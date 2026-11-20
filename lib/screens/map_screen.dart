import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/route_model.dart';
import '../theme/app_theme.dart';
import '../widgets/route_card.dart';
import 'route_detail_screen.dart';

/// Harita ekranı (#34): Muğla haritası, 16 rotanın başlangıç noktaları
/// ve OpenStreetMap atfı (#35). Rotalar RouteRepository'den okunur.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  LatLng _start(TrailRoute r) => LatLng(r.startLat, r.startLon);

  void _showRoute(BuildContext context, TrailRoute route) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                RouteThumb(route: route, size: 64),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 13, color: AppColors.sea),
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
                      Text(route.name, style: Theme.of(sheetContext).textTheme.titleMedium),
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
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RouteDetailScreen(route: route)),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Rota detayını aç'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TrailRoute>>(
      future: RouteRepository.load(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Rotalar yüklenemedi: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final routes = snapshot.data!;

        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                // Bütün başlangıç noktaları ekrana sığacak şekilde açılır.
                initialCameraFit: CameraFit.coordinates(
                  coordinates: routes.map(_start).toList(),
                  padding: const EdgeInsets.fromLTRB(40, 110, 40, 40),
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.patikanos',
                ),
                _ClusteredMarkers(
                  routes: routes,
                  pointOf: _start,
                  onRouteTap: (r) => _showRoute(context, r),
                ),
                // #35: OpenStreetMap atfı
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '© OpenStreetMap contributors',
                      style: TextStyle(fontSize: 11, color: AppColors.ink),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 12,
              child: _MapHeader(count: routes.length),
            ),
          ],
        );
      },
    );
  }
}

/// Ekranda birbirine çok yakın düşen başlangıç noktalarını tek bir sayı balonunda toplar.
/// Kamera değiştikçe (yakınlaştırma) yeniden hesaplanır; balona dokununca o rotalara yakınlaşır.
class _ClusteredMarkers extends StatelessWidget {
  const _ClusteredMarkers({required this.routes, required this.pointOf, required this.onRouteTap});

  final List<TrailRoute> routes;
  final LatLng Function(TrailRoute) pointOf;
  final ValueChanged<TrailRoute> onRouteTap;

  static const _markerSize = 36.0;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);

    // Basit açgözlü gruplama: her rota, ekranda işaret boyundan yakın olduğu ilk gruba girer.
    final clusters = <List<TrailRoute>>[];
    final centers = <Offset>[];
    for (final r in routes) {
      final p = camera.projectAtZoom(pointOf(r));
      final i = centers.indexWhere((c) => (c - p).distance < _markerSize);
      if (i == -1) {
        clusters.add([r]);
        centers.add(p);
      } else {
        clusters[i].add(r);
      }
    }

    return MarkerLayer(
      markers: [
        for (final group in clusters)
          if (group.length == 1)
            Marker(
              point: pointOf(group.single),
              width: _markerSize,
              height: _markerSize,
              child: _RouteMarker(route: group.single, onTap: () => onRouteTap(group.single)),
            )
          else
            Marker(
              point: _average(group.map(pointOf)),
              width: _markerSize + 4,
              height: _markerSize + 4,
              child: _ClusterMarker(
                count: group.length,
                onTap: () => MapController.of(context).fitCamera(
                  CameraFit.coordinates(
                    coordinates: group.map(pointOf).toList(),
                    padding: const EdgeInsets.all(120),
                    maxZoom: 14,
                  ),
                ),
              ),
            ),
      ],
    );
  }

  static LatLng _average(Iterable<LatLng> points) {
    var lat = 0.0, lon = 0.0;
    for (final p in points) {
      lat += p.latitude;
      lon += p.longitude;
    }
    return LatLng(lat / points.length, lon / points.length);
  }
}

class _ClusterMarker extends StatelessWidget {
  const _ClusterMarker({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.sunset,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Text(
          '$count',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }
}

class _RouteMarker extends StatelessWidget {
  const _RouteMarker({required this.route, required this.onTap});

  final TrailRoute route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cycling = route.isCycling && !route.isWalking;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cycling ? AppColors.sea : AppColors.pine,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Icon(
          cycling ? Icons.directions_bike_rounded : Icons.hiking_rounded,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Harita', style: Theme.of(context).textTheme.titleLarge),
                Text('Muğla\'da $count rota', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const _LegendDot(color: AppColors.pine, label: 'Yürüyüş'),
          const SizedBox(width: 12),
          const _LegendDot(color: AppColors.sea, label: 'Bisiklet'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
      ],
    );
  }
}
