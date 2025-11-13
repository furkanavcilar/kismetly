import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationSuggestion {
  final String displayName;
  final String city;
  final String? country;
  final double latitude;
  final double longitude;

  const LocationSuggestion({
    required this.displayName,
    required this.city,
    this.country,
    required this.latitude,
    required this.longitude,
  });
}

class LocationAutocompleteService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  Future<List<LocationSuggestion>> search(String query) async {
    if (query.trim().length < 2) return [];

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        '$_nominatimBaseUrl/search?q=$encodedQuery&format=json&limit=5&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Kismetly/1.0',
        },
      );

      if (response.statusCode != 200) return [];

      final List<dynamic> data = json.decode(response.body);
      return data.map((item) {
        final address = item['address'] as Map<String, dynamic>? ?? {};
        final city = address['city'] ?? 
                     address['town'] ?? 
                     address['village'] ?? 
                     address['municipality'] ?? 
                     item['display_name']?.toString().split(',').first ?? '';
        final country = address['country'] as String?;
        
        return LocationSuggestion(
          displayName: item['display_name'] as String? ?? '',
          city: city.toString(),
          country: country,
          latitude: double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0,
          longitude: double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

