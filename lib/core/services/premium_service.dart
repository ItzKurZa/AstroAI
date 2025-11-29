import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase/firestore_paths.dart';

/// Service to manage premium subscription status
class PremiumService {
  static final PremiumService _instance = PremiumService._();
  static PremiumService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PremiumService._();

  /// Get premium status for user
  Future<bool> isPremium(String userId) async {
    final doc = await _firestore.doc(FirestorePaths.user(userId)).get();
    final data = doc.data() ?? {};
    final planType = data['planType'] as String? ?? 'Free';
    return planType == 'Premium' || planType == 'Pro';
  }

  /// Update premium status
  Future<void> updatePremiumStatus(String userId, String planType) async {
    await _firestore.doc(FirestorePaths.user(userId)).update({
      'planType': planType,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get premium features available
  List<String> getPremiumFeatures() {
    return [
      'Unlimited daily insights',
      'Advanced birth chart analysis',
      'Personalized AI advisor',
      'Priority support',
      'Ad-free experience',
    ];
  }
}

