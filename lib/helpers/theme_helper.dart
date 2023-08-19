import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeHelper {
  final GetStorage _box = GetStorage();
  final String _key = 'isDarkMode';

  Future<void> initialize({bool userDarkModeSetting = false}) async {
    await GetStorage.init();
    if (_box.read(_key) == null) {
      _box.write(_key, userDarkModeSetting); // Initialize with user preference
    }
  }

  ThemeMode get themeMode {
    final isDarkMode = _box.read<bool>(_key) ?? false;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDark {
    ThemeMode themeMode = ThemeHelper().themeMode;
    bool isDarkMode = themeMode == ThemeMode.dark;
    return isDarkMode;
  }

  void toggleTheme() {
    final isDarkMode = _box.read<bool>(_key) ?? false;
    final newThemeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;

    Get.changeThemeMode(newThemeMode);
    _box.write(_key, !isDarkMode);
  }

  void deleteThemePreference() {
    _box.remove(_key);
  }
}
