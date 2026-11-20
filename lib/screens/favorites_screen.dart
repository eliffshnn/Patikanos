import 'package:flutter/material.dart';

import '../data/favorites.dart';
import '../data/route_model.dart';
import '../theme/app_theme.dart';
import '../widgets/route_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<List<TrailRoute>>(
      future: RouteRepository.load(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <TrailRoute>[];
        return ValueListenableBuilder<Set<String>>(
          valueListenable: Favorites.ids,
          builder: (context, ids, _) {
            final favorites = all.where((r) => ids.contains(r.id)).toList();
            final totalKm = favorites.fold<double>(0, (sum, r) => sum + r.distanceKm);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text('Favoriler', style: textTheme.headlineLarge),
                const SizedBox(height: 4),
                Text(
                  favorites.isEmpty
                      ? 'Beğendiğin rotaları burada topla'
                      : '${favorites.length} rota · toplam ${totalKm.toStringAsFixed(1)} km',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                if (favorites.isEmpty)
                  _EmptyState(onExplore: onExplore)
                else
                  for (final r in favorites)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RouteCard(route: r),
                    ),
              ],
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.tint(AppColors.sunset),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_rounded, size: 42, color: AppColors.sunset),
          ),
          const SizedBox(height: 18),
          Text('Henüz favori rotan yok', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Rota kartlarındaki kalbe dokunarak sevdiğin parkurları buraya ekleyebilirsin.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: onExplore,
            icon: const Icon(Icons.explore_rounded),
            label: const Text('Rotaları keşfet'),
          ),
        ],
      ),
    );
  }
}
