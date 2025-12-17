import 'package:flutter/material.dart';

enum ColorTheme { green, blue, purple, orange, pink, teal }

class ColorThemes {
  ColorThemes._();

  static const Map<ColorTheme, Color> seedColors = {
    ColorTheme.green: Color(0xFF4CAF50),
    ColorTheme.blue: Color(0xFF2196F3),
    ColorTheme.purple: Color(0xFF9C27B0),
    ColorTheme.orange: Color(0xFFFF9800),
    ColorTheme.pink: Color(0xFFE91E63),
    ColorTheme.teal: Color(0xFF009688),
  };

  static const Map<ColorTheme, String> themeNames = {
    ColorTheme.green: 'Green',
    ColorTheme.blue: 'Blue',
    ColorTheme.purple: 'Purple',
    ColorTheme.orange: 'Orange',
    ColorTheme.pink: 'Pink',
    ColorTheme.teal: 'Teal',
  };

  static const Map<ColorTheme, IconData> themeIcons = {
    ColorTheme.green: Icons.eco,
    ColorTheme.blue: Icons.water_drop,
    ColorTheme.purple: Icons.auto_awesome,
    ColorTheme.orange: Icons.wb_sunny,
    ColorTheme.pink: Icons.favorite,
    ColorTheme.teal: Icons.waves,
  };

  static Color getSeedColor(ColorTheme theme) {
    return seedColors[theme] ?? seedColors[ColorTheme.green]!;
  }

  static String getThemeName(ColorTheme theme) {
    return themeNames[theme] ?? 'Green';
  }

  static IconData getThemeIcon(ColorTheme theme) {
    return themeIcons[theme] ?? Icons.eco;
  }

  static ColorTheme fromString(String? value) {
    switch (value) {
      case 'green':
        return ColorTheme.green;
      case 'blue':
        return ColorTheme.blue;
      case 'purple':
        return ColorTheme.purple;
      case 'orange':
        return ColorTheme.orange;
      case 'pink':
        return ColorTheme.pink;
      case 'teal':
        return ColorTheme.teal;
      default:
        return ColorTheme.green;
    }
  }

  static String toStringValue(ColorTheme theme) {
    return theme.toString().split('.').last;
  }
}
