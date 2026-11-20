import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/route_model.dart';
import '../theme/app_theme.dart';

/// Onboarding'deki oklu, tam yuvarlak buton. [onPhoto] fotoğraf üzerinde krem, değilse çam yeşili.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.onPhoto = false,
    this.loading = false,
    this.expand = false,
    this.icon = Icons.arrow_forward_rounded,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool onPhoto;
  final bool loading;
  final bool expand;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bg = onPhoto ? AppColors.sand : AppColors.pine;
    final fg = onPhoto ? AppColors.pineDark : AppColors.onDark;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: onPhoto ? AppColors.sandDark : AppColors.tint(AppColors.pine),
        minimumSize: expand ? const Size.fromHeight(54) : const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const StadiumBorder(),
        textStyle: AppText.button,
      ),
      child: loading
          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label),
                const SizedBox(width: 8),
                Icon(icon, size: 18),
              ],
            ),
    );
  }
}

/// Tam genişlikte fotoğraf + okunabilirlik için koyu yeşil geçiş; içerik fotoğrafın altına hizalanır.
class PhotoHeader extends StatelessWidget {
  const PhotoHeader({
    super.key,
    required this.image,
    required this.child,
    this.height = 380,
    this.alignment = Alignment.center,
    this.bottomRadius = 32,
  });

  final String image;
  final Widget child;
  final double height;
  final Alignment alignment;
  final double bottomRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(bottomRadius)),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover, alignment: alignment),
            const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.photoScrim)),
            child,
          ],
        ),
      ),
    );
  }
}

/// Fotoğraf üzerindeki küçük buzlu cam etiket ("📍 Muğla").
class GlassPill extends StatelessWidget {
  const GlassPill({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.onDark),
          const SizedBox(width: 5),
          Text(label, style: AppText.label.copyWith(color: AppColors.onDark)),
        ],
      ),
    );
  }
}

/// Rotanın başlangıç noktasının gerçek haritası (OpenStreetMap). Rotaya ait fotoğraf olmadığından
/// kartlarda temsili fotoğraf yerine bu kullanılır. Harita yüklenemezse renkli zemin görünür.
class RouteMapPreview extends StatelessWidget {
  const RouteMapPreview({super.key, required this.route, this.zoom = 12.5, this.showMarker = true});

  final TrailRoute route;
  final double zoom;
  final bool showMarker;

  /// Widget testlerinde ağ olmadığı için kapatılır; harita yerine düz zemin çizilir.
  static bool enabled = true;

  @override
  Widget build(BuildContext context) {
    final cycling = route.isCycling && !route.isWalking;
    final point = LatLng(route.startLat, route.startLon);
    return ColoredBox(
      color: AppColors.seaLight,
      child: !enabled
          ? null
          : IgnorePointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: zoom,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.patikanos',
                    tileDisplay: const TileDisplay.instantaneous(),
                  ),
                  if (showMarker)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 26,
                          height: 26,
                          child: Container(
                            decoration: BoxDecoration(
                              color: cycling ? AppColors.sea : AppColors.pine,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.onDark, width: 2),
                              boxShadow: AppShadows.raised,
                            ),
                            child: Icon(
                              cycling ? Icons.directions_bike_rounded : Icons.hiking_rounded,
                              size: 13,
                              color: AppColors.onDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
