import 'package:flutter/material.dart';

import '../data/favorites.dart';
import '../data/route_model.dart';
import '../screens/route_detail_screen.dart';
import '../theme/app_theme.dart';
import 'nature.dart';

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
              ? const [AppColors.sea, AppColors.seaBright]
              : const [AppColors.pineDark, AppColors.pine],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -size * 0.15,
            bottom: -size * 0.2,
            child: Icon(Icons.landscape_rounded, size: size * 0.9, color: AppColors.glass),
          ),
          Center(
            child: Icon(
              cycling ? Icons.directions_bike_rounded : Icons.hiking_rounded,
              color: AppColors.onDark,
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
        color: AppColors.tint(color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        difficultyLabel(difficulty),
        style: AppText.eyebrow.copyWith(color: color, letterSpacing: 0.4),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 132,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RouteMapPreview(route: route),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: _ActivityTag(route: route),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                      child: FavoriteButton(routeId: route.id),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(route.region.toUpperCase(), style: AppText.eyebrow.copyWith(color: AppColors.sea)),
                      const SizedBox(width: 8),
                      DifficultyPill(difficulty: route.difficulty),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    route.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.section,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 14,
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
          ],
        ),
      ),
    );
  }
}

/// Haritanın üzerinde "Yürüyüş" / "Bisiklet" etiketi
class _ActivityTag extends StatelessWidget {
  const _ActivityTag({required this.route});

  final TrailRoute route;

  @override
  Widget build(BuildContext context) {
    final cycling = route.isCycling && !route.isWalking;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cycling ? AppColors.sea : AppColors.pine,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppShadows.raised,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cycling ? Icons.directions_bike_rounded : Icons.hiking_rounded, size: 14, color: AppColors.onDark),
          const SizedBox(width: 4),
          Text(cycling ? 'Bisiklet' : 'Yürüyüş', style: AppText.label.copyWith(color: AppColors.onDark)),
        ],
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
