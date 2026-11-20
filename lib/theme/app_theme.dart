import 'package:flutter/material.dart';

/// Patikanos renkleri: Muğla'nın çam ormanları, Ege denizi, kum ve gün batımı.
class AppColors {
  static const pine = Color(0xFF1F5E4B);
  static const pineDark = Color(0xFF143F33);
  static const sea = Color(0xFF1F7A8C);
  static const seaLight = Color(0xFFD7ECEF);
  static const sand = Color(0xFFF6F1E7);
  static const sandDark = Color(0xFFEDE5D5);
  static const surface = Colors.white;
  static const ink = Color(0xFF1C2A27);
  static const muted = Color(0xFF6B7A75);
  static const line = Color(0xFFE4DDD0);
  static const sunset = Color(0xFFE8833A);

  static const good = Color(0xFF2E9E6A);
  static const fair = Color(0xFF8DB64A);
  static const okay = Color(0xFFE8A53A);
  static const bad = Color(0xFFD9534F);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pineDark, pine, sea],
  );
}

/// Başlıklar Fraunces (serif), metinler Manrope. Dosyalar assets/fonts/ içinde, pubspec.yaml'da kayıtlı.
class AppFonts {
  static const serif = 'Fraunces';
  static const sans = 'Manrope';

  /// Büyük başlıklar ve öne çıkan sayılar için (onboarding'deki başlıklarla aynı görünüm).
  static TextStyle display(double size, {Color color = AppColors.ink, FontWeight weight = FontWeight.w500}) =>
      TextStyle(fontFamily: serif, fontSize: size, fontWeight: weight, color: color, height: 1.12, letterSpacing: -0.4);
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.pine,
      primary: AppColors.pine,
      secondary: AppColors.sea,
      tertiary: AppColors.sunset,
      surface: AppColors.surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.sand,
      fontFamily: AppFonts.sans,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: AppFonts.serif, fontSize: 32, fontWeight: FontWeight.w500, color: AppColors.ink, height: 1.1, letterSpacing: -0.6),
        headlineSmall: TextStyle(fontFamily: AppFonts.serif, fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.3),
        titleLarge: TextStyle(fontFamily: AppFonts.serif, fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.ink, letterSpacing: -0.2),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.1),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.muted, height: 1.45),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.muted),
        labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.sand,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontFamily: AppFonts.serif, fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.ink, letterSpacing: -0.2),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.pine,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontFamily: AppFonts.sans, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.pine,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        labelStyle: const TextStyle(fontFamily: AppFonts.sans, fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
        secondaryLabelStyle: const TextStyle(fontFamily: AppFonts.sans, fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.muted),
        prefixIconColor: AppColors.muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.pine, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.seaLight,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? AppColors.pine : AppColors.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? AppColors.pine : AppColors.muted,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),
    );
  }
}

Color difficultyColor(int difficulty) => switch (difficulty) {
      1 => AppColors.good,
      2 => AppColors.okay,
      _ => AppColors.bad,
    };

String difficultyLabel(int difficulty) => switch (difficulty) {
      1 => 'Kolay',
      2 => 'Orta',
      _ => 'Zor',
    };
