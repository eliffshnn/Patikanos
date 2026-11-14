import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'detail_screen.dart';
import 'notification_service.dart';
import 'weather_model.dart';
import 'weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({
    super.key,
    this.lat = WeatherService.muglaLat,
    this.lon = WeatherService.muglaLon,
    this.placeName = 'Muğla',
    this.initialActivity = 'bike',
  });

  final double lat;
  final double lon;
  final String placeName;
  final String initialActivity;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _service = WeatherService();
  late String _activity = widget.initialActivity;
  late Future<WeatherScore> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _service.getScore(lat: widget.lat, lon: widget.lon, activity: _activity);
    NotificationService.scheduleAll(_activity).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bugün · ${widget.placeName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Bildirim testi',
            onPressed: () => NotificationService.testIn5Seconds(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  selectedBackgroundColor: AppColors.pine,
                  selectedForegroundColor: Colors.white,
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.line),
                ),
                segments: const [
                  ButtonSegment(value: 'bike', label: Text('Bisiklet'), icon: Icon(Icons.directions_bike_rounded)),
                  ButtonSegment(value: 'walk', label: Text('Yürüyüş'), icon: Icon(Icons.hiking_rounded)),
                ],
                selected: {_activity},
                onSelectionChanged: (s) => setState(() {
                  _activity = s.first;
                  _load();
                }),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<WeatherScore>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ErrorView(onRetry: () => setState(_load));
                }
                return _ScoreView(data: snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreView extends StatelessWidget {
  final WeatherScore data;
  const _ScoreView({required this.data});

  @override
  Widget build(BuildContext context) {
    final score = data.nowScore;
    final daytime = data.hourly.where((h) {
      final hour = int.parse(h.time.substring(0, 2));
      return hour >= 6 && hour < 21;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 108,
                height: 108,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: (score ?? 0) / 10,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      color: score == null ? Colors.white54 : scoreColor(score),
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                    ),
                    Center(
                      child: Text(
                        score == null ? '–' : '$score',
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Şu an · ${data.nowTime ?? '-'}',
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      score == null ? 'Skor yok' : scoreLabel(score),
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '10 üzerinden ${data.activity == 'bike' ? 'bisiklet' : 'yürüyüş'} uygunluğu',
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.sunset.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.wb_twilight_rounded, color: AppColors.sunset),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bugünün en iyi zamanı', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      Text(
                        data.bestStart == null ? 'Bugün uygun saat yok' : '${data.bestStart} – ${data.bestEnd}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(data: data)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Saatlik skor', style: Theme.of(context).textTheme.titleMedium)),
                      const Text('Detay', style: TextStyle(color: AppColors.sea, fontWeight: FontWeight.w600)),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.sea),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 96,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final h in daytime)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 8 + 64 * h.score / 10,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: scoreColor(h.score).withValues(alpha: h.time == data.nowTime ? 1 : 0.75),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  h.time.substring(0, 2),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: h.time == data.nowTime ? AppColors.ink : AppColors.muted,
                                    fontWeight: h.time == data.nowTime ? FontWeight.w800 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (data.warnings.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Dikkat', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          for (final warning in data.warnings)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.sunset.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.sunset),
                  const SizedBox(width: 12),
                  Expanded(child: Text(warning, style: Theme.of(context).textTheme.bodyLarge)),
                ],
              ),
            ),
        ],
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(color: AppColors.seaLight, shape: BoxShape.circle),
              child: const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.sea),
            ),
            const SizedBox(height: 16),
            Text('Hava durumu alınamadı', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Sunucuya ulaşılamıyor. İnternet bağlantını ya da backend\'in çalıştığını kontrol et.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}
