import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';

class MagazinesPage extends StatelessWidget {
  const MagazinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      'Weekly Shonen Jump',
      'Monthly Shonen Magazine',
      'Young Magazine',
      'V Jump',
      'Ultra Jump',
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Magazines',
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
