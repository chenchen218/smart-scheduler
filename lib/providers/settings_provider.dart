import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';

/// Provider for managing app settings and preferences
class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  final NotificationService _notificationService = NotificationService();

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  int _themeMode = 0; // 0: system, 1: light, 2: dark
  bool _isLoading = false;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  int get themeMode => _themeMode;
  bool get isLoading => _isLoading;

  /// Initialize settings
  Future<void> initializeSettings() async {
    _setLoading(true);

    try {
      _notificationsEnabled = await _settingsService.getNotificationsEnabled();
      _darkModeEnabled = await _settingsService.getDarkModeEnabled();
      _themeMode = await _settingsService.getThemeMode();

      // Sync theme mode with dark mode setting
      if (_themeMode == 0) {
        // If system mode, use dark mode setting
        _themeMode = _darkModeEnabled ? 2 : 1;
      }
    } catch (e) {
      print('SettingsProvider: Error loading settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle notifications
  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();

    try {
      await _settingsService.setNotificationsEnabled(_notificationsEnabled);
      // Update the notification service
      await _notificationService.setEnabled(_notificationsEnabled);
    } catch (e) {
      // Revert on error
      _notificationsEnabled = !_notificationsEnabled;
      notifyListeners();
      print('SettingsProvider: Error saving notification setting: $e');
    }
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    _darkModeEnabled = !_darkModeEnabled;
    // Automatically set theme mode based on dark mode toggle
    _themeMode = _darkModeEnabled ? 2 : 1; // 2 = Dark, 1 = Light
    notifyListeners();

    try {
      await _settingsService.setDarkModeEnabled(_darkModeEnabled);
      await _settingsService.setThemeMode(_themeMode);
    } catch (e) {
      // Revert on error
      _darkModeEnabled = !_darkModeEnabled;
      _themeMode = _darkModeEnabled ? 2 : 1;
      notifyListeners();
      print('SettingsProvider: Error saving dark mode setting: $e');
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(int mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      await _settingsService.setThemeMode(mode);
    } catch (e) {
      print('SettingsProvider: Error saving theme mode: $e');
    }
  }

  /// Get theme mode for MaterialApp
  ThemeMode get themeModeForApp {
    switch (_themeMode) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
