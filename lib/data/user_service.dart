import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../weather/weather_service.dart';

/// Backend'deki kullanıcı (POST /users cevabı).
class AppUser {
  const AppUser({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
      );
}

class UserServiceException implements Exception {
  const UserServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// /users, /users/{id}/preferences uç noktalarıyla konuşur.
class UserService {
  static String get _base => WeatherService.baseUrl;
  static const _json = {'Content-Type': 'application/json'};
  static const _timeout = Duration(seconds: 10);

  static Future<AppUser> createUser({
    required String name,
    required String email,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_base/users'),
          headers: _json,
          body: jsonEncode({'name': name, 'email': email}),
        )
        .timeout(_timeout);

    if (response.statusCode == 409) {
      throw const UserServiceException('Bu e-posta zaten kayıtlı.');
    }
    if (response.statusCode != 201) {
      throw UserServiceException(
          'Hesap oluşturulamadı (${response.statusCode}).');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    return AppUser.fromJson(body as Map<String, dynamic>);
  }

  static Future<void> updatePreferences(
    int userId,
    Map<String, dynamic> preferences,
  ) async {
    final response = await http
        .put(
          Uri.parse('$_base/users/$userId/preferences'),
          headers: _json,
          body: jsonEncode({'preferences': preferences}),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw UserServiceException(
          'Tercihler kaydedilemedi (${response.statusCode}).');
    }
  }
}

/// Onboarding'de girilen bilgiler. [userId] backend'e ulaşılamadan devam edildiyse null.
class SessionData {
  const SessionData({this.userId, required this.name, required this.email, required this.activity});

  final int? userId;
  final String name;
  final String email;

  /// 'Bisiklet', 'Yürüyüş' veya 'İkisi de' (Bugün ekranındaki seçimle aynı)
  final String activity;
}

/// Cihazda tutulan oturum bilgisi: onboarding bitti mi, kullanıcı kim.
class Session {
  static const _kOnboarded = 'onboarding_done';
  static const _kUserId = 'user_id';
  static const _kName = 'name';
  static const _kEmail = 'email';
  static const _kActivity = 'activity';

  /// Ekranlar bunu dinler; giriş/çıkışta kendiliğinden güncellenir.
  static final current = ValueNotifier<SessionData?>(null);

  /// Uygulama açılırken bir kez çağrılır. Onboarding tamamlandıysa true döner.
  static Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_kOnboarded) ?? false)) return false;
    current.value = SessionData(
      userId: prefs.getInt(_kUserId),
      name: prefs.getString(_kName) ?? '',
      email: prefs.getString(_kEmail) ?? '',
      activity: prefs.getString(_kActivity) ?? 'Bisiklet',
    );
    return true;
  }

  static Future<void> save(SessionData data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data.userId != null) {
      await prefs.setInt(_kUserId, data.userId!);
    } else {
      await prefs.remove(_kUserId);
    }
    await prefs.setString(_kName, data.name);
    await prefs.setString(_kEmail, data.email);
    await prefs.setString(_kActivity, data.activity);
    await prefs.setBool(_kOnboarded, true);
    current.value = data;
  }

  /// Çıkış: cihazdaki bilgileri siler. Backend'deki kullanıcı kaydı silinmez.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    for (final k in [_kOnboarded, _kUserId, _kName, _kEmail, _kActivity]) {
      await prefs.remove(k);
    }
    current.value = null;
  }
}
