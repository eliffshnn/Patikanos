import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'detail_screen.dart';
import 'notification_service.dart';
import 'weather_model.dart';
import 'weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({
    super.key,
    this.activity = 'bike',
    this.lat = WeatherService.muglaLat,
    this.lon = WeatherService.muglaLon,
    this.placeName = 'Muğla',
  });

  /// 'bike', 'walk' veya 'both'
  final String activity;
  final double lat;
  final double lon;
  final String placeName;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
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
          lat: widget.lat,
          lon: widget.lon,
          activity: a,
        )));
    NotificationService.scheduleAll(_activities.first).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bugün · ${activityName(widget.activity)}'),
            Row(
              children: [
                const Icon(Icons.place_rounded, size: 13, color: AppColors.sea),
                const SizedBox(width: 2),
                Text(widget.placeName, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
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
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
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
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showTitle)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 10),
              child: Row(
                children: [
                  Icon(
                    data.activity == 'bike' ? Icons.directions_bike_rounded : Icons.hiking_rounded,
                    color: AppColors.pine,
                  ),
                  const SizedBox(width: 8),
                  Text(activityName(data.activity), style: textTheme.titleLarge),
                ],
              ),
            ),
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
                        color: score == null ? AppColors.onDarkSubtle : scoreColor(score),
                        backgroundColor: AppColors.glass,
                      ),
                      Center(
                        child: Text(
                          score == null ? '–' : '$score',
                          style: AppText.score.copyWith(color: AppColors.onDark),
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
                        style: AppText.caption.copyWith(color: AppColors.onDarkMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        score == null ? 'Skor yok' : scoreLabel(score),
                        style: AppText.title.copyWith(color: AppColors.onDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '10 üzerinden ${activityName(data.activity).toLowerCase()} uygunluğu',
                        style: AppText.caption.copyWith(color: AppColors.onDarkMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (data.nowTips.isNotEmpty) ...[
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.backpack_rounded, size: 20, color: AppColors.pine),
                        const SizedBox(width: 8),
                        Text('Bunları unutma', style: textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final tip in data.nowTips)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.seaLight,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Icon(tipIcon(tip.type), size: 17, color: AppColors.sea),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(tip.text, style: textTheme.bodyLarge),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
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
                      color: AppColors.tint(AppColors.sunset),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.wb_twilight_rounded, color: AppColors.sunset),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sıradaki en iyi zaman', style: textTheme.bodyMedium),
                        const SizedBox(height: 2),
                        data.bestStart == null
                            ? Text('Bugün için uygun saat kalmadı, yarına bak', style: textTheme.titleMedium)
                            : Text(
                                '${data.bestStart} – ${data.bestEnd}',
                                style: AppText.title,
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final warning in data.warnings)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.tint(AppColors.sunset),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.sunset),
                  const SizedBox(width: 12),
                  Expanded(child: Text(warning, style: textTheme.bodyLarge)),
                ],
              ),
            ),
          const SizedBox(height: 14),
          _HourlyChart(data: data),
        ],
      ),
    );
  }
}

class _HourlyChart extends StatelessWidget {
  final WeatherScore data;
  const _HourlyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  Text('Detay', style: AppText.label.copyWith(color: AppColors.sea)),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.sea),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 96,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final h in data.hourly)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 6 + 66 * h.score / 10,
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              decoration: BoxDecoration(
                                color: scoreColor(h.score).withValues(alpha: h.time == data.nowTime ? 1 : 0.75),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // 24 çubuk için her saati yazmak sığmıyor; 3 saatte bir etiket
                            Text(
                              int.parse(h.time.substring(0, 2)) % 3 == 0 ? h.time.substring(0, 2) : '',
                              style: AppText.caption.copyWith(
                                color: h.time == data.nowTime ? AppColors.ink : AppColors.muted,
                                fontWeight: h.time == data.nowTime ? FontWeight.w700 : FontWeight.w500,
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
