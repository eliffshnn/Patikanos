import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/route_model.dart';
import '../data/user_service.dart';
import '../theme/app_theme.dart';
import '../weather/weather_screen.dart';
import '../widgets/nature.dart';
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
    // Fotoğraf durum çubuğunun altına uzandığı için saat ve pil simgeleri beyaz
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          const _Hero(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Bugün ne yapmak istersin?', style: AppText.section),
                const SizedBox(height: 12),
                _ActivityPicker(
                  activities: _activities,
                  selected: selectedActivity,
                  onChanged: onActivitySelected,
                ),
                const SizedBox(height: 16),
                PillButton(
                  label: 'Devam',
                  expand: true,
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
                ),
                const SizedBox(height: 30),
                SectionHeader(title: 'Öne çıkan rotalar', action: 'Tümünü gör', onAction: onSeeAllRoutes),
              ],
            ),
          ),
          const SizedBox(height: 6),
          FutureBuilder<List<TrailRoute>>(
            future: RouteRepository.load(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final featured = snapshot.data!.where(_matches).take(5).toList();
              // Sabit yükseklik yerine kartlar içeriğe göre boylanır (büyük yazı ayarında taşmaz);
              // hepsi en uzun kartla aynı boyda durur.
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final r in featured) ...[
                        if (r != featured.first) const SizedBox(width: 12),
                        SizedBox(width: 290, child: RouteCard(route: r)),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return PhotoHeader(
      image: AppImages.coast,
      alignment: const Alignment(0, -0.1),
      height: 400 + top,
      child: Padding(
        padding: EdgeInsets.fromLTRB(22, top + 12, 22, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Patikanos', style: AppText.section.copyWith(color: AppColors.onDark)),
                const Spacer(),
                const GlassPill(icon: Icons.place_rounded, label: 'Muğla'),
              ],
            ),
            const Spacer(),
            ValueListenableBuilder<SessionData?>(
              valueListenable: Session.current,
              builder: (context, session, _) {
                final name = session?.name.split(' ').first ?? '';
                return Text(
                  name.isEmpty ? 'MERHABA 👋' : 'MERHABA, ${name.toUpperCase()} 👋',
                  style: AppText.eyebrow.copyWith(color: AppColors.onDarkMuted),
                );
              },
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: AppText.hero.copyWith(color: AppColors.onDark),
                children: const [
                  TextSpan(text: 'Bugün hangi rota, '),
                  TextSpan(text: 'hangi saatte?', style: TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hava durumuna göre bisiklet ve yürüyüş için en uygun zamanı gösteririz.',
              style: AppText.bodyMuted.copyWith(color: AppColors.onDarkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Onboarding'deki yuvarlak seçicinin açık zemin hali
class _ActivityPicker extends StatelessWidget {
  const _ActivityPicker({required this.activities, required this.selected, required this.onChanged});

  final List<(String, IconData)> activities;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          for (final (label, icon) in activities)
            Expanded(
              child: Semantics(
                button: true,
                selected: label == selected,
                child: GestureDetector(
                  onTap: () => onChanged(label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      color: label == selected ? AppColors.pine : AppColors.surface,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 18, color: label == selected ? AppColors.onDark : AppColors.pine),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.label.copyWith(
                              color: label == selected ? AppColors.onDark : AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
