// Uygulamayı ekran ekran dolaşıp rapor için ekran görüntüsü alır.
// Backend açıkken (docker compose up) şu komutla çalıştırın:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshots_test.dart -d <cihaz>
// Görüntüler docs/screenshots/ klasörüne yazılır.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:patikanos/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Rota kartlarındaki haritalar yüklenirken ekran hiç "durmaz"; pumpAndSettle yerine sabit süre bekle.
  Future<void> wait(WidgetTester tester, [int quarterSeconds = 8]) async {
    for (var i = 0; i < quarterSeconds; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  Future<void> shot(String name) => binding.takeScreenshot(name);

  testWidgets('screens for the report', (tester) async {
    (await SharedPreferences.getInstance()).clear();

    await tester.pumpWidget(const MyApp(onboarded: false));
    await wait(tester);
    await shot('01_onboarding_1');
    await tester.tap(find.text('Başlayalım'));
    await wait(tester);
    await shot('02_onboarding_2');
    await tester.tap(find.text('Devam'));
    await wait(tester);
    await shot('03_onboarding_3');

    await tester.pumpWidget(const MyApp());
    await wait(tester, 16);
    await shot('04_bugun');

    await tester.tap(find.text('İkisi de'));
    await wait(tester, 2);
    await tester.tap(find.text('Devam'));
    await wait(tester, 16);
    await shot('05_hava_durumu');

    await tester.tap(find.text('Saatlik skor').first);
    await wait(tester);
    await shot('06_saatlik_detay');
    await tester.pageBack();
    await wait(tester, 4);
    await tester.pageBack();
    await wait(tester, 4);

    await tester.tap(find.text('Keşfet'));
    await wait(tester, 16);
    await shot('07_kesfet');

    await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
    await wait(tester, 2);
    await tester.tap(find.byType(Card).first);
    await wait(tester, 16);
    await shot('08_rota_detayi');
    await tester.pageBack();
    await wait(tester, 4);

    await tester.tap(find.text('Harita'));
    await wait(tester, 20);
    await shot('09_harita');

    await tester.tap(find.text('Favoriler'));
    await wait(tester, 12);
    await shot('10_favoriler');

    await tester.tap(find.text('Profil'));
    await wait(tester, 4);
    await shot('11_profil');

    (await SharedPreferences.getInstance()).clear();
  });
}
