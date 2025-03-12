import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';
import 'package:flutter_getx_boilerplate/theme/text_theme.dart';

class ThemeConfig {
  static ThemeData get lightTheme => _getTheme(lightColorScheme);
  static ThemeData get darkTheme => _getTheme(darkColorScheme);

  static _getTheme(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      brightness: colorScheme.brightness,
      useMaterial3: true,
      hintColor: colorScheme.onSurface.withOpacity(.6),
      disabledColor: colorScheme.onSurface.withOpacity(.7),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        titleTextStyle: Typo.h4,
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: colorScheme.primary,
        selectionHandleColor: colorScheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kRadius),
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadius),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadius),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadius),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        hintStyle: Typo.bodyM.copyWith(
          color: colorScheme.onSurface.withOpacity(.6),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
      fontFamily: "Cabin",
    );
  }
}
