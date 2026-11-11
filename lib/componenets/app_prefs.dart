import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-level appearance preferences (theme and language). [AppStarter]
/// listens to these notifiers, so changing them updates the app at once.
class AppPrefs {
  AppPrefs._();

  static const _themeKey = 'pref_theme_mode';
  static const _localeKey = 'pref_locale';

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.system);

  /// null = follow the device language.
  static final ValueNotifier<Locale?> locale = ValueNotifier(null);

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      themeMode.value = ThemeMode.values.firstWhere(
        (m) => m.name == prefs.getString(_themeKey),
        orElse: () => ThemeMode.system,
      );
      final code = prefs.getString(_localeKey);
      locale.value = (code == null || code.isEmpty) ? null : Locale(code);
    } catch (_) {
      // Fall back to system defaults.
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  static Future<void> setLocale(Locale? value) async {
    locale.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, value?.languageCode ?? '');
  }
}
