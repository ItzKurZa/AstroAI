import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/characteristic.dart';

class CharacteristicModel extends Characteristic {
  CharacteristicModel({
    required super.id,
    required super.title,
    required super.house,
    required super.description,
    required super.imageUrl,
    required super.order,
  });

  factory CharacteristicModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return CharacteristicModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      house: data['house'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ??
          'assets/images/app/planet-icons/Sun.png',
      order: (data['order'] as num?)?.toInt() ?? 0,
    );
  }
}

