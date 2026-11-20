import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:patikanos/main.dart';

void main() {
  testWidgets('Shows the real app with bottom navigation and action buttons',
      (tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Patikanos'), findsOneWidget);
    expect(find.text('Bugün hangi rota, hangi saatte?'), findsOneWidget);
    expect(find.text('Bisiklet'), findsWidgets);
    expect(find.text('Devam'), findsOneWidget);

    await tester.tap(find.text('Keşfet'));
    await tester.pumpAndSettle();
    expect(find.text('Rotalar'), findsOneWidget);
    expect(find.textContaining('16 yürüyüş ve bisiklet rotası'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
    await tester.tap(find.text('Favoriler'));
    await tester.pumpAndSettle();
    expect(find.textContaining('1 rota'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Profil ve Ayarlar'), findsOneWidget);
  });
}
