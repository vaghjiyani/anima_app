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
      appBar: AppBar(
        title: const Text('Top Anime'),
        backgroundColor: Colors.green[400],
      ),
      body: Container(
        decoration: AppColors.primaryGradientDecoration,
        child: ListView.separated(
          padding: ResponsiveHelper.getResponsivePadding(context),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              tileColor: Colors.white.withOpacity(0.9),
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
