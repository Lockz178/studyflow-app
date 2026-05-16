import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyflow_app/providers/app_settings_provider.dart';

void main() {
  group('AppSettingsProvider', () {
    test('setThemeMode persists through SettingsService', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});

      final provider = AppSettingsProvider();
      await provider.load();
      await provider.setThemeMode(ThemeMode.light);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings_theme_mode'), 'light');
      expect(provider.themeMode, ThemeMode.light);
    });

    test('setThemeMode system persists and reloads', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({
        'settings_theme_mode': 'system',
      });

      final provider = AppSettingsProvider();
      await provider.load();
      expect(provider.themeMode, ThemeMode.system);

      await provider.setThemeMode(ThemeMode.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('settings_theme_mode'), 'dark');
    });

    test('setNotificationsEnabled updates flag and storage', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});

      final provider = AppSettingsProvider();
      await provider.load();
      await provider.setNotificationsEnabled(false);

      expect(provider.notificationsEnabled, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('settings_notifications_enabled'), isFalse);
    });
  });
}
