import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api/api_config.dart';
import '../theme/app_theme.dart';
import 'weather_model.dart';

class DayForecast {
  final DateTime date;
  final int maxScore;
  final double minFeels;
  final double maxFeels;
  final String? bestStart;
  final String? bestEnd;

  DayForecast.fromJson(Map<String, dynamic> j)
      : date = DateTime.parse(j['date'] as String),
        maxScore = (j['max_score'] as num).toInt(),
        minFeels = (j['min_feels_like'] as num).toDouble(),
        maxFeels = (j['max_feels_like'] as num).toDouble(),
        bestStart = (j['best_window'] as Map?)?['start'] as String?,
        bestEnd = (j['best_window'] as Map?)?['end'] as String?;
}

Future<List<DayForecast>> fetchWeek(double lat, double lon, String activity) async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/weather/week').replace(queryParameters: {
    'lat': '$lat',
    'lon': '$lon',
    'activity': activity,
  });
  final r = await http.get(uri).timeout(const Duration(seconds: 10));
  if (r.statusCode != 200) throw Exception('Sunucu hatası (${r.statusCode})');
  final body = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
  return (body['days'] as List).map((d) => DayForecast.fromJson(d)).toList();
}

const _dayNames = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key, required this.activity, required this.lat, required this.lon, required this.placeName});
  final String activity;
  final double lat;
  final double lon;
  final String placeName;

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  late Future<List<DayForecast>> _future;

  String get _act => widget.activity == 'walk' ? 'walk' : 'bike';

  @override
  void initState() {
    super.initState();
    _future = fetchWeek(widget.lat, widget.lon, _act);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('7 günlük · ${widget.placeName}')),
      body: FutureBuilder<List<DayForecast>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _future = fetchWeek(widget.lat, widget.lon, _act)),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tahmin alınamadı, tekrar dene'),
              ),
            );
          }
          final days = snap.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final d = days[i];
              final name = i == 0 ? 'Bugün' : (i == 1 ? 'Yarın' : _dayNames[d.date.weekday - 1]);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scoreColor(d.maxScore),
                    child: Text('${d.maxScore}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text('$name  ·  ${d.date.day}.${d.date.month}'),
                  subtitle: Text(d.bestStart != null
                      ? 'En iyi zaman ${d.bestStart}–${d.bestEnd} · ${scoreLabel(d.maxScore)}'
                      : 'Uygun zaman yok · ${scoreLabel(d.maxScore)}'),
                  trailing: Text('${d.minFeels.round()}° / ${d.maxFeels.round()}°',
                      style: const TextStyle(color: AppColors.muted)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
