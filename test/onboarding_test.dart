import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:patikanos/data/user_service.dart';
import 'package:patikanos/main.dart';
import 'package:patikanos/widgets/nature.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Session.current.value = null;
    RouteMapPreview.enabled = false; // testte ağ yok
  });

  Future<void> pumpOnboarding(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp(onboarded: false));
    await tester.pumpAndSettle();
  }

  testWidgets('Walks through the pages and validates the form', (tester) async {
    await pumpOnboarding(tester);

    expect(find.textContaining('patika patika'), findsOneWidget);
    await tester.tap(find.text('Başlayalım'));
    await tester.pumpAndSettle();

    expect(find.text('AKILLI ZAMANLAMA'), findsOneWidget);
    await tester.tap(find.text('Devam'));
    await tester.pumpAndSettle();

    expect(find.text('NE YAPMAYI SEVERSİN?'), findsOneWidget);
    await tester.tap(find.text('Keşfetmeye başla'));
    await tester.pumpAndSettle();
    expect(find.text('Adını yazar mısın?'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Tuba');
    await tester.enterText(find.byType(TextField).last, 'mail-degil');
    await tester.tap(find.text('Keşfetmeye başla'));
    await tester.pumpAndSettle();
    expect(find.text('Geçerli bir e-posta adresi gir.'), findsOneWidget);
  });

  testWidgets('Atla jumps straight to the setup page', (tester) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text('Atla'));
    await tester.pumpAndSettle();
    expect(find.text('NE YAPMAYI SEVERSİN?'), findsOneWidget);
  });

  testWidgets('A saved session opens the app with the user name and activity', (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'name': 'Tuba Arpaçay',
      'email': 'tuba@example.com',
      'activity': 'Yürüyüş',
    });
    final onboarded = await Session.load();
    expect(onboarded, isTrue);

    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MyApp(onboarded: onboarded));
    await tester.pumpAndSettle();

    expect(find.text('MERHABA, TUBA 👋'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Tuba Arpaçay'), findsOneWidget);
    expect(find.textContaining('Hesap oluşturulmadı'), findsOneWidget);
  });
}
