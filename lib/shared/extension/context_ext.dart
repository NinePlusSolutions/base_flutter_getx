import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;
  ThemeMode get themeMode =>
      MediaQuery.of(this).platformBrightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  // NAME	SIZE	WEIGHT	SPACING
  // displayLarge	96.0	light	-1.5
  // displayMedium	60.0	light	-0.5
  // displaySmall	48.0	regular	0.0
  // headlineMedium	34.0	regular	0.25
  // headlineSmall	24.0	regular	0.0
  // titleLarge	20.0	medium	0.15
  // titleMedium	16.0	regular	0.15
  // titleSmall	14.0	medium	0.1
  // bodyLarge	16.0	regular	0.5
  // bodyMedium	14.0	regular	0.25
  // bodySmall	12.0	regular	0.4
  // labelLarge	14.0	medium	1.25
  // labelSmall	10.0	regular	1.5

  /// text style
  TextStyle get headline => textTheme.headlineLarge!;

  TextStyle get title => textTheme.titleLarge!;

  TextStyle get label => textTheme.labelLarge!;

  TextStyle get body => textTheme.bodyLarge!;

  // hint text
  TextStyle get bodySmall => textTheme.bodySmall!;
}
