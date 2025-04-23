import 'package:flutter/material.dart';

enum AppThemeMode {
  system(Icons.settings, ThemeMode.system),
  light(Icons.light_mode, ThemeMode.light),
  dark(Icons.dark_mode, ThemeMode.dark);

  final IconData icon;
  final ThemeMode themeMode;

  const AppThemeMode(this.icon, this.themeMode);

  static AppThemeMode fromInt(int value) {
    return AppThemeMode.values.firstWhere(
          (e) => e.index == value,
      orElse: () => AppThemeMode.system,
    );
  }
}