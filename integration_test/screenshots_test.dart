// Uygulamayı ekran ekran dolaşıp rapor için ekran görüntüsü alır.
// Backend açıkken (docker compose up) şu komutla çalıştırın:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshots_test.dart -d <cihaz>
// Görüntüler docs/screenshots/ klasörüne yazılır.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:patikanos/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Hava durumu yüklenirken dönen gösterge pumpAndSettle'ı bitirmez; yükleme bitene kadar bekler.
  Future<void> waitForLoading(WidgetTester tester) async {
    // Skor halkası da bir CircularProgressIndicator ama değeri dolu; sadece değersiz (dönen) olanı bekliyoruz.
    final spinner = find.byWidgetPredicate((w) => w is CircularProgressIndicator && w.value == null);
    for (var i = 0; i < 60 && spinner.evaluate().isNotEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await tester.pumpAndSettle();
  }

  Future<void> shot(String name) => binding.takeScreenshot(name);

  testWidgets('screens for the report', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await shot('01_bugun');

    await tester.tap(find.text('İkisi de'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Devam'));
    await waitForLoading(tester);
    await shot('02_hava_durumu');

    await tester.tap(find.text('Saatlik skor').first);
    await tester.pumpAndSettle();
    await shot('03_saatlik_detay');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keşfet'));
    await tester.pumpAndSettle();
    await shot('04_kesfet');

    await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle();
    await shot('05_rota_detayi');
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favoriler'));
    await tester.pumpAndSettle();
    await shot('06_favoriler');

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await shot('07_profil');

    await tester.tap(find.text('Harita'));
    // Harita parçaları OpenStreetMap'ten iniyor; birkaç saniye bekle.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await shot('08_harita');
  });
}
