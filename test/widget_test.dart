import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:patikanos/data/route_model.dart';
import 'package:patikanos/main.dart';
import 'package:patikanos/widgets/nature.dart';
import 'package:patikanos/screens/map_screen.dart';
import 'package:patikanos/theme/app_theme.dart';

void main() {
  setUp(() {
    rootBundle.clear();
    RouteRepository.clearCache();
    RouteMapPreview.enabled = false; // testte ağ yok
  });

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

  testWidgets('Map marker opens the route sheet and route detail', (tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // Harita parçaları testte yüklenemez ve animasyonları bitmez; pumpAndSettle yerine sabit süre ilerlet.
    Future<void> settle() async {
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: MapScreen()),
    ));
    await settle();

    expect(find.text('Muğla\'da 16 rota'), findsOneWidget);

    // Tek işaretler + küme balonlarındaki sayılar = 16 rota
    final singles = find.byIcon(Icons.hiking_rounded).evaluate().length +
        find.byIcon(Icons.directions_bike_rounded).evaluate().length;
    final clusters = find.byWidgetPredicate((w) => w is Text && RegExp(r'^\d+$').hasMatch(w.data ?? ''));
    final clustered = clusters.evaluate().fold<int>(0, (sum, e) => sum + int.parse((e.widget as Text).data!));
    expect(singles + clustered, 16);
    expect(clusters, findsWidgets);

    // Bir kümeye dokununca harita yakınlaşır ve kümedeki rotalar ayrı işaretlere bölünür
    final firstClusterSize = int.parse((clusters.evaluate().first.widget as Text).data!);
    await tester.tap(clusters.first);
    await settle();
    final singlesAfterZoom = find.byIcon(Icons.hiking_rounded).evaluate().length +
        find.byIcon(Icons.directions_bike_rounded).evaluate().length;
    expect(singlesAfterZoom, greaterThanOrEqualTo(firstClusterSize));

    await tester.tap(find.byIcon(Icons.hiking_rounded).first, warnIfMissed: false);
    await settle();
    expect(find.text('Rota detayını aç'), findsOneWidget);

    await tester.tap(find.text('Rota detayını aç'));
    await settle();
    expect(find.text('Mesafe'), findsOneWidget);
    expect(find.text('Hava durumuna bak'), findsOneWidget);
  });
}
