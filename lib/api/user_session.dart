import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

/// Giriş ekranı gelene kadar her cihaz için anonim bir "Misafir" kullanıcı.
class UserSession {
  static const _key = 'user_id';
  static Future<int>? _future;

  /// Kullanıcı id'si. Aynı anda birden çok yerden çağrılsa da tek kullanıcı oluşturur.
  static Future<int> userId() => _future ??= _load();

  /// Sunucuda kullanıcı bulunamazsa (ör. veritabanı sıfırlandı) çağrılır.
  static Future<void> reset() async {
    _future = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<int> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt(_key);
      if (saved != null) return saved;

      final id = await _createGuest();
      await prefs.setInt(_key, id);
      return id;
    } catch (_) {
      _future = null; // hata olursa bir sonraki çağrıda tekrar denesin
      rethrow;
    }
  }

  static Future<int> _createGuest() async {
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/users'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': 'Misafir',
            'email': 'guest-$stamp@patikanos.local',
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 201) {
      throw Exception('Kullanıcı oluşturulamadı (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['id'] as int;
  }
}