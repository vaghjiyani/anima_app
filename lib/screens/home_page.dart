import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../main.dart';
import '../widgets/app_sidebar.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';
import 'profile_page.dart';
import 'top_anime_page.dart';
import 'manga_page.dart';
import 'magazines_page.dart';
import 'search_page.dart';
import 'favorites_page.dart';
import '../services/jikan_api_service.dart';
import '../models/anime.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'anime_detail_page.dart';

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

  // API data
  List<Anime> _trendingAnime = [];
  List<Anime> _seasonalAnime = [];
  List<Anime> _topAnime = [];
  List<Anime> _searchResults = [];

  bool _isLoadingTrending = true;
  bool _isLoadingSeasonal = true;
  bool _isLoadingTop = true;
  bool _isSearching = false;

  String? _errorMessage;

  void _onBottomNavTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SearchPage()),
      );
      return;
    }
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FavoritesPage()),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedProfileImage();
    _loadAnimeData();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _loadAnimeData() async {
    await Future.wait([
      _loadTrendingAnime(),
      _loadSeasonalAnime(),
      _loadTopAnime(),
    ]);
  }

  Future<void> _loadTrendingAnime() async {
    try {
      setState(() {
        _isLoadingTrending = true;
        _errorMessage = null;
      });

      final anime = await JikanApiService.getSeasonalAnime(page: 1);

      if (mounted) {
        setState(() {
          _trendingAnime = anime.take(10).toList();
          _isLoadingTrending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load trending anime';
          _isLoadingTrending = false;
        });
      }
    }
  }

  Future<void> _loadSeasonalAnime() async {
    try {
      setState(() {
        _isLoadingSeasonal = true;
      });

      final anime = await JikanApiService.getSeasonalAnime(page: 1);

      if (mounted) {
        setState(() {
          _seasonalAnime = anime.take(10).toList();
          _isLoadingSeasonal = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSeasonal = false;
        });
      }
    }
  }

  Future<void> _loadTopAnime() async {
    try {
      setState(() {
        _isLoadingTop = true;
      });

      final anime = await JikanApiService.getTopAnime(page: 1, limit: 10);

      if (mounted) {
        setState(() {
          _topAnime = anime;
          _isLoadingTop = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTop = false;
        });
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    try {
      setState(() {
        _isSearching = true;
      });

      final results = await JikanApiService.searchAnime(
        query: query,
        limit: 20,
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
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
    // Use seasonal anime for featured banners
    final List<Anime> featuredAnime = _seasonalAnime.take(10).toList();

    final List<String> categories = const [
      'Action',
      'Romance',
      'Fantasy',
      'Comedy',
      'Sci-Fi',
      'Adventure',
      'Drama',
      'Slice of Life',
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Anima',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        actions: [
          IconButton(
            onPressed: () {
              final brightness = Theme.of(context).brightness;
              final mode = brightness == Brightness.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              appKey.currentState?.setThemeMode(mode);
            },
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
            tooltip: 'Toggle theme',
          ),
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
                : Icon(
                    Icons.person,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
            tooltip: 'Profile',
          ),
        ],
      ),
      drawer: const AppSidebar(),
      body: Container(
        width: double.infinity,
        decoration: AppColors.themedPrimaryGradient(context),
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
                    _SearchBar(
                      controller: _searchController,
                      onSubmitted: _performSearch,
                    ),
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 24 : 16,
                    ),

                    // Search Results Section
                    if (_isSearching || _searchResults.isNotEmpty) ...[
                      _SectionHeader(title: 'Search Results'),
                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 16 : 12,
                      ),

                      if (_isSearching)
                        SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      else if (_searchResults.isEmpty)
                        Container(
                          padding: EdgeInsets.all(
                            ResponsiveHelper.isDesktop(context) ? 32 : 24,
                          ),
                          child: Center(
                            child: Text(
                              'No results found',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white70
                                    : Colors.black54,
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      16,
                                    ),
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: ResponsiveHelper.getResponsivePadding(
                            context,
                          ),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            return _SearchResultTile(
                              anime: _searchResults[index],
                            );
                          },
                        ),

                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context) ? 32 : 24,
                      ),
                    ],

                    _SectionHeader(title: 'Featured'),
                    _isLoadingSeasonal
                        ? SizedBox(
                            height: ResponsiveHelper.getBannerHeight(context),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                        : featuredAnime.isEmpty
                        ? SizedBox(
                            height: 100,
                            child: Center(
                              child: Text(
                                'No featured anime available',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: ResponsiveHelper.getBannerHeight(context),
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(
                                    dragDevices: {
                                      PointerDeviceKind.touch,
                                      PointerDeviceKind.mouse,
                                      PointerDeviceKind.trackpad,
                                    },
                                    scrollbars: false,
                                  ),
                              child: ListView.builder(
                                padding: ResponsiveHelper.getResponsivePadding(
                                  context,
                                ),
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: featuredAnime.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: index < featuredAnime.length - 1
                                          ? 12
                                          : 0,
                                    ),
                                    child: _BannerCard(
                                      anime: featuredAnime[index],
                                    ),
                                  );
                                },
                              ),
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
                          // Scrollable categories with mouse wheel support
                          SizedBox(
                            height: ResponsiveHelper.isDesktop(context)
                                ? 56
                                : 48,
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(
                                    dragDevices: {
                                      PointerDeviceKind.touch,
                                      PointerDeviceKind.mouse,
                                      PointerDeviceKind.trackpad,
                                    },
                                    scrollbars: false,
                                  ),
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                itemCount: categories.length,
                                separatorBuilder: (_, __) => SizedBox(
                                  width: ResponsiveHelper.isDesktop(context)
                                      ? 12
                                      : 8,
                                ),
                                itemBuilder: (context, index) {
                                  return _CategoryChip(
                                    label: categories[index],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 24 : 16,
                    ),
                    _SectionHeader(title: 'Trending Now'),
                    _isLoadingTrending
                        ? SizedBox(
                            height: ResponsiveHelper.getAnimeCardHeight(
                              context,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                        : _trendingAnime.isEmpty
                        ? SizedBox(
                            height: 100,
                            child: Center(
                              child: Text(
                                'No trending anime available',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: ResponsiveHelper.getAnimeCardHeight(
                              context,
                            ),
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(
                                    dragDevices: {
                                      PointerDeviceKind.touch,
                                      PointerDeviceKind.mouse,
                                      PointerDeviceKind.trackpad,
                                    },
                                    scrollbars: false,
                                  ),
                              child: ListView.builder(
                                padding: ResponsiveHelper.getResponsivePadding(
                                  context,
                                ),
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _trendingAnime.length,
                                itemBuilder: (context, index) {
                                  final anime = _trendingAnime[index];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: index < _trendingAnime.length - 1
                                          ? ResponsiveHelper.isDesktop(context)
                                                ? 16
                                                : 12
                                          : 0,
                                    ),
                                    child: _AnimeCard(anime: anime),
                                  );
                                },
                              ),
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
                    _isLoadingTop
                        ? SizedBox(
                            height: ResponsiveHelper.getAnimeCardHeight(
                              context,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                        : SizedBox(
                            height: ResponsiveHelper.getAnimeCardHeight(
                              context,
                            ),
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(
                                    dragDevices: {
                                      PointerDeviceKind.touch,
                                      PointerDeviceKind.mouse,
                                      PointerDeviceKind.trackpad,
                                    },
                                    scrollbars: false,
                                  ),
                              child: ListView.builder(
                                padding: ResponsiveHelper.getResponsivePadding(
                                  context,
                                ),
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _topAnime.length,
                                itemBuilder: (context, index) {
                                  final anime = _topAnime[index];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: index < _topAnime.length - 1
                                          ? 12
                                          : 0,
                                    ),
                                    child: _AnimeCard(anime: anime),
                                  );
                                },
                              ),
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
                    _isLoadingSeasonal
                        ? SizedBox(
                            height: ResponsiveHelper.getAnimeCardHeight(
                              context,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                        : SizedBox(
                            height: ResponsiveHelper.getAnimeCardHeight(
                              context,
                            ),
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(
                                    dragDevices: {
                                      PointerDeviceKind.touch,
                                      PointerDeviceKind.mouse,
                                      PointerDeviceKind.trackpad,
                                    },
                                    scrollbars: false,
                                  ),
                              child: ListView.builder(
                                padding: ResponsiveHelper.getResponsivePadding(
                                  context,
                                ),
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _seasonalAnime.length,
                                itemBuilder: (context, index) {
                                  final anime = _seasonalAnime[index];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: index < _seasonalAnime.length - 1
                                          ? 12
                                          : 0,
                                    ),
                                    child: _AnimeCard(anime: anime),
                                  );
                                },
                              ),
                            ),
                          ),
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 20 : 12,
                    ),

                    // Magazines section
                    _SectionHeader(title: 'Magazines'),
                    _SeeAllButton(
                      onTap: () {
                        print('Magazines See All button tapped');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MagazinesPage(),
                          ),
                        );
                      },
                    ),
                    _isLoadingTop
                        ? SizedBox(
                            height: ResponsiveHelper.getAnimeCardHeight(
                              context,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                        : SizedBox(
                            height: ResponsiveHelper.getAnimeCardHeight(
                              context,
                            ),
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(
                                    dragDevices: {
                                      PointerDeviceKind.touch,
                                      PointerDeviceKind.mouse,
                                      PointerDeviceKind.trackpad,
                                    },
                                    scrollbars: false,
                                  ),
                              child: ListView.builder(
                                padding: ResponsiveHelper.getResponsivePadding(
                                  context,
                                ),
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _topAnime.take(5).length,
                                itemBuilder: (context, index) {
                                  final anime = _topAnime[index];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: index < 4 ? 12 : 0,
                                    ),
                                    child: _AnimeCard(anime: anime),
                                  );
                                },
                              ),
                            ),
                          ),
                  ] else if (_selectedIndex == 1) ...[
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 16 : 12,
                    ),
                    _SearchBar(
                      controller: _searchController,
                      onSubmitted: _performSearch,
                    ),
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 16 : 12,
                    ),
                    _SectionHeader(title: 'Results'),
                    SizedBox(
                      height: ResponsiveHelper.isDesktop(context) ? 12 : 8,
                    ),
                    if (_isSearching)
                      Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    else if (_searchResults.isEmpty)
                      Padding(
                        padding: ResponsiveHelper.getResponsivePadding(context),
                        child: Text(
                          'No matches found',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.black54,
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
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final anime = _searchResults[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < _searchResults.length - 1
                                  ? 12
                                  : 0,
                            ),
                            child: _SearchResultTile(anime: anime),
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
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
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
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white54
            : Colors.black54,
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
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
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
  const _BannerCard({required this.anime});

  final Anime anime;

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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimeDetailPage(anime: anime),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: SizedBox(
            width: cardWidth,
            child: anime.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: anime.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                          size: ResponsiveHelper.getIconSize(context, 24),
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[800],
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
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
  const _AnimeCard({required this.anime});

  final Anime anime;

  @override
  Widget build(BuildContext context) {
    final cardWidth = ResponsiveHelper.getCardWidth(context, itemsPerRow: 1);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimeDetailPage(anime: anime),
          ),
        );
      },
      child: SizedBox(
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
                  child: anime.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: anime.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                                size: ResponsiveHelper.getIconSize(context, 24),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: ResponsiveHelper.getIconSize(context, 24),
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.isDesktop(context) ? 6 : 4),
              Expanded(
                child: Text(
                  anime.displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Removed unused _GradientSection widget and _AnimeCardData class

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.anime});

  final Anime anime;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnimeDetailPage(anime: anime),
            ),
          );
        },
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.isDesktop(context) ? 16 : 12,
          vertical: ResponsiveHelper.isDesktop(context) ? 8 : 6,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: anime.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: anime.imageUrl!,
                  width: ResponsiveHelper.isDesktop(context) ? 52 : 44,
                  height: ResponsiveHelper.isDesktop(context) ? 52 : 44,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: ResponsiveHelper.isDesktop(context) ? 52 : 44,
                    height: ResponsiveHelper.isDesktop(context) ? 52 : 44,
                    color: Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: ResponsiveHelper.isDesktop(context) ? 52 : 44,
                    height: ResponsiveHelper.isDesktop(context) ? 52 : 44,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                  ),
                )
              : Container(
                  width: ResponsiveHelper.isDesktop(context) ? 52 : 44,
                  height: ResponsiveHelper.isDesktop(context) ? 52 : 44,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: ResponsiveHelper.getIconSize(context, 20),
                  ),
                ),
        ),
        title: Text(
          anime.displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
          ),
        ),
        subtitle: anime.score != null
            ? Text(
                '⭐ ${anime.scoreString}',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                ),
              )
            : null,
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.controller, this.onSubmitted});

  final TextEditingController controller;
  final Function(String)? onSubmitted;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  bool _isFocused = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Use theme primary color for search box background
      final primaryColor = Theme.of(context).colorScheme.primary;
      _colorAnimation =
          ColorTween(
            begin: primaryColor.withOpacity(0.9),
            end: primaryColor,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );
      _isInitialized = true;
    }
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
        return Padding(
          padding: ResponsiveHelper.getResponsivePadding(context),
          child: Container(
            height: ResponsiveHelper.isDesktop(context) ? 56 : 52,
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(16),
              border: _isFocused
                  ? Border.all(color: Colors.white, width: 2)
                  : Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: _isFocused
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.15),
                  blurRadius: _isFocused ? 12 : 6,
                  offset: Offset(0, _isFocused ? 4 : 2),
                  spreadRadius: _isFocused ? 1 : 0,
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              cursorColor: Colors.white,
              onTap: () => _onFocusChange(true),
              onSubmitted: (value) {
                _onFocusChange(false);
                widget.onSubmitted?.call(value);
              },
              onEditingComplete: () => _onFocusChange(false),
              onChanged: (_) {
                setState(() {});
              },
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search for anime, manga...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 4, right: 8),
                  child: Icon(
                    _isFocused ? Icons.search : Icons.search_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        color: Colors.white,
                        onPressed: () {
                          widget.controller.clear();
                          setState(() {});
                        },
                        tooltip: 'Clear',
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: ResponsiveHelper.isDesktop(context) ? 16 : 14,
                ),
                isDense: true,
              ),
            ),
          ),
        );
      },
    );
  }
}
