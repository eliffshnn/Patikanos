import 'package:flutter/material.dart';

import 'detail_screen.dart';
import 'notification_service.dart';
import 'weather_model.dart';
import 'weather_service.dart';

const weatherBackground = Color(0xFFF5F4F2);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.activity = 'bike'});

  /// 'bike', 'walk' veya 'both'
  final String activity;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = WeatherService();
  late Future<List<WeatherScore>> _future;

  List<String> get _activities =>
      widget.activity == 'both' ? ['bike', 'walk'] : [widget.activity];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = Future.wait(_activities.map((a) => _service.getScore(
          lat: WeatherService.muglaLat,
          lon: WeatherService.muglaLon,
          activity: a,
        )));
    NotificationService.scheduleAll(_activities.first).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: weatherBackground,
      appBar: AppBar(
        backgroundColor: weatherBackground,
        title: Text('Bugün · ${activityName(widget.activity)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Bildirim testi',
            onPressed: () => NotificationService.testIn5Seconds(),
          ),
        ],
      ),
      body: FutureBuilder<List<WeatherScore>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(onRetry: () => setState(_load));
          }
          final results = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final data in results)
                _ActivitySection(data: data, showTitle: results.length > 1),
            ],
          );
        },
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final WeatherScore data;
  final bool showTitle;
  const _ActivitySection({required this.data, required this.showTitle});

  @override
  Widget build(BuildContext context) {
    final score = data.nowScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(activityName(data.activity),
                style: Theme.of(context).textTheme.titleLarge),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text('Şu an (${data.nowTime ?? '-'})'),
                const SizedBox(height: 8),
                Text(
                  score == null ? '-' : '$score/10',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: score == null ? Colors.grey : scoreColor(score),
                  ),
                ),
                if (score != null) Text(scoreLabel(score)),
              ],
            ),
          ),
        ),
                if (data.nowTips.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.backpack, size: 20),
                      SizedBox(width: 8),
                      Text('Bunları unutma', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final tip in data.nowTips)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(tipIcon(tip.type), size: 18, color: Colors.teal),
                          const SizedBox(width: 10),
                          Expanded(child: Text(tip.text)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Sıradaki en iyi zaman'),
            subtitle: Text(data.bestStart == null
                ? 'Bugün için uygun saat kalmadı, yarına bak'
                : '${data.bestStart} – ${data.bestEnd}'),
          ),
        ),
        for (final warning in data.warnings)
          Card(
            child: ListTile(
              leading: const Icon(Icons.warning_amber, color: Colors.orange),
              title: Text(warning),
            ),
          ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Saatlik detay'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(data: data)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48),
          const SizedBox(height: 8),
          const Text('Hava durumu alınamadı'),
          const SizedBox(height: 8),
          FilledButton(onPressed: onRetry, child: const Text('Tekrar dene')),
        ],
      ),
    );
  }
}