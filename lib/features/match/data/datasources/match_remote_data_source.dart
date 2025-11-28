import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firestore_paths.dart';
import '../models/match_profile_model.dart';

class MatchRemoteDataSource {
  MatchRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<Map<String, List<MatchProfileModel>>> fetchMatchSections() async {
    final query = await _firestore
        .collection(FirestorePaths.matchesCollection())
        .get();
    final byCategory = <String, List<MatchProfileModel>>{};
    for (final doc in query.docs) {
      final model = MatchProfileModel.fromDoc(
        doc as DocumentSnapshot<Map<String, dynamic>>,
      );
      byCategory.putIfAbsent(model.category, () => []).add(model);
    }
    return byCategory;
  }
}

