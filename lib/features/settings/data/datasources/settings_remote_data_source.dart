import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/firebase/firestore_paths.dart';

/// Data source for settings operations
class SettingsRemoteDataSource {
  SettingsRemoteDataSource(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Change user password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Re-authenticate with current password
    final credential = EmailAuthProvider.credential(
      email: user.email ?? '',
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Update password
    await user.updatePassword(newPassword);
  }

  /// Change phone number
  Future<void> changePhoneNumber(String newPhoneNumber) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Update in Firestore
    await _firestore.doc(FirestorePaths.user(user.uid)).update({
      'phoneNumber': newPhoneNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Wipe account - delete all user data
  Future<void> wipeAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userId = user.uid;

    // Delete user data from Firestore
    final batch = _firestore.batch();
    
    // Delete user profile
    batch.delete(_firestore.doc(FirestorePaths.user(userId)));
    
    // Delete notification prefs
    batch.delete(_firestore.doc(FirestorePaths.notificationPrefsDoc(userId)));
    
    // Delete chat thread
    final chatThread = _firestore.doc(FirestorePaths.chatThread(userId));
    final messages = await chatThread.collection('messages').get();
    for (final msg in messages.docs) {
      batch.delete(msg.reference);
    }
    batch.delete(chatThread);
    
    // Delete shared charts
    final sharedCharts = await _firestore
        .collection('shared_charts')
        .where('userId', isEqualTo: userId)
        .get();
    for (final chart in sharedCharts.docs) {
      batch.delete(chart.reference);
    }

    await batch.commit();

    // Delete auth account
    await user.delete();
  }

  /// Log out user
  Future<void> logOut() async {
    await _auth.signOut();
  }

  /// Contact support - save support request
  Future<void> contactSupport({
    required String subject,
    required String message,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('support_requests').add({
      'userId': user.uid,
      'email': user.email,
      'subject': subject,
      'message': message,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

