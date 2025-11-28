import 'influential_planet_model.dart';
import '../../domain/entities/daily_section.dart';

class DailySectionModel extends DailySection {
  DailySectionModel({
    required super.title,
    required super.description,
    required List<InfluentialPlanetModel> super.planets,
  });

  factory DailySectionModel.fromMap(Map<String, dynamic> data) {
    final planets = (data['planets'] as List<dynamic>? ?? [])
        .map((e) => InfluentialPlanetModel.fromMap(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
    return DailySectionModel(
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      planets: planets,
    );
  }
}

