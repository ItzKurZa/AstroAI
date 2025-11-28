import 'dart:convert';

import 'package:http/http.dart' as http;

class LocationService {
  Future<List<Map<String, String>>> searchAddress(String query) async {
    // Remove middle dot (·) used during Vietnamese IME composing and trim whitespace
    final cleanQuery = query.replaceAll('·', '').trim();
    
    if (cleanQuery.length < 2) return [];

    try {
      // Use Uri.https() for proper URL encoding of query parameters
      // Note: Photon API doesn't support lang=vi, so we omit it
      final url = Uri.https('photon.komoot.io', '/api/', {
        'q': cleanQuery,
        'limit': '5',
      });
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List features = data['features'] as List<dynamic>;

        return features.map<Map<String, String>>((feature) {
          final props = feature['properties'] as Map<String, dynamic>;

          final name = props['name'] as String? ?? '';
          final city =
              props['city'] as String? ?? props['state'] as String? ?? '';
          final country = props['country'] as String? ?? '';

          final coords = feature['geometry']['coordinates'] as List<dynamic>;
          final lat = (coords[1] as num).toDouble();
          final lng = (coords[0] as num).toDouble();

          return {
            'display_name': '$name, $city, $country',
            'lat': lat.toString(),
            'lng': lng.toString(),
          };
        }).toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('LocationService error: $e');
    }
    return [];
  }
}


