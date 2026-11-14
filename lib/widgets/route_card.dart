import 'package:flutter/material.dart';

import '../data/favorites.dart';
import '../data/route_model.dart';
import '../screens/route_detail_screen.dart';
import '../theme/app_theme.dart';

/// Rotanın aktivitesine göre küçük resim yerine kullanılan renkli kutu.
class RouteThumb extends StatelessWidget {
  const RouteThumb({super.key, required this.route, this.size = 72});

  final TrailRoute route;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cycling = route.isCycling && !route.isWalking;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cycling
              ? const [AppColors.sea, Color(0xFF3FA7B5)]
              : const [AppColors.pineDark, AppColors.pine],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -size * 0.15,
            bottom: -size * 0.2,
            child: Icon(Icons.landscape_rounded, size: size * 0.9, color: Colors.white.withValues(alpha: 0.15)),
          ),
          Center(
            child: Icon(
              cycling ? Icons.directions_bike_rounded : Icons.hiking_rounded,
              color: Colors.white,
              size: size * 0.42,
            ),
          ),
        ],
      ),
    );
  }
}

class DifficultyPill extends StatelessWidget {
  const DifficultyPill({super.key, required this.difficulty});

  final int difficulty;

  @override
  Widget build(BuildContext context) {
    final color = difficultyColor(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        difficultyLabel(difficulty),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.muted),
        const SizedBox(width: 3),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class RouteCard extends StatelessWidget {
  const RouteCard({super.key, required this.route});

  final TrailRoute route;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RouteDetailScreen(route: route)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              RouteThumb(route: route),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 13, color: AppColors.sea),
                        const SizedBox(width: 2),
                        Text(
                          route.region,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.sea),
                        ),
                        const SizedBox(width: 8),
                        DifficultyPill(difficulty: route.difficulty),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      route.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        InfoChip(icon: Icons.straighten_rounded, label: '${route.distanceKm.toStringAsFixed(1)} km'),
                        InfoChip(icon: Icons.trending_up_rounded, label: '${route.elevationGainM} m'),
                        InfoChip(icon: Icons.schedule_rounded, label: formatDuration(route.durationMin)),
                      ],
                    ),
                  ],
                ),
              ),
              FavoriteButton(routeId: route.id),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.routeId, this.color = AppColors.muted});

  final String routeId;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: Favorites.ids,
      builder: (context, ids, _) {
        final fav = ids.contains(routeId);
        return IconButton(
          tooltip: fav ? 'Favorilerden çıkar' : 'Favorilere ekle',
          onPressed: () => Favorites.toggle(routeId),
          icon: Icon(
            fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: fav ? AppColors.sunset : color,
          ),
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: AppColors.sea),
            child: Text(action!),
          ),
      ],
    );
  }
}
