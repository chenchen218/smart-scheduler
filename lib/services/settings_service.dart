import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user settings and preferences
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _notificationsKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _themeKey = 'theme_mode';

  /// Get SharedPreferences instance
  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  /// Get notification settings
  Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_notificationsKey) ?? true; // Default to enabled
  }

  /// Set notification settings
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_notificationsKey, enabled);
  }

  /// Get dark mode setting
  Future<bool> getDarkModeEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_darkModeKey) ?? false; // Default to light mode
  }

  /// Set dark mode setting
  Future<void> setDarkModeEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_darkModeKey, enabled);
  }

  /// Get theme mode (0: system, 1: light, 2: dark)
  Future<int> getThemeMode() async {
    final prefs = await _prefs;
    return prefs.getInt(_themeKey) ?? 0; // Default to system
  }

  /// Set theme mode
  Future<void> setThemeMode(int mode) async {
    final prefs = await _prefs;
    await prefs.setInt(_themeKey, mode);
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    final prefs = await _prefs;
    await prefs.remove(_notificationsKey);
    await prefs.remove(_darkModeKey);
    await prefs.remove(_themeKey);
  }
}
