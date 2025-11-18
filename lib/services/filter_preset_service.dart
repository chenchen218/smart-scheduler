import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/filter_options.dart';

/// Service for managing filter presets
class FilterPresetService {
  static final FilterPresetService _instance = FilterPresetService._internal();
  factory FilterPresetService() => _instance;
  FilterPresetService._internal();

  static const String _presetsKey = 'filter_presets';

  /// Get SharedPreferences instance
  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  /// Get all saved presets
  Future<List<FilterPreset>> getPresets() async {
    try {
      final prefs = await _prefs;
      final presetsJson = prefs.getStringList(_presetsKey) ?? [];
      return presetsJson
          .map((json) => FilterPreset.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading filter presets: $e');
      return [];
    }
  }

  /// Save a preset
  Future<void> savePreset(FilterPreset preset) async {
    try {
      final presets = await getPresets();
      final existingIndex = presets.indexWhere((p) => p.id == preset.id);

      if (existingIndex >= 0) {
        presets[existingIndex] = preset;
      } else {
        presets.add(preset);
      }

      final prefs = await _prefs;
      final presetsJson = presets.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(_presetsKey, presetsJson);
    } catch (e) {
      print('Error saving filter preset: $e');
    }
  }

  /// Delete a preset
  Future<void> deletePreset(String presetId) async {
    try {
      final presets = await getPresets();
      presets.removeWhere((p) => p.id == presetId);

      final prefs = await _prefs;
      final presetsJson = presets.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(_presetsKey, presetsJson);
    } catch (e) {
      print('Error deleting filter preset: $e');
    }
  }

  /// Clear all presets
  Future<void> clearPresets() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_presetsKey);
    } catch (e) {
      print('Error clearing filter presets: $e');
    }
  }
}
