import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firestore_paths.dart';
import '../../../../core/services/astrology_service.dart';
import '../models/characteristic_model.dart';
import '../models/user_profile_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;
  final AstrologyService _astrologyService = AstrologyService.instance;

  Future<UserProfileModel> fetchProfile(String userId) async {
    final doc =
        await _firestore.doc(FirestorePaths.user(userId)).get();
    if (!doc.exists) {
      throw Exception('User not found');
    }
    return UserProfileModel.fromDoc(doc);
  }

  Future<List<CharacteristicModel>> fetchCharacteristics({String? userId}) async {
    // If userId provided, fetch user-specific characteristics
    if (userId != null) {
      final query = await _firestore
          .collection(FirestorePaths.characteristicsCollection())
          .where('userId', isEqualTo: userId)
          .orderBy('order')
          .get();
      
      if (query.docs.isNotEmpty) {
        return query.docs
            .map((doc) => CharacteristicModel.fromDoc(doc))
            .toList();
      }
    }
    
    // Fallback to general characteristics (or if no userId provided)
    final query = await _firestore
        .collection(FirestorePaths.characteristicsCollection())
        .orderBy('order')
        .get();
    return query.docs
        .map(
          (doc) => CharacteristicModel.fromDoc(doc),
        )
        .toList();
  }

  /// Update user profile fields
  Future<void> updateProfile(String userId, {
    String? displayName,
    String? avatarUrl,
    String? birthDate,
    String? birthTime,
    String? birthPlace,
    String? location,
  }) async {
    final doc = _firestore.doc(FirestorePaths.user(userId));
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (displayName != null) updates['displayName'] = displayName;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
    if (birthDate != null) updates['birthDate'] = birthDate;
    if (birthTime != null) updates['birthTime'] = birthTime;
    if (birthPlace != null) updates['birthPlace'] = birthPlace;
    if (location != null) updates['location'] = location;

    await doc.update(updates);
  }

  /// Calculate and update astrological signs
  Future<void> updateAstrologicalSigns(String userId) async {
    final profile = await fetchProfile(userId);
    
    // Parse birth date
    final birthDateParts = profile.birthDate.split('-');
    if (birthDateParts.length != 3) return;
    
    final birthDate = DateTime(
      int.parse(birthDateParts[0]),
      int.parse(birthDateParts[1]),
      int.parse(birthDateParts[2]),
    );

    // Parse birth place for coordinates (simplified - in production use geocoding)
    // For now, use default coordinates
    final latitude = 0.0;
    final longitude = 0.0;

    // Calculate signs
    final sunSign = await _astrologyService.getSunSign(birthDate);
    final moonSign = await _astrologyService.getMoonSign(
      birthDate,
      profile.birthTime,
      latitude: latitude,
      longitude: longitude,
    );
    final ascendantSign = await _astrologyService.getAscendant(
      birthDate,
      profile.birthTime,
      latitude,
      longitude,
    );

    // Update in Firestore
    final doc = _firestore.doc(FirestorePaths.user(userId));
    await doc.update({
      'sunSign': sunSign,
      'moonSign': moonSign,
      'ascendantSign': ascendantSign,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Generate shareable chart data
  Future<Map<String, dynamic>> shareChart(String userId) async {
    final profile = await fetchProfile(userId);
    
    // Create shareable chart data
    final shareData = {
      'userId': userId,
      'displayName': profile.displayName,
      'sunSign': profile.sunSign,
      'moonSign': profile.moonSign,
      'ascendantSign': profile.ascendantSign,
      'birthDate': profile.birthDate,
      'sharedAt': FieldValue.serverTimestamp(),
    };

    // Save to shared_charts collection
    final shareDoc = await _firestore
        .collection('shared_charts')
        .add(shareData);

    return {
      'shareId': shareDoc.id,
      'shareUrl': 'https://astroai.app/share/${shareDoc.id}',
      'data': shareData,
    };
  }

  /// Fetch aspects for user's birth chart
  Future<List<Map<String, dynamic>>> fetchAspects(String userId) async {
    final doc = await _firestore
        .doc(FirestorePaths.user(userId))
        .collection('aspects')
        .get();
    
    if (doc.docs.isEmpty) {
      // Return empty list if no aspects found
      // In production, aspects should be calculated from birth chart
      return [];
    }
    
    return doc.docs.map((doc) => doc.data()).toList();
  }
}

