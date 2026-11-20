import 'package:geolocator/geolocator.dart';

import 'weather_service.dart';

class PlaceLocation {
  final double lat;
  final double lon;
  final String name;
  const PlaceLocation(this.lat, this.lon, this.name);
}

const mugla = PlaceLocation(WeatherService.muglaLat, WeatherService.muglaLon, 'Muğla merkez');

/// Muğla ilinin kabaca sınırları; dışındaysa Muğla merkezi kullanılır.
bool inMugla(double lat, double lon) =>
    lat >= 36.3 && lat <= 37.7 && lon >= 27.2 && lon <= 29.5;

/// Konum izni varsa cihaz konumu, yoksa / hata olursa / il dışındaysa Muğla merkez.
Future<PlaceLocation> currentOrMugla() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return mugla;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return mugla;
    }
    final pos = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 8));
    if (!inMugla(pos.latitude, pos.longitude)) return mugla;
    return PlaceLocation(pos.latitude, pos.longitude, 'Konumun');
  } catch (_) {
    return mugla;
  }
}
