import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firestore_paths.dart';
import '../models/notification_prefs_model.dart';

class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<NotificationPrefsModel> fetchPrefs(String userId) async {
    final doc = await _firestore
        .doc(FirestorePaths.notificationPrefsDoc(userId))
        .get();
    return NotificationPrefsModel.fromMap(
      doc.data() ?? const {},
    );
  }

  Future<void> updatePrefs(String userId, NotificationPrefsModel prefs) async {
    await _firestore
        .doc(FirestorePaths.notificationPrefsDoc(userId))
        .set(prefs.toMap(), SetOptions(merge: true));
  }
}

