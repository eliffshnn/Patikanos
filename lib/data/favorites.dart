import 'package:flutter/foundation.dart';

/// Favori rota ID'leri. Şimdilik uygulama içinde tutuluyor; backend'deki
/// /users/{id}/favorites uç noktasına giriş ekranı gelince bağlanacak.
class Favorites {
  static final ids = ValueNotifier<Set<String>>({});

  static bool contains(String id) => ids.value.contains(id);

  static void toggle(String id) {
    final next = {...ids.value};
    if (!next.remove(id)) next.add(id);
    ids.value = next;
  }
}
