import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../api/api_config.dart';

/// A trail route; fields match docs/route-data-format.md.
class TrailRoute {
  final String id;
  final String name;
  final String region;
  final List<String> activity;
  final double distanceKm;
  final int elevationGainM;
  final int difficulty;
  final int? estDurationMin;
  final double startLat;
  final double startLon;
  final List<String> warnings;
  final String? sourceUrl;

  TrailRoute({
    required this.id,
    required this.name,
    required this.region,
    required this.activity,
    required this.distanceKm,
    required this.elevationGainM,
    required this.difficulty,
    this.estDurationMin,
    required this.startLat,
    required this.startLon,
    required this.warnings,
    this.sourceUrl,
  });

  bool get isCycling => activity.contains('cycling');
  bool get isWalking => activity.contains('walking');

  /// Activity name expected by the weather score API.
  String get weatherActivity => isCycling && !isWalking ? 'bike' : 'walk';

  /// Rough estimate when no duration is given: walking 4 km/h plus 10 min
  /// per 100 m of climbing, cycling 15 km/h.
  int get durationMin =>
      estDurationMin ??
      (isCycling && !isWalking
          ? (distanceKm / 15 * 60).round()
          : (distanceKm / 4 * 60 + elevationGainM / 100 * 10).round());

  factory TrailRoute.fromFeature(Map<String, dynamic> feature) {
    final p = feature['properties'] as Map<String, dynamic>;
    final start = (p['start'] as List).cast<num>();
    return TrailRoute(
      id: p['id'] as String,
      name: p['name'] as String,
      region: p['region'] as String,
      activity: (p['activity'] as List).cast<String>(),
      distanceKm: (p['distance_km'] as num).toDouble(),
      elevationGainM: (p['elevation_gain_m'] as num).toInt(),
      difficulty: (p['difficulty'] as num).toInt(),
      estDurationMin: (p['est_duration_min'] as num?)?.toInt(),
      startLon: start[0].toDouble(),
      startLat: start[1].toDouble(),
      warnings: ((p['warnings'] as List?) ?? const []).cast<String>(),
      sourceUrl: p['source_url'] as String?,
    );
  }
}

String formatDuration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m dk';
  if (m == 0) return '$h sa';
  return '$h sa $m dk';
}

class RouteRepository {
  static Future<List<TrailRoute>>? _cache;

  /// Routes are read from the backend's /routes API (B-8). If the backend is
  /// down, returns an error or returns an empty list, the bundled
  /// docs/routes.geojson is used instead, so the app keeps working.
  static Future<List<TrailRoute>> load() => _cache ??= _read();

  /// Her widget testi kendi sahte zamanında çalışır; önceki testin Future'ı orada tamamlanmaz.
  @visibleForTesting
  static void clearCache() => _cache = null;

  static Future<List<TrailRoute>> _read() async {
    try {
      return await _fromApi();
    } catch (e) {
      debugPrint('Could not load routes from the API, using bundled file: $e');
      return _fromAsset();
    }
  }

  static Future<List<TrailRoute>> _fromApi() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/routes'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final routes = _parse(utf8.decode(response.bodyBytes));
    // An empty database (routes not seeded yet) should not leave the app empty.
    if (routes.isEmpty) throw Exception('API returned no routes');
    return routes;
  }

  static Future<List<TrailRoute>> _fromAsset() async =>
      _parse(await rootBundle.loadString('docs/routes.geojson'));

  // The API and the bundled file use the same GeoJSON FeatureCollection format.
  static List<TrailRoute> _parse(String raw) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (data['features'] as List)
        .map((f) => TrailRoute.fromFeature(f as Map<String, dynamic>))
        .toList();
  }
}