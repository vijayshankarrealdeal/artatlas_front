// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // For system brightness
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class ThemeProvider with ChangeNotifier {
  static const String _themePrefKey =
      'themePreference'; // Key for SharedPreferences

  ThemeMode _themeMode =
      ThemeMode.light; // Default to light before loading preference

  ThemeProvider() {
    _loadThemePreference(); // Load preference on initialization
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    } else {
      return _themeMode == ThemeMode.dark;
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _saveThemePreference(mode); // Save preference when changed
      notifyListeners();
    }
  }

  void toggleTheme() {
    // If current mode is system, toggling should pick one explicitly based on current system brightness
    if (_themeMode == ThemeMode.system) {
      if (SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark) {
        // System is dark, so toggle to light
        setThemeMode(ThemeMode.light);
      } else {
        // System is light, so toggle to dark
        setThemeMode(ThemeMode.dark);
      }
    } else if (isDarkMode) {
      // If explicitly dark, toggle to light
      setThemeMode(ThemeMode.light);
    } else {
      // If explicitly light, toggle to dark
      setThemeMode(ThemeMode.dark);
    }
  }

  // --- SharedPreferences Logic ---
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themePreference = prefs.getString(_themePrefKey);

      if (themePreference != null) {
        if (themePreference == 'dark') {
          _themeMode = ThemeMode.dark;
        } else if (themePreference == 'light') {
          _themeMode = ThemeMode.light;
        } else {
          // 'system' or any other unrecognized value
          _themeMode = ThemeMode.system;
        }
      } else {
        _themeMode = ThemeMode.light; // Default if no preference is saved yet
      }
    } catch (e) {
      _themeMode = ThemeMode.light; // Fallback to a default
    }
    notifyListeners(); // Notify listeners after loading
  }

  Future<void> _saveThemePreference(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String valueToSave;
      if (mode == ThemeMode.dark) {
        valueToSave = 'dark';
      } else if (mode == ThemeMode.light) {
        valueToSave = 'light';
      } else {
        // ThemeMode.system
        valueToSave = 'system';
      }
      await prefs.setString(_themePrefKey, valueToSave);
    } catch (e) {
      // Handle potential errors during SharedPreferences access
    }
  }
}
