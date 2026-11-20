import 'package:flutter/material.dart';

import '../data/route_model.dart';
import '../theme/app_theme.dart';
import '../widgets/route_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _query = '';
  String? _activity; // walking, cycling
  int? _difficulty;

  bool _matches(TrailRoute r) {
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty && !r.name.toLowerCase().contains(q) && !r.region.toLowerCase().contains(q)) {
      return false;
    }
    if (_activity != null && !r.activity.contains(_activity)) return false;
    if (_difficulty != null && r.difficulty != _difficulty) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<List<TrailRoute>>(
      future: RouteRepository.load(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <TrailRoute>[];
        final routes = all.where(_matches).toList();

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverList.list(
                children: [
                  Text('Rotalar', style: textTheme.headlineLarge),
                  const SizedBox(height: 4),
                  Text('Muğla\'da ${all.length} yürüyüş ve bisiklet rotası', style: textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Rota veya ilçe ara',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _chip('Tümü', _activity == null && _difficulty == null, () {
                      setState(() {
                        _activity = null;
                        _difficulty = null;
                      });
                    }),
                    _chip('Yürüyüş', _activity == 'walking', () {
                      setState(() => _activity = _activity == 'walking' ? null : 'walking');
                    }, icon: Icons.hiking_rounded),
                    _chip('Bisiklet', _activity == 'cycling', () {
                      setState(() => _activity = _activity == 'cycling' ? null : 'cycling');
                    }, icon: Icons.directions_bike_rounded),
                    for (final d in [1, 2, 3])
                      _chip(difficultyLabel(d), _difficulty == d, () {
                        setState(() => _difficulty = _difficulty == d ? null : d);
                      }, dot: difficultyColor(d)),
                  ],
                ),
              ),
            ),
            if (snapshot.connectionState != ConnectionState.done)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (routes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48, color: AppColors.muted),
                      const SizedBox(height: 12),
                      Text('Bu filtrelere uyan rota yok', style: textTheme.titleMedium),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                sliver: SliverList.separated(
                  itemCount: routes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => RouteCard(route: routes[i]),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap, {IconData? icon, Color? dot}) {
    final fg = selected ? Colors.white : AppColors.ink;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        avatar: icon != null
            ? Icon(icon, size: 16, color: fg)
            : dot != null
                ? Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle))
                : null,
        label: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
