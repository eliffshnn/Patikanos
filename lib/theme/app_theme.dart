import 'package:flutter/material.dart';

/// Patikanos renkleri: Muğla'nın çam ormanları, Ege denizi, kum ve gün batımı.
class AppColors {
  static const pine = Color(0xFF1F5E4B);
  static const pineDark = Color(0xFF143F33);
  static const sea = Color(0xFF1F7A8C);
  static const seaLight = Color(0xFFD7ECEF);
  static const sand = Color(0xFFF6F1E7);
  static const sandDark = Color(0xFFEDE5D5);
  static const surface = Color(0xFFFCF9F3); // sıcak kâğıt tonu, saf beyaz yerine
  static const ink = Color(0xFF1C2A27);
  static const muted = Color(0xFF6B7A75);
  static const line = Color(0xFFE4DDD0);
  static const sunset = Color(0xFFE8833A);
  static const sunsetLight = Color(0xFFF6C79A);
  static const seaBright = Color(0xFF3FA7B5);

  static const good = Color(0xFF2E9E6A);
  static const fair = Color(0xFF8DB64A);
  static const okay = Color(0xFFE8A53A);
  static const bad = Color(0xFFD9534F);

  // Fotoğraf ya da koyu gradyan üzerindeki metin ve yüzeyler
  static const onDark = Colors.white;
  static const onDarkMuted = Color(0xC7FFFFFF); // %78
  static const onDarkSubtle = Color(0x99FFFFFF); // %60
  static const onDarkGood = Color(0xFFBFE3C9);
  static const onDarkBad = Color(0xFFFFC9C2);
  static const glass = Color(0x1FFFFFFF); // %12
  static const glassBorder = Color(0x38FFFFFF); // %22
  static const shadow = Color(0x1F000000);

  // Fotoğrafların üzerindeki koyu çam yeşili katmanlar (onboarding)
  static const glassDark = Color(0x5C143F33);
  static const photoSheet = Color(0x29143F33);
  static const photoScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, 0.2, 0.56, 0.76, 1],
    colors: [Color(0x59143F33), Color(0x00143F33), Color(0x00143F33), Color(0x9E143F33), Color(0xE0143F33)],
  );
  static const photoScrimTop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, 0.14],
    colors: [Color(0x40143F33), Color(0x00143F33)],
  );

  /// Bir rengin açık zemin tonu (ikon kutuları, rozetler, uyarı kartları). Hep aynı saydamlık.
  static Color tint(Color color) => color.withValues(alpha: 0.12);

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
}

/// Uygulamadaki bütün yazı stilleri. Ekranlarda yeni boyut/ağırlık tanımlamak yerine bunlardan birini
/// seçip gerekirse sadece rengini değiştirin: `AppText.title.copyWith(color: AppColors.onDark)`.
/// Aynı stiller ThemeData.textTheme'e de bağlı (Theme.of(context).textTheme.headlineLarge == AppText.screenTitle).
class AppText {
  // Fraunces: başlıklar ve öne çıkan sayılar
  static const score = TextStyle(fontFamily: AppFonts.serif, fontSize: 44, fontWeight: FontWeight.w500, height: 1.0, letterSpacing: -0.6, color: AppColors.ink);
  static const screenTitle = TextStyle(fontFamily: AppFonts.serif, fontSize: 32, fontWeight: FontWeight.w500, height: 1.1, letterSpacing: -0.6, color: AppColors.ink);
  static const hero = TextStyle(fontFamily: AppFonts.serif, fontSize: 28, fontWeight: FontWeight.w500, height: 1.12, letterSpacing: -0.4, color: AppColors.ink);
  static const title = TextStyle(fontFamily: AppFonts.serif, fontSize: 24, fontWeight: FontWeight.w500, height: 1.15, letterSpacing: -0.3, color: AppColors.ink);
  static const section = TextStyle(fontFamily: AppFonts.serif, fontSize: 20, fontWeight: FontWeight.w500, height: 1.2, letterSpacing: -0.2, color: AppColors.ink);

  // Manrope: metin, buton, etiket
  static const cardTitle = TextStyle(fontFamily: AppFonts.sans, fontSize: 16, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.1, color: AppColors.ink);
  static const body = TextStyle(fontFamily: AppFonts.sans, fontSize: 15, fontWeight: FontWeight.w500, height: 1.5, color: AppColors.ink);
  static const bodyMuted = TextStyle(fontFamily: AppFonts.sans, fontSize: 14, fontWeight: FontWeight.w500, height: 1.45, color: AppColors.muted);
  static const caption = TextStyle(fontFamily: AppFonts.sans, fontSize: 12, fontWeight: FontWeight.w500, height: 1.35, color: AppColors.muted);
  static const button = TextStyle(fontFamily: AppFonts.sans, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.1);
  static const label = TextStyle(fontFamily: AppFonts.sans, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.ink);

  /// Küçük, aralıklı büyük harf üst başlıklar ve rozetler ("AKILLI ZAMANLAMA", "Orta")
  static const eyebrow = TextStyle(fontFamily: AppFonts.sans, fontSize: 11, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: 1.4, color: AppColors.muted);
}

/// Uygulamadaki fotoğraflar. Rotaya özel fotoğraf olmadığı için bunlar sadece atmosfer görseli olarak
/// kullanılır (Bugün, hava durumu, profil); rota kartlarında rotanın gerçek haritası gösterilir.
class AppImages {
  static const coast = 'assets/onboarding/coast-hike.jpg';
  static const forest = 'assets/onboarding/forest-bike.jpg';
  static const sunset = 'assets/onboarding/sunset-climb.jpg';

  /// Hava durumu kartının arka planı: bisiklette orman yolu, yürüyüşte sahil patikası
  static String forActivity(String activity) => activity == 'bike' ? forest : coast;
}

/// Kartlar, işaretler ve alt menü için tek tip gölgeler.
class AppShadows {
  static const soft = [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, -2))];
  static const raised = [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 3))];
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
        displaySmall: AppText.score,
        headlineLarge: AppText.screenTitle,
        headlineMedium: AppText.hero,
        headlineSmall: AppText.title,
        titleLarge: AppText.section,
        titleMedium: AppText.cardTitle,
        bodyLarge: AppText.body,
        bodyMedium: AppText.bodyMuted,
        bodySmall: AppText.caption,
        labelLarge: AppText.button,
        labelMedium: AppText.label,
        labelSmall: AppText.eyebrow,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.sand,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.section,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.pine,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: const StadiumBorder(),
          textStyle: AppText.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: const StadiumBorder(),
          textStyle: AppText.button,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.pine,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        labelStyle: AppText.label,
        secondaryLabelStyle: AppText.label.copyWith(color: AppColors.onDark),
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppText.bodyMuted,
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
          (states) => AppText.caption.copyWith(
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
