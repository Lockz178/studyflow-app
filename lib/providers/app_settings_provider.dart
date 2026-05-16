import 'package:flutter/material.dart';

import '../services/settings_service.dart';

class AppSettingsProvider extends ChangeNotifier {
  AppSettingsProvider({SettingsService? settingsService})
    : _settingsService = settingsService ?? SettingsService();

  final SettingsService _settingsService;

  ThemeMode _themeMode = ThemeMode.dark;
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> load() async {
    final raw = await _settingsService.getThemeModeRaw();
    _themeMode = _themeModeFromStorage(raw);
    _notificationsEnabled = await _settingsService.getNotificationsEnabled();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _settingsService.setThemeModeRaw(_themeModeToStorage(mode));
  }

  static ThemeMode _themeModeFromStorage(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  static String _themeModeToStorage(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  Future<void> setNotificationsEnabled(bool value) async {
    if (_notificationsEnabled == value) return;
    _notificationsEnabled = value;
    notifyListeners();
    await _settingsService.setNotificationsEnabled(value);
  }
}
