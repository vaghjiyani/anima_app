import 'package:flutter/material.dart';

/// Custom AppBar widget with gradient background and no white background
///
/// Usage:
/// ```dart
/// return Scaffold(
///   extendBodyBehindAppBar: true,
///   backgroundColor: Colors.transparent,
///   appBar: CustomAppBar(title: 'Page Title'),
///   body: Container(
///     decoration: AppColors.themedPrimaryGradient(context),
///     child: SafeArea(child: YourContent()),
///   ),
/// );
/// ```
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading:
          leading ??
          (automaticallyImplyLeading
              ? BackButton(color: isDark ? Colors.white : Colors.black)
              : null),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Custom Scaffold with gradient background - use this for all pages
///
/// Usage:
/// ```dart
/// return GradientScaffold(
///   appBarTitle: 'Page Title',
///   body: YourContent(),
/// );
/// ```
class GradientScaffold extends StatelessWidget {
  final String appBarTitle;
  final Widget body;
  final bool centerTitle;
  final List<Widget>? appBarActions;
  final Widget? appBarLeading;
  final bool automaticallyImplyLeading;
  final bool showAppBar;

  const GradientScaffold({
    super.key,
    required this.appBarTitle,
    required this.body,
    this.centerTitle = true,
    this.appBarActions,
    this.appBarLeading,
    this.automaticallyImplyLeading = true,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: showAppBar,
      backgroundColor: Colors.transparent,
      appBar: showAppBar
          ? CustomAppBar(
              title: appBarTitle,
              centerTitle: centerTitle,
              actions: appBarActions,
              leading: appBarLeading,
              automaticallyImplyLeading: automaticallyImplyLeading,
            )
          : null,
      body: body,
    );
  }
}
