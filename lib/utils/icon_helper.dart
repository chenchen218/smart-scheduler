import 'package:flutter/material.dart';

/// Icon Helper Utility
/// Maps string icon names to actual IconData objects
class IconHelper {
  static const Map<String, IconData> _iconMap = {
    'group': Icons.group_rounded,
    'work': Icons.work_rounded,
    'school': Icons.school_rounded,
    'home': Icons.home_rounded,
    'favorite': Icons.favorite_rounded,
    'star': Icons.star_rounded,
    'lightbulb': Icons.lightbulb_rounded,
    'rocket': Icons.rocket_launch_rounded,
    'diamond': Icons.diamond_rounded,
    'heart': Icons.favorite_rounded,
    'business': Icons.business_rounded,
    'sports': Icons.sports_rounded,
    'music': Icons.music_note_rounded,
    'movie': Icons.movie_rounded,
    'travel': Icons.flight_rounded,
    'food': Icons.restaurant_rounded,
    'shopping': Icons.shopping_cart_rounded,
    'health': Icons.health_and_safety_rounded,
    'tech': Icons.computer_rounded,
    'art': Icons.palette_rounded,
  };

  /// Get IconData from string name
  static IconData getIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.group_rounded; // Default icon
    }
    return _iconMap[iconName] ?? Icons.group_rounded;
  }

  /// Get all available icon names
  static List<String> getAvailableIcons() {
    return _iconMap.keys.toList();
  }

  /// Check if icon name exists
  static bool hasIcon(String iconName) {
    return _iconMap.containsKey(iconName);
  }
}
