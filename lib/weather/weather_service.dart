import 'dart:convert';

import '../api/api_config.dart';
import 'package:http/http.dart' as http;

import 'weather_model.dart';

class WeatherService {
  static const muglaLat = 37.21;
  static const muglaLon = 28.36;

  Future<WeatherScore> getScore({
    required double lat,
    required double lon,
    required String activity,
    String day = 'today',
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/weather/score').replace(queryParameters: {
      'lat': '$lat',
      'lon': '$lon',
      'activity': activity,
      'day': day,
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Sunucu hatası (${response.statusCode})');
    }
    return WeatherScore.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }
}