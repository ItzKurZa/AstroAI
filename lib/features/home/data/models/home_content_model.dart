import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../profile/data/models/user_profile_model.dart';
import '../../domain/entities/home_content.dart';
import 'daily_section_model.dart';
import 'planet_entry_model.dart';
import 'tip_of_day_model.dart';

class HomeContentModel extends HomeContent {
  HomeContentModel({
    required super.user,
    required super.planets,
    required super.sections,
    required super.tip,
  });

  factory HomeContentModel.fromSnapshots({
    required DocumentSnapshot<Map<String, dynamic>> planetsDoc,
    required DocumentSnapshot<Map<String, dynamic>> sectionsDoc,
    required DocumentSnapshot<Map<String, dynamic>> tipDoc,
    required UserProfileModel user,
  }) {
    final planetsData = (planetsDoc.data()?['cards'] as List<dynamic>? ?? [])
        .map((e) => PlanetEntryModel.fromMap(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();

    final sectionsData = (sectionsDoc.data()?['sections'] as List<dynamic>? ??
            [])
        .map((e) => DailySectionModel.fromMap(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();

    final tip = TipOfDayModel.fromMap(tipDoc.data() ?? {});

    return HomeContentModel(
      user: user,
      planets: planetsData,
      sections: sectionsData,
      tip: tip,
    );
  }
}

