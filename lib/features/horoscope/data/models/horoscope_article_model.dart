import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/horoscope_article.dart';

class HoroscopeArticleModel extends HoroscopeArticle {
  HoroscopeArticleModel({
    required super.id,
    required super.title,
    required super.date,
    required super.body,
    required super.buttonLabel,
  });

  factory HoroscopeArticleModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return HoroscopeArticleModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      date: data['date'] as String? ?? '',
      body: data['body'] as String? ?? '',
      buttonLabel: data['buttonLabel'] as String? ?? 'Read more',
    );
  }
}

