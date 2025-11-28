import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firestore_paths.dart';
import '../models/horoscope_article_model.dart';

class HoroscopeRemoteDataSource {
  HoroscopeRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<HoroscopeArticleModel>> fetchArticles() async {
    final query = await _firestore
        .collection(FirestorePaths.horoscopesCollection())
        .get();
    return query.docs
        .map(
          (doc) => HoroscopeArticleModel.fromDoc(
            doc as DocumentSnapshot<Map<String, dynamic>>,
          ),
        )
        .toList();
  }
}

