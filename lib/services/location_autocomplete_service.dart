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
      // Optimize for Turkish cities - bias search to Turkey when query looks Turkish
      final trimmed = query.trim().toLowerCase();
      final isTurkishQuery = trimmed.contains(RegExp(r'[ığüşöç]')) || 
                             ['istanbul', 'ankara', 'izmir', 'bursa', 'antalya', 'adana'].any((city) => trimmed.contains(city));
      
      // Add country bias for Turkish queries
      final countryBias = isTurkishQuery ? '&countrycodes=tr' : '';
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        '$_nominatimBaseUrl/search?q=$encodedQuery&format=json&limit=8&addressdetails=1$countryBias',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Kismetly/1.0',
        },
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode != 200) return [];

      final List<dynamic> data = json.decode(response.body);
      final suggestions = <LocationSuggestion>[];
      
      for (final item in data) {
        final address = item['address'] as Map<String, dynamic>? ?? {};
        final city = address['city'] ?? 
                     address['town'] ?? 
                     address['village'] ?? 
                     address['municipality'] ?? 
                     address['county'] ??
                     item['display_name']?.toString().split(',').first ?? '';
        final country = address['country'] as String?;
        final district = address['suburb'] ?? address['neighbourhood'] ?? '';
        
        // Prioritize Turkish cities for Turkish queries
        if (isTurkishQuery && country != 'Türkiye' && country != 'Turkey' && suggestions.length >= 3) {
          continue;
        }
        
        suggestions.add(LocationSuggestion(
          displayName: item['display_name'] as String? ?? '',
          city: city.toString(),
          country: country,
          latitude: double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0,
          longitude: double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0,
        ));
        
        if (suggestions.length >= 5) break;
      }
      
      return suggestions;
    } catch (e) {
      return [];
    }
  }
}

