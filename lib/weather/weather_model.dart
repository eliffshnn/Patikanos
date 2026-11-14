import 'package:flutter/material.dart';

class HourlyWeather {
  final String time;
  final int score;
  final double feelsLike;
  final double wind;
  final int rainProb;
  final double uv;

  HourlyWeather({
    required this.time,
    required this.score,
    required this.feelsLike,
    required this.wind,
    required this.rainProb,
    required this.uv,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) => HourlyWeather(
        time: json['time'] as String,
        score: (json['score'] as num).toInt(),
        feelsLike: (json['feels_like'] as num).toDouble(),
        wind: (json['wind'] as num).toDouble(),
        rainProb: (json['rain_prob'] as num? ?? 0).toInt(),
        uv: (json['uv'] as num).toDouble(),
      );
}

class WeatherScore {
  final String activity;
  final String? nowTime;
  final int? nowScore;
  final List<Tip> nowTips;
  final String? bestStart;
  final String? bestEnd;
  final List<String> warnings;
  final List<HourlyWeather> hourly;

  WeatherScore({
    required this.activity,
    this.nowTime,
    this.nowScore,
    this.nowTips = const [],
    this.bestStart,
    this.bestEnd,
    required this.warnings,
    required this.hourly,
  });

  factory WeatherScore.fromJson(Map<String, dynamic> json) {
    final now = json['now'] as Map<String, dynamic>?;
    final best = json['best_window'] as Map<String, dynamic>?;
    return WeatherScore(
      activity: json['activity'] as String,
      nowTime: now?['time'] as String?,
      nowScore: (now?['score'] as num?)?.toInt(),
      nowTips: ((now?['tips'] as List?) ?? const []).map((t) => Tip.fromJson(t as Map<String, dynamic>)).toList(),
      bestStart: best?['start'] as String?,
      bestEnd: best?['end'] as String?,
      warnings: (json['warnings'] as List).cast<String>(),
      hourly: (json['hourly'] as List)
          .map((h) => HourlyWeather.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }
}

Color scoreColor(int score) {
  if (score >= 9) return Colors.green;
  if (score >= 7) return Colors.lightGreen;
  if (score >= 5) return Colors.orange;
  if (score >= 3) return Colors.deepOrange;
  return Colors.red;
}

String scoreLabel(int score) {
  if (score >= 9) return 'Harika';
  if (score >= 7) return 'İyi';
  if (score >= 5) return 'İdare eder, hazırlıklı çık';
  if (score >= 3) return 'Zor';
  return 'Önerilmez';
}

String activityName(String activity) => activity == 'walk'
    ? 'Yürüyüş'
    : (activity == 'both' ? 'Bisiklet ve Yürüyüş' : 'Bisiklet');



class Tip {
  final String type;
  final String text;
  const Tip(this.type, this.text);

  factory Tip.fromJson(Map<String, dynamic> json) =>
      Tip(json['type'] as String, json['text'] as String);
}

IconData tipIcon(String type) {
  switch (type) {
    case 'temperature':
      return Icons.thermostat;
    case 'wind':
      return Icons.air;
    case 'rain':
      return Icons.umbrella;
    case 'sun':
      return Icons.wb_sunny;
    case 'visibility':
      return Icons.flashlight_on;
    case 'safety':
      return Icons.health_and_safety;
    default:
      return Icons.info_outline;
  }
}