import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

/// Helper class for consistent Material motion animations throughout the app
class AnimationHelpers {
  // Private constructor to prevent instantiation
  AnimationHelpers._();

  /// Default animation duration for page transitions
  static const Duration defaultDuration = Duration(milliseconds: 400);

  /// Container transform duration (slightly longer for smoother effect)
  static const Duration containerDuration = Duration(milliseconds: 500);

  /// Shared Axis page route for hierarchical navigation
  /// Use this for parent-child page transitions (e.g., Home -> Profile, Home -> Detail)
  static Route<T> sharedAxisRoute<T>({
    required Widget page,
    SharedAxisTransitionType transitionType = SharedAxisTransitionType.scaled,
    Duration? duration,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          child: child,
        );
      },
      transitionDuration: duration ?? defaultDuration,
      reverseTransitionDuration: duration ?? defaultDuration,
    );
  }

  /// Fade Through page route for unrelated UI transitions
  /// Use this for bottom nav switches or tab changes
  static Route<T> fadeThroughRoute<T>({
    required Widget page,
    Duration? duration,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      transitionDuration: duration ?? defaultDuration,
      reverseTransitionDuration: duration ?? defaultDuration,
    );
  }

  /// Fade page route for dialogs and overlays
  static Route<T> fadeRoute<T>({required Widget page, Duration? duration}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(animation: animation, child: child);
      },
      transitionDuration: duration ?? defaultDuration,
      reverseTransitionDuration: duration ?? defaultDuration,
    );
  }

  /// Build an OpenContainer for container transform animations
  /// Use this for anime cards -> detail page transitions
  static Widget buildOpenContainer({
    required BuildContext context,
    required Widget Function(BuildContext, VoidCallback) closedBuilder,
    required Widget Function(BuildContext, VoidCallback) openBuilder,
    VoidCallback? onClosed,
    Color? closedColor,
    Color? openColor,
    double closedElevation = 2.0,
    double openElevation = 0.0,
    ShapeBorder? closedShape,
  }) {
    return OpenContainer(
      closedElevation: closedElevation,
      openElevation: openElevation,
      closedColor: closedColor ?? Theme.of(context).cardColor,
      openColor: openColor ?? Theme.of(context).scaffoldBackgroundColor,
      closedShape:
          closedShape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      transitionDuration: containerDuration,
      closedBuilder: closedBuilder,
      openBuilder: openBuilder,
      onClosed: (data) {
        if (onClosed != null) onClosed();
      },
    );
  }
}
