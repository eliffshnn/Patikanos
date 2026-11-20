import 'package:flutter/material.dart';

import 'data/user_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final onboarded = await Session.load();
  runApp(MyApp(onboarded: onboarded));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.onboarded = true});

  /// false ise uygulama onboarding ile açılır (yalnızca ilk açılışta).
  final bool onboarded;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patikanos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: onboarded ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
