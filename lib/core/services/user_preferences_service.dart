import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to manage user preferences (tabs, horoscope settings, etc.)
class UserPreferencesService {
  static final UserPreferencesService _instance = UserPreferencesService._();
  static UserPreferencesService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserPreferencesService._();

  /// Get user preferences
  Future<Map<String, dynamic>> getPreferences(String userId) async {
    final doc = await _firestore
        .doc('user_preferences/$userId')
        .get();
    
    if (!doc.exists) {
      return _getDefaultPreferences();
    }
    
    return doc.data() ?? _getDefaultPreferences();
  }

  /// Update user preferences
  Future<void> updatePreferences(String userId, Map<String, dynamic> prefs) async {
    await _firestore.doc('user_preferences/$userId').set({
      ...prefs,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Update profile tab preference (Chart/Aspects)
  Future<void> updateProfileTab(String userId, String tab) async {
    await updatePreferences(userId, {'profileTab': tab});
  }

  /// Update horoscope preferences
  Future<void> updateHoroscopePrefs(String userId, {
    bool? enabled,
    String? selectedSign,
  }) async {
    final updates = <String, dynamic>{};
    if (enabled != null) updates['horoscopeEnabled'] = enabled;
    if (selectedSign != null) updates['horoscopeSign'] = selectedSign;
    
    await updatePreferences(userId, updates);
  }

  /// Mark notifications as skipped
  Future<void> skipNotifications(String userId) async {
    await updatePreferences(userId, {
      'notificationsSkipped': true,
      'notificationsSkippedAt': FieldValue.serverTimestamp(),
    });
  }

  Map<String, dynamic> _getDefaultPreferences() {
    return {
      'profileTab': 'Chart',
      'horoscopeEnabled': true,
      'notificationsSkipped': false,
    };
  }
}

