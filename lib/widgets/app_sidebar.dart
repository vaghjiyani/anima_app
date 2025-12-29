import 'package:flutter/material.dart';
import '../screens/top_anime_page.dart';
import '../screens/manga_page.dart';
import '../screens/profile_page.dart';
import '../screens/search_page.dart';
import '../screens/seasonal_anime_page.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import '../screens/signin_screen.dart';
import '../screens/theme_settings_page.dart';

class AppSidebar extends StatefulWidget {
  const AppSidebar({super.key});

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _fade(int index, {int total = 8}) {
    final start = 0.15 + (index * (0.5 / total));
    final end = (start + 0.2).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _slide(int index, {int total = 8}) {
    final start = 0.1 + (index * (0.5 / total));
    final end = (start + 0.25).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(-0.2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Container(
          decoration: AppColors.themedPrimaryGradient(context),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizeTransition(
                      sizeFactor: CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
                      ),
                      axisAlignment: -1.0,
                      child: _AnimatedHeader(controller: _controller),
                    ),
                    FadeTransition(
                      opacity: _fade(0),
                      child: SlideTransition(
                        position: _slide(0),
                        child: _NavTile(
                          icon: Icons.home_outlined,
                          label: 'Home',
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    // Browse Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        'BROWSE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _fade(1),
                      child: SlideTransition(
                        position: _slide(1),
                        child: _NavTile(
                          icon: Icons.search,
                          label: 'Search',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SearchPage()),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _fade(2),
                      child: SlideTransition(
                        position: _slide(2),
                        child: _NavTile(
                          icon: Icons.trending_up,
                          label: 'Top Anime',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TopAnimePage()),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _fade(3),
                      child: SlideTransition(
                        position: _slide(3),
                        child: _NavTile(
                          icon: Icons.calendar_today,
                          label: 'Seasonal Anime',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SeasonalAnimePage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _fade(4),
                      child: SlideTransition(
                        position: _slide(4),
                        child: _NavTile(
                          icon: Icons.book_outlined,
                          label: 'Manga',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MangaPage()),
                            );
                          },
                        ),
                      ),
                    ),

                    // Library Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Text(
                        'SETTINGS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _fade(5),
                      child: SlideTransition(
                        position: _slide(5),
                        child: _NavTile(
                          icon: Icons.person_outline,
                          label: 'Profile',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfilePage()),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _fade(6),
                      child: SlideTransition(
                        position: _slide(6),
                        child: _NavTile(
                          icon: Icons.dark_mode,
                          label: 'Theme Settings',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ThemeSettingsPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const Spacer(),
                    FadeTransition(
                      opacity: _fade(5),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: _LogoutTile(
                          onTap: () async {
                            Navigator.pop(context);
                            await AuthService.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const SigninScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'v1.0.0',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedHeader extends StatelessWidget {
  const _AnimatedHeader({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fade = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    final slide = Tween<Offset>(begin: const Offset(-0.1, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Text(
            'Anima Menu',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color base = theme.colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: base.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(icon, color: base),
            title: Text(
              label,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            trailing: Icon(Icons.chevron_right, color: base.withOpacity(0.7)),
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color danger = theme.colorScheme.error;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: danger.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(Icons.logout, color: danger),
          title: Text(
            'Logout',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: danger.withOpacity(0.7)),
        ),
      ),
    );
  }
}
