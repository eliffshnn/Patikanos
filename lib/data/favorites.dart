import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api/api_config.dart';
import '../api/user_session.dart';

/// Favori rota ID'leri. Ekranlar [ids]'i dinler; değişiklikler backend'e
/// (/users/{id}/favorites) yazılır. Sunucuya ulaşılamazsa değişiklik geri alınır.
class Favorites {
  static final ids = ValueNotifier<Set<String>>({});
  static const _timeout = Duration(seconds: 10);

  static bool contains(String id) => ids.value.contains(id);

  /// Uygulama açılışında favorileri backend'den çeker.
  static Future<void> load() async {
    try {
      var response = await _get();
      if (response.statusCode == 404) {
        // Kayıtlı kullanıcı sunucuda yok (veritabanı sıfırlanmış): yenisini aç
        await UserSession.reset();
        response = await _get();
      }
      if (response.statusCode != 200) return;

      final body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final features = body['features'] as List<dynamic>;
      ids.value = {
        for (final f in features)
          (f['properties'] as Map<String, dynamic>)['id'] as String,
      };
    } catch (e) {
      debugPrint('Favoriler yüklenemedi: $e');
    }
  }

  static Future<void> toggle(String id) async {
    final wasFav = contains(id);
    _set(id, !wasFav); // ekranda hemen değişsin

    try {
      final userId = await UserSession.userId();
      final base = '${ApiConfig.baseUrl}/users/$userId/favorites';

      final response = wasFav
          ? await http.delete(Uri.parse('$base/$id')).timeout(_timeout)
          : await http
              .post(
                Uri.parse(base),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'route_id': id}),
              )
              .timeout(_timeout);

      // 409 = zaten favoride, silerken 404 = zaten yok: sonuç aynı, sorun değil
      final ok = response.statusCode == 201 ||
          response.statusCode == 204 ||
          response.statusCode == 409 ||
          (wasFav && response.statusCode == 404);
      if (!ok) throw Exception('HTTP ${response.statusCode}');
    } catch (e) {
      _set(id, wasFav); // kaydedilemedi: geri al
      debugPrint('Favori kaydedilemedi: $e');
    }
  }

  static Future<http.Response> _get() async {
    final userId = await UserSession.userId();
    return http
        .get(Uri.parse('${ApiConfig.baseUrl}/users/$userId/favorites'))
        .timeout(_timeout);
  }

  static void _set(String id, bool favorite) {
    final next = {...ids.value};
    if (favorite) {
      next.add(id);
    } else {
      next.remove(id);
    }
    ids.value = next;
  }
}