import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/route_model.dart';
import '../theme/app_theme.dart';
import '../weather/weather_screen.dart';
import '../widgets/route_card.dart';

class RouteDetailScreen extends StatelessWidget {
  const RouteDetailScreen({super.key, required this.route});

  final TrailRoute route;

  @override
  Widget build(BuildContext context) {
    final cycling = route.isCycling && !route.isWalking;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 240,
            backgroundColor: AppColors.pineDark,
            foregroundColor: Colors.white,
            actions: [FavoriteButton(routeId: route.id, color: Colors.white)],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      bottom: -40,
                      child: Icon(Icons.landscape_rounded, size: 260, color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _HeroTag(
                                icon: cycling ? Icons.directions_bike_rounded : Icons.hiking_rounded,
                                label: cycling ? 'Bisiklet' : 'Yürüyüş',
                              ),
                              const SizedBox(width: 8),
                              _HeroTag(icon: Icons.place_rounded, label: '${route.region}, Muğla'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            route.name,
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, height: 1.15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList.list(
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.1,
                  children: [
                    _StatTile(icon: Icons.straighten_rounded, label: 'Mesafe', value: '${route.distanceKm.toStringAsFixed(1)} km'),
                    _StatTile(icon: Icons.trending_up_rounded, label: 'Tırmanış', value: '${route.elevationGainM} m'),
                    _StatTile(icon: Icons.schedule_rounded, label: 'Tahmini süre', value: formatDuration(route.durationMin)),
                    _StatTile(
                      icon: Icons.terrain_rounded,
                      label: 'Zorluk',
                      value: difficultyLabel(route.difficulty),
                      valueColor: difficultyColor(route.difficulty),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.seaLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny_rounded, color: AppColors.sea),
                          const SizedBox(width: 8),
                          Text('Ne zaman gitmeli?', style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rotanın başlangıç noktası için saatlik hava skorunu ve günün en iyi zamanını gör.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WeatherScreen(
                              lat: route.startLat,
                              lon: route.startLon,
                              placeName: route.region,
                              initialActivity: route.weatherActivity,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.cloud_outlined),
                        label: const Text('Hava durumuna bak'),
                      ),
                    ],
                  ),
                ),
                if (route.warnings.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('Uyarılar', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  for (final w in route.warnings)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.warning_amber_rounded, color: AppColors.sunset),
                      title: Text(w),
                    ),
                ],
                const SizedBox(height: 20),
                Text('Başlangıç noktası', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.flag_rounded, color: AppColors.pine),
                    title: Text('${route.startLat.toStringAsFixed(5)}, ${route.startLon.toStringAsFixed(5)}'),
                    subtitle: const Text('Kopyalamak için dokun'),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: '${route.startLat}, ${route.startLon}'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Koordinat kopyalandı')),
                      );
                    },
                  ),
                ),
                if (route.sourceUrl != null) ...[
                  const SizedBox(height: 16),
                  Text('Kaynak: Wikiloc', style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value, this.valueColor = AppColors.ink});

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.sea),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  value,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: valueColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
