import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFFff9a9e), // Soft coral
    Color(0xFFfecfef), // Light pink
    Color(0xFFfecfef), // Light pink
    Color(0xFFffecd2), // Cream
  ];

  static const List<double> primaryGradientStops = [0.0, 0.3, 0.7, 1.0];

  // Alternative gradient options
  static const List<Color> blueGradient = [
    Color(0xFF1e3c72), // Deep blue
    Color(0xFF2a5298), // Medium blue
    Color(0xFF4facfe), // Light blue
    Color(0xFF00f2fe), // Cyan
  ];

  static const List<Color> professionalGradient = [
    Color(0xFF2C3E50), // Dark blue-gray
    Color(0xFF34495E), // Medium blue-gray
    Color(0xFF3498DB), // Bright blue
    Color(0xFF85C1E9), // Light blue
  ];

  static const List<Color> sunsetGradient = [
    Color(0xFF667eea), // Beautiful blue-purple
    Color(0xFF764ba2), // Deep purple
    Color(0xFFf093fb), // Soft pink
    Color(0xFFf5576c), // Coral pink
  ];

  // Individual colors
  static const Color primaryColor = Color(0xFFff9a9e);
  static const Color secondaryColor = Color(0xFFfecfef);
  static const Color accentColor = Color(0xFFffecd2);
  static const Color textColor = Colors.white;
  static const Color buttonColor = Colors.white;

  // Helper method to get gradient decoration
  static BoxDecoration get primaryGradientDecoration => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: primaryGradient,
      stops: primaryGradientStops,
    ),
  );

  // Context-aware gradient that dims for dark mode
  static BoxDecoration themedPrimaryGradient(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) return primaryGradientDecoration;
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2C3E50),
          Color(0xFF1B2838),
          Color(0xFF0F2027),
          Color(0xFF0B1116),
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ),
    );
  }

  static BoxDecoration get blueGradientDecoration => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: blueGradient,
      stops: [0.0, 0.4, 0.7, 1.0],
    ),
  );

  static BoxDecoration get professionalGradientDecoration =>
      const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: professionalGradient,
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
      );

  static BoxDecoration get sunsetGradientDecoration => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: sunsetGradient,
      stops: [0.0, 0.3, 0.7, 1.0],
    ),
  );
}
