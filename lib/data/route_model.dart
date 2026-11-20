import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bir rota; alanlar docs/route-data-format.md ile aynı.
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

  /// Hava skoru API'sinin beklediği aktivite adı.
  String get weatherActivity => isCycling && !isWalking ? 'bike' : 'walk';

  /// Süre yoksa kaba tahmin: yürüyüşte 4 km/sa + her 100 m tırmanış için 10 dk, bisiklette 15 km/sa.
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

  /// Sprint 3: rotalar uygulamayla birlikte gelen GeoJSON'dan okunur (Sprint 4'te /routes API'si).
  static Future<List<TrailRoute>> load() => _cache ??= _read();

  /// Her widget testi kendi sahte zamanında çalışır; önceki testin Future'ı orada tamamlanmaz.
  @visibleForTesting
  static void clearCache() => _cache = null;

  static Future<List<TrailRoute>> _read() async {
    final raw = await rootBundle.loadString('docs/routes.geojson');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (data['features'] as List)
        .map((f) => TrailRoute.fromFeature(f as Map<String, dynamic>))
        .toList();
  }
}
