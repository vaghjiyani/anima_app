import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';

class TopAnimePage extends StatelessWidget {
  const TopAnimePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      'Demon Slayer',
      'One Piece',
      'Jujutsu Kaisen',
      'Your Name',
      'Attack on Titan',
      'Naruto',
      'Chainsaw Man',
      'My Hero Academia',
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Top Anime',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      body: Container(
        decoration: AppColors.themedPrimaryGradient(context),
        child: ListView.separated(
          padding: EdgeInsets.only(
            top: ResponsiveHelper.isDesktop(context) ? 100 : 80,
            left: ResponsiveHelper.getResponsivePadding(context).left,
            right: ResponsiveHelper.getResponsivePadding(context).right,
            bottom: ResponsiveHelper.getResponsivePadding(context).bottom,
          ),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final theme = Theme.of(context);
            final tileColor = theme.brightness == Brightness.dark
                ? theme.colorScheme.surface.withOpacity(0.7)
                : Colors.white.withOpacity(0.9);
            return ListTile(
              tileColor: tileColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                items[index],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          },
        ),
      ),
    );
  }
}
