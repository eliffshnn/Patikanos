import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Haritada gösterilecek tek bir rota başlangıç noktası.
class _RoutePin {
  _RoutePin({
    required this.name,
    required this.region,
    required this.isCycling,
    required this.distanceKm,
    required this.point,
  });

  final String name;
  final String region;
  final bool isCycling;
  final double distanceKm;
  final LatLng point;
}

/// Harita ekranı (#34): Muğla haritası, 16 rotanın başlangıç noktaları
/// ve OpenStreetMap atfı (#35). Rotalar docs/routes.geojson dosyasından okunur.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Muğla ilinin yaklaşık ortası
  static const LatLng _muglaCenter = LatLng(37.0, 28.3);

  late final Future<List<_RoutePin>> _pinsFuture = _loadPins();

  Future<List<_RoutePin>> _loadPins() async {
    final raw = await rootBundle.loadString('docs/routes.geojson');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>;

    final pins = <_RoutePin>[];
    for (final f in features) {
      final p = (f as Map<String, dynamic>)['properties'] as Map<String, dynamic>;
      final start = p['start'] as List<dynamic>?; // [boylam, enlem]
      if (start == null || start.length < 2) continue;
      final activity = (p['activity'] as List<dynamic>? ?? []).cast<String>();
      pins.add(_RoutePin(
        name: p['name'] as String? ?? '',
        region: p['region'] as String? ?? '',
        isCycling: activity.contains('cycling'),
        distanceKm: (p['distance_km'] as num?)?.toDouble() ?? 0,
        point: LatLng(
          (start[1] as num).toDouble(),
          (start[0] as num).toDouble(),
        ),
      ));
    }
    return pins;
  }

  void _showPin(_RoutePin pin) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pin.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '${pin.region} • ${pin.isCycling ? 'Bisiklet' : 'Yürüyüş'} • '
              '${pin.distanceKm.toStringAsFixed(1)} km',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_RoutePin>>(
      future: _pinsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Rotalar yüklenemedi: ${snapshot.error}'));
        }
        final pins = snapshot.data ?? [];

        return FlutterMap(
          options: const MapOptions(
            initialCenter: _muglaCenter,
            initialZoom: 8.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.patikanos',
            ),
            MarkerLayer(
              markers: [
                for (final pin in pins)
                  Marker(
                    point: pin.point,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showPin(pin),
                      child: Icon(
                        pin.isCycling ? Icons.directions_bike : Icons.hiking,
                        size: 32,
                        color: pin.isCycling
                            ? const Color(0xFF1D5FA8)
                            : const Color(0xFF1D7A68),
                      ),
                    ),
                  ),
              ],
            ),
            // #35: OpenStreetMap atfı
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                color: Colors.white70,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: const Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
