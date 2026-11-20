import 'package:flutter/material.dart';

import '../data/route_model.dart';
import '../data/user_service.dart';
import '../theme/app_theme.dart';
import '../weather/weather_screen.dart';
import '../widgets/route_card.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({
    super.key,
    required this.selectedActivity,
    required this.onActivitySelected,
    required this.onSeeAllRoutes,
  });

  final String selectedActivity;
  final ValueChanged<String> onActivitySelected;
  final VoidCallback onSeeAllRoutes;

  static const _activities = [
    ('Bisiklet', Icons.directions_bike_rounded),
    ('Yürüyüş', Icons.hiking_rounded),
    ('İkisi de', Icons.all_inclusive_rounded),
  ];

  bool _matches(TrailRoute r) => switch (selectedActivity) {
        'Bisiklet' => r.isCycling,
        'Yürüyüş' => r.isWalking,
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<SessionData?>(
                    valueListenable: Session.current,
                    builder: (context, session, _) {
                      final name = session?.name.split(' ').first ?? '';
                      return Text(name.isEmpty ? 'Merhaba 👋' : 'Merhaba, $name 👋', style: textTheme.bodyMedium);
                    },
                  ),
                  Text('Patikanos', style: textTheme.headlineSmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.line),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.place_rounded, size: 16, color: AppColors.sea),
                  SizedBox(width: 4),
                  Text('Muğla', style: AppText.label),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _HeroCard(),
        const SizedBox(height: 24),
        Text('Ne yapmak istersiniz?', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final (label, icon) in _activities) ...[
              if (label != _activities.first.$1) const SizedBox(width: 10),
              Expanded(
                child: _ActivityOption(
                  label: label,
                  icon: icon,
                  selected: label == selectedActivity,
                  onTap: () => onActivitySelected(label),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WeatherScreen(
                activity: selectedActivity == 'Yürüyüş'
                    ? 'walk'
                    : (selectedActivity == 'İkisi de' ? 'both' : 'bike'),
              ),
            ),
          ),
          icon: const Icon(Icons.wb_twilight_rounded),
          label: const Text('Devam'),
        ),
        const SizedBox(height: 28),
        SectionHeader(title: 'Öne çıkan rotalar', action: 'Tümünü gör', onAction: onSeeAllRoutes),
        const SizedBox(height: 8),
        FutureBuilder<List<TrailRoute>>(
          future: RouteRepository.load(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final featured = snapshot.data!.where(_matches).take(3).toList();
            return Column(
              children: [
                for (final r in featured)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RouteCard(route: r),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          // Gün batımı güneşi ve dağ silüetleri
          Positioned(
            right: 34,
            top: 26,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.sunsetLight, AppColors.sunset],
                ),
                boxShadow: [BoxShadow(color: AppColors.sunset.withValues(alpha: 0.5), blurRadius: 30)],
              ),
            ),
          ),
          Positioned(
            right: -40,
            bottom: -70,
            child: Icon(Icons.landscape_rounded, size: 230, color: AppColors.glass),
          ),
          Positioned(
            right: 70,
            bottom: -50,
            child: Icon(Icons.forest_rounded, size: 120, color: AppColors.glass),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 92, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 240,
                  child: Text.rich(
                    TextSpan(
                      style: AppText.hero.copyWith(color: AppColors.onDark),
                      children: const [
                        TextSpan(text: 'Bugün hangi rota, '),
                        TextSpan(text: 'hangi saatte?', style: TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 250,
                  child: Text(
                    'Hava durumuna göre bisiklet ve yürüyüş için en uygun zamanı gösteririz.',
                    style: AppText.bodyMuted.copyWith(color: AppColors.onDarkMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityOption extends StatelessWidget {
  const _ActivityOption({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.pine : AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? AppColors.pine : AppColors.line),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? AppColors.onDark : AppColors.pine, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppText.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.onDark : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
