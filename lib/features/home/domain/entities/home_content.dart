import '../../../profile/domain/entities/user_profile.dart';
import 'daily_section.dart';
import 'planet_entry.dart';
import 'tip_of_day.dart';

class HomeContent {
  const HomeContent({
    required this.user,
    required this.planets,
    required this.sections,
    required this.tip,
  });

  final UserProfile user;
  final List<PlanetEntry> planets;
  final List<DailySection> sections;
  final TipOfDay tip;
}

