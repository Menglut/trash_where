import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService {
  static const String _darkModeEnabledKey = 'setting_dark_mode_enabled';
  static final ValueNotifier<bool> darkModeEnabled = ValueNotifier<bool>(false);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    darkModeEnabled.value = prefs.getBool(_darkModeEnabledKey) ?? false;
  }

  Future<void> saveDarkModeEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeEnabledKey, value);
    darkModeEnabled.value = value;
  }
}
