import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class ThemePreferences {
  static const _themeKey = 'theme_mode';

 

  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    print('🌓 Loaded theme preference: $isDark'); // 👈 log
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

 

  static Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
    print('💾 Saved theme preference: $isDarkMode'); // 👈 log
  }

 static void toggleTheme(bool isDarkMode) {
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  saveTheme(isDarkMode);
}

}
