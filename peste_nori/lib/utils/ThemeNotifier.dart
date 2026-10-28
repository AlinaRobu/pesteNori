import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  Future<void> load() async {
    // On web this goes through window.crypto.subtle / IndexedDB, which some
    // browsers refuse in stricter privacy/tracking-prevention modes. That
    // must not block startup — the app should just fall back to the default
    // theme rather than never calling runApp().
    try {
      const storage = FlutterSecureStorage();
      final saved = await storage.read(key: 'APP_THEME');
      value = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      debugPrint('ThemeNotifier.load failed, using default theme: $e');
    }
  }

  Future<void> toggle() async {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    const storage = FlutterSecureStorage();
    await storage.write(
      key: 'APP_THEME',
      value: value == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  bool get isDark => value == ThemeMode.dark;
}

class AppTheme {
  static const primary = Color(0xff00a77f);

  static ThemeData light() => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xffd7d8d6),
        colorScheme: const ColorScheme.light(
          primary: primary,
          surface: Colors.white,
          onSurface: Color(0xff1a1a1a),
          onSurfaceVariant: Color(0xff666666),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Color(0xff1a1a1a),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(
            color: Color(0xff444444),
            fontSize: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xff2b3028),
          contentTextStyle: TextStyle(color: Colors.white),
          actionTextColor: Color(0xff00a77f),
          behavior: SnackBarBehavior.fixed,
        ),
      );

  static ThemeData dark() => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff111714),
        colorScheme: const ColorScheme.dark(
          primary: primary,
          surface: Color(0xff1e2520),
          onSurface: Color(0xffe4ece6),
          onSurfaceVariant: Color(0xff8a9e8f),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xff1e2520),
          titleTextStyle: TextStyle(
            color: Color(0xffe4ece6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(
            color: Color(0xff8a9e8f),
            fontSize: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xff1a2118),
          contentTextStyle: TextStyle(color: Color(0xffe4ece6)),
          actionTextColor: Color(0xff00a77f),
          behavior: SnackBarBehavior.fixed,
        ),
      );

  static List<Color> gradientColors(ThemeMode mode) {
    if (mode == ThemeMode.dark) {
      return const [Color(0xff0d1210), Color(0xff141a16)];
    }
    return const [Color(0xff363b30), Color(0xff5e625a)];
  }
}