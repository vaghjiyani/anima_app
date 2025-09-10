import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  // Responsive font sizes
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) {
      return baseSize * 1.2;
    } else if (isTablet(context)) {
      return baseSize * 1.1;
    } else {
      return baseSize;
    }
  }

  // Responsive card width
  static double getCardWidth(BuildContext context, {int itemsPerRow = 2}) {
    final screenWidth = getScreenWidth(context);
    final padding = getResponsivePadding(context).horizontal;
    final availableWidth = screenWidth - padding;

    if (isDesktop(context)) {
      final calculatedWidth =
          (availableWidth - (itemsPerRow - 1) * 16) / itemsPerRow;
      return calculatedWidth.clamp(120.0, 200.0); // Clamp between 120-200px
    } else if (isTablet(context)) {
      final calculatedWidth =
          (availableWidth - (itemsPerRow - 1) * 12) / itemsPerRow;
      return calculatedWidth.clamp(100.0, 180.0); // Clamp between 100-180px
    } else {
      return 140; // Fixed width for mobile
    }
  }

  // Responsive banner height
  static double getBannerHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 250;
    } else if (isTablet(context)) {
      return 200;
    } else {
      return 180;
    }
  }

  // Responsive anime card height
  static double getAnimeCardHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 320; // Increased from 300
    } else if (isTablet(context)) {
      return 290; // Increased from 270
    } else {
      return 260; // Increased from 250
    }
  }

  // Responsive max width
  static double getMaxWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200;
    } else if (isTablet(context)) {
      return 800;
    } else {
      return double.infinity;
    }
  }

  // Responsive grid columns
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 2;
    }
  }

  // Responsive button height
  static double getButtonHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 64;
    } else if (isTablet(context)) {
      return 60;
    } else {
      return 56;
    }
  }

  // Responsive icon size
  static double getIconSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) {
      return baseSize * 1.3;
    } else if (isTablet(context)) {
      return baseSize * 1.1;
    } else {
      return baseSize;
    }
  }
}
