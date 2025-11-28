import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firestore_paths.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../models/home_content_model.dart';

class HomeRemoteDataSource {
  HomeRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<HomeContentModel> fetchContent(String userId) async {
    final planetsDoc =
        await _firestore.doc(FirestorePaths.planetsTodayDoc()).get();
    final sectionsDoc =
        await _firestore.doc(FirestorePaths.youTodayDoc()).get();
    final tipDoc = await _firestore.doc(FirestorePaths.tipOfDayDoc()).get();
    final userDoc = await _firestore.doc(FirestorePaths.user(userId)).get();

    final user = UserProfileModel.fromDoc(userDoc);

    return HomeContentModel.fromSnapshots(
      planetsDoc: planetsDoc,
      sectionsDoc: sectionsDoc,
      tipDoc: tipDoc,
      user: user,
    );
  }

  Future<UserProfileModel> fetchUser(String userId) async {
    final doc = await _firestore.doc(FirestorePaths.user(userId)).get();
    return UserProfileModel.fromDoc(doc);
  }
}

