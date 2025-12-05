import 'influential_planet.dart';

class DailySection {
  const DailySection({
    required this.title,
    required this.description,
    required this.planets,
  });

  final String title;
  final String description;
  final List<InfluentialPlanet> planets;
}

