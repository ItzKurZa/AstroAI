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
    try {
    final doc =
        await _firestore.doc(FirestorePaths.user(userId)).get();
    if (!doc.exists) {
        print('❌ User document does not exist: $userId');
      throw Exception('User not found');
    }
      
      final data = doc.data();
      if (data == null || data.isEmpty) {
        print('❌ User document exists but has no data: $userId');
        throw Exception('User data is empty');
      }
      
      try {
    return UserProfileModel.fromDoc(doc);
      } catch (e) {
        print('❌ Error parsing user profile: $e');
        print('Document data: $data');
        rethrow;
      }
    } catch (e) {
      print('❌ Error in fetchProfile for user $userId: $e');
      rethrow;
    }
  }

  Future<List<CharacteristicModel>> fetchCharacteristics({String? userId}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;
      
      // If userId provided, fetch user-specific characteristics
      if (userId != null) {
        // Fetch without orderBy to avoid needing composite index
        // We'll sort manually in code
        querySnapshot = await _firestore
            .collection(FirestorePaths.characteristicsCollection())
            .where('userId', isEqualTo: userId)
            .get();
      } else {
        // Fetch all characteristics (no filter, no orderBy needed)
        querySnapshot = await _firestore
            .collection(FirestorePaths.characteristicsCollection())
            .get();
      }
      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }
      
      // Sort manually by order field (avoids needing Firestore index)
      final docs = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return MapEntry(
          (data['order'] as num?)?.toInt() ?? 999,
          CharacteristicModel.fromDoc(doc),
        );
      }).toList();
      
      docs.sort((a, b) => a.key.compareTo(b.key));
      return docs.map((e) => e.value).toList();
    } catch (e) {
      print('❌ Error fetching characteristics: $e');
      // Return empty list instead of throwing to prevent profile page from failing
      return [];
    }
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
    try {
      final snapshot = await _firestore
        .doc(FirestorePaths.user(userId))
        .collection('aspects')
        .get();
    
      if (snapshot.docs.isEmpty) {
      // Return empty list if no aspects found
      // In production, aspects should be calculated from birth chart
      return [];
    }
    
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
    } catch (e) {
      print('⚠️ Error fetching aspects for user $userId: $e');
      // Return empty list instead of throwing to prevent profile page from failing
      return [];
    }
  }
}

