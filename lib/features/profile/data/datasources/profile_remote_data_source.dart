import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firestore_paths.dart';
import '../models/characteristic_model.dart';
import '../models/user_profile_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<UserProfileModel> fetchProfile(String userId) async {
    final doc =
        await _firestore.doc(FirestorePaths.user(userId)).get();
    if (!doc.exists) {
      throw Exception('User not found');
    }
    return UserProfileModel.fromDoc(doc);
  }

  Future<List<CharacteristicModel>> fetchCharacteristics() async {
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
}

