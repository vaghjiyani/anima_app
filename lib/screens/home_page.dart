import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';
import 'profile_page.dart';
import 'top_anime_page.dart';
import 'manga_page.dart';
import 'magazines_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  File? _profileImageFile;
  static const String _profileImagePathKey = 'profile_image_path';
  int _selectedIndex = 0;

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedProfileImage();
  }

  Future<void> _loadSavedProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_profileImagePathKey);
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) {
        setState(() {
          _profileImageFile = file;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> bannerImages = const [
      'assets/images/download.jpeg',
      'assets/images/download_1.jpeg',
      'assets/images/download_2.jpeg',
    ];

    final List<String> categories = const [
      'Action',
      'Romance',
      'Fantasy',
      'Comedy',
      'Sci‑Fi'
          'Adventure',
      'Drama',
      'Slice of Life',
    ];

    final List<_AnimeCardData> trending = const [
      _AnimeCardData('Demon Slayer', 'assets/images/download_1.jpeg'),
      _AnimeCardData('One Piece', 'assets/images/download_2.jpeg'),
      _AnimeCardData('Jujutsu Kaisen', 'assets/images/download.jpeg'),
      _AnimeCardData('Your Name', 'assets/images/download_2.jpeg'),
    ];

    final String query = _searchController.text.trim().toLowerCase();
    final List<_AnimeCardData> filteredTrending = query.isEmpty
        ? trending
        : trending.where((a) => a.title.toLowerCase().contains(query)).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Anima',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
              await _loadSavedProfileImage();
            },
            icon: (_profileImageFile != null)
                ? CircleAvatar(
                    radius: 16,
                    backgroundImage: FileImage(_profileImageFile!),
                  )
                : const Icon(Icons.person, color: Colors.white),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: AppColors.primaryGradientDecoration,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            top: ResponsiveHelper.isDesktop(context) ? 80 : 60,
            bottom: 12,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.getMaxWidth(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedIndex == 0) ...[
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 16 : 12,
                    ),
                    _SearchBar(controller: _searchController),
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 24 : 16,
                    ),
                    _SectionHeader(title: 'Featured'),
                    SizedBox(
                      height: ResponsiveHelper.getBannerHeight(context),
                      child: ListView.builder(
                        padding: ResponsiveHelper.getResponsivePadding(context),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: bannerImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < bannerImages.length - 1 ? 12 : 0,
                            ),
                            child: _BannerCard(imagePath: bannerImages[index]),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 24 : 16,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.isDesktop(context)
                            ? 16
                            : 12,
                      ),
                      padding: EdgeInsets.all(
                        ResponsiveHelper.isDesktop(context) ? 20 : 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0x66ffffff), Color(0x44ffffff)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(title: 'Categories', padding: 0),
                          SizedBox(
                            height: ResponsiveHelper.isDesktop(context)
                                ? 16
                                : 12,
                          ),
                          SizedBox(
                            height: ResponsiveHelper.isDesktop(context)
                                ? 52
                                : 44,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: categories.length,
                              separatorBuilder: (_, __) => SizedBox(
                                width: ResponsiveHelper.isDesktop(context)
                                    ? 12
                                    : 8,
                              ),
                              itemBuilder: (context, index) {
                                return _CategoryChip(label: categories[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 24 : 16,
                    ),
                    _SectionHeader(title: 'Trending Now'),
                    SizedBox(
                      height: ResponsiveHelper.getAnimeCardHeight(context),
                      child: ListView.builder(
                        padding: ResponsiveHelper.getResponsivePadding(context),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: trending.length,
                        itemBuilder: (context, index) {
                          final item = trending[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < trending.length - 1 ? 12 : 0,
                            ),
                            child: _AnimeCard(
                              title: item.title,
                              imagePath: item.imagePath,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 20 : 12,
                    ),

                    // Top Anime section
                    _SectionHeader(title: 'Top Anime'),
                    SizedBox(height: 0),
                    _SeeAllButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TopAnimePage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getAnimeCardHeight(context),
                      child: ListView.builder(
                        padding: ResponsiveHelper.getResponsivePadding(context),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: trending.length,
                        itemBuilder: (context, index) {
                          final item = trending[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < trending.length - 1 ? 12 : 0,
                            ),
                            child: _AnimeCard(
                              title: item.title,
                              imagePath: item.imagePath,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 20 : 12,
                    ),

                    // Manga section
                    _SectionHeader(title: 'Manga'),
                    SizedBox(height: 0),
                    _SeeAllButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MangaPage()),
                        );
                      },
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getAnimeCardHeight(context),
                      child: ListView.builder(
                        padding: ResponsiveHelper.getResponsivePadding(context),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: trending.length,
                        itemBuilder: (context, index) {
                          final item = trending[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < trending.length - 1 ? 12 : 0,
                            ),
                            child: _AnimeCard(
                              title: item.title,
                              imagePath: item.imagePath,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 20 : 12,
                    ),

                    // Magazines section
                    _SectionHeader(title: 'Magazines'),
                    SizedBox(height: 0),
                    _SeeAllButton(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MagazinesPage(),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getAnimeCardHeight(context),
                      child: ListView.builder(
                        padding: ResponsiveHelper.getResponsivePadding(context),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: trending.length,
                        itemBuilder: (context, index) {
                          final item = trending[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < trending.length - 1 ? 12 : 0,
                            ),
                            child: _AnimeCard(
                              title: item.title,
                              imagePath: item.imagePath,
                            ),
                          );
                        },
                      ),
                    ),
                  ] else if (_selectedIndex == 1) ...[
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 16 : 12,
                    ),
                    _SearchBar(controller: _searchController),
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 16 : 12,
                    ),
                    _SectionHeader(title: 'Results'),
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 12 : 8,
                    ),
                    if (filteredTrending.isEmpty)
                      Padding(
                        padding: ResponsiveHelper.getResponsivePadding(context),
                        child: Text(
                          'No matches found',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              16,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        padding: ResponsiveHelper.getResponsivePadding(context),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredTrending.length,
                        itemBuilder: (context, index) {
                          final item = filteredTrending[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < filteredTrending.length - 1
                                  ? 12
                                  : 0,
                            ),
                            child: _SearchResultTile(
                              title: item.title,
                              imagePath: item.imagePath,
                            ),
                          );
                        },
                      ),
                  ] else ...[
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 16 : 12,
                    ),
                    Padding(
                      padding: ResponsiveHelper.getResponsivePadding(context),
                      child: Text(
                        'Favorites coming soon',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF43a047),
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.padding = 16});

  final String title;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 4, padding, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _SeeAllButton extends StatelessWidget {
  const _SeeAllButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final horizontal =
        ResponsiveHelper.getResponsivePadding(context).horizontal / 2;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: onTap,
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF43a047)),
          icon: const Icon(Icons.chevron_right),
          label: const Text('See all'),
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = ResponsiveHelper.getResponsivePadding(context).horizontal;
    final availableWidth = screenWidth - padding;

    // Calculate banner width based on available space
    final cardWidth = ResponsiveHelper.isDesktop(context)
        ? (availableWidth * 0.8).clamp(300.0, 500.0)
        : ResponsiveHelper.isTablet(context)
        ? (availableWidth * 0.85).clamp(250.0, 400.0)
        : (availableWidth * 0.9).clamp(200.0, 300.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: SizedBox(
          width: cardWidth,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.white,
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.black54,
                  size: ResponsiveHelper.getIconSize(context, 24),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isDesktop(context) ? 20 : 16,
        vertical: ResponsiveHelper.isDesktop(context) ? 14 : 12,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF66bb6a), Color(0xFF43a047)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 15),
        ),
      ),
    );
  }
}

class _AnimeCard extends StatelessWidget {
  const _AnimeCard({required this.title, required this.imagePath});

  final String title;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final cardWidth = ResponsiveHelper.getCardWidth(context, itemsPerRow: 1);

    return SizedBox(
      width: cardWidth,
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.white,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.black54,
                        size: ResponsiveHelper.getIconSize(context, 24),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: ResponsiveHelper.isDesktop(context) ? 6 : 4),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientSection extends StatelessWidget {
  const _GradientSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x66ffffff), Color(0x44ffffff)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _AnimeCardData {
  const _AnimeCardData(this.title, this.imagePath);
  final String title;
  final String imagePath;
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.title, required this.imagePath});

  final String title;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.isDesktop(context) ? 16 : 12,
          vertical: ResponsiveHelper.isDesktop(context) ? 8 : 6,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: ResponsiveHelper.isDesktop(context) ? 52 : 44,
            height: ResponsiveHelper.isDesktop(context) ? 52 : 44,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: ResponsiveHelper.isDesktop(context) ? 52 : 44,
              height: ResponsiveHelper.isDesktop(context) ? 52 : 44,
              color: Colors.white,
              child: Icon(
                Icons.image_not_supported,
                color: Colors.black54,
                size: ResponsiveHelper.getIconSize(context, 20),
              ),
            ),
          ),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _borderRadiusAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _shadowAnimation = Tween<double>(begin: 0.1, end: 0.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation =
        ColorTween(
          begin: Colors.white.withOpacity(0.9),
          end: Colors.white,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _borderRadiusAnimation = Tween<double>(begin: 25.0, end: 20.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });

    if (hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Padding(
            padding: ResponsiveHelper.getResponsivePadding(context),
            child: Container(
              height: ResponsiveHelper.getButtonHeight(context),
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(
                  _borderRadiusAnimation.value,
                ),
                border: _isFocused
                    ? Border.all(color: const Color(0xFF66bb6a), width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_shadowAnimation.value),
                    blurRadius: _isFocused ? 16 : 8,
                    offset: Offset(0, _isFocused ? 6 : 2),
                  ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                onTap: () => _onFocusChange(true),
                onSubmitted: (_) => _onFocusChange(false),
                onEditingComplete: () => _onFocusChange(false),
                onChanged: (_) {
                  // let parent listeners update results via setState
                  setState(() {});
                },
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
                decoration: InputDecoration(
                  hintText: 'Search anime...',
                  hintStyle: TextStyle(
                    color: Colors.black54,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      16,
                    ),
                  ),
                  prefixIcon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isFocused ? Icons.search : Icons.search_outlined,
                      key: ValueKey(_isFocused),
                      color: _isFocused
                          ? const Color(0xFF66bb6a)
                          : Colors.black54,
                      size: ResponsiveHelper.getIconSize(context, 24),
                    ),
                  ),
                  suffixIcon: widget.controller.text.isNotEmpty
                      ? AnimatedOpacity(
                          opacity: widget.controller.text.isNotEmpty
                              ? 1.0
                              : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: IconButton(
                            icon: const Icon(Icons.clear),
                            color: Colors.black54,
                            onPressed: () {
                              widget.controller.clear();
                              setState(() {});
                            },
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.isDesktop(context) ? 24 : 20,
                    vertical: ResponsiveHelper.isDesktop(context) ? 18 : 15,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
