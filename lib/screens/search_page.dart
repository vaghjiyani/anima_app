import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../models/anime.dart';
import '../services/jikan_api_service.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_app_bar.dart';
import 'anime_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<Anime> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  // Filter options
  String? _selectedType;
  String? _selectedStatus;
  double? _minScore;

  final List<String> _types = ['TV', 'Movie', 'OVA', 'Special', 'ONA'];
  final List<String> _statuses = ['Airing', 'Complete', 'Upcoming'];
  final List<String> _popularSearches = [
    'Naruto',
    'One Piece',
    'Attack on Titan',
    'Demon Slayer',
    'My Hero Academia',
    'Death Note',
    'Fullmetal Alchemist',
    'Jujutsu Kaisen',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final results = await JikanApiService.searchAnime(
        query: query,
        type: _selectedType?.toLowerCase(),
        status: _selectedStatus?.toLowerCase(),
        minScore: _minScore,
        limit: 25,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _minScore = null;
    });
    if (_searchController.text.isNotEmpty) {
      _performSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientScaffold(
      appBarTitle: 'Search Anime',
      body: Container(
        decoration: AppColors.themedPrimaryGradient(context),
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: ResponsiveHelper.getResponsivePadding(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search for anime...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 15,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults = [];
                                  _hasSearched = false;
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Filters
              _buildFilters(isDark),

              const SizedBox(height: 16),

              // Results
              Expanded(child: _buildContent(isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
          scrollbars: false,
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            // Type Filter
            _buildFilterChip(
              label: _selectedType ?? 'Type',
              icon: Icons.tv,
              isSelected: _selectedType != null,
              onTap: () => _showTypeDialog(),
            ),
            const SizedBox(width: 8),

            // Status Filter
            _buildFilterChip(
              label: _selectedStatus ?? 'Status',
              icon: Icons.info_outline,
              isSelected: _selectedStatus != null,
              onTap: () => _showStatusDialog(),
            ),
            const SizedBox(width: 8),

            // Score Filter
            _buildFilterChip(
              label: _minScore != null ? 'Score ≥ $_minScore' : 'Min Score',
              icon: Icons.star_outline,
              isSelected: _minScore != null,
              onTap: () => _showScoreDialog(),
            ),
            const SizedBox(width: 8),

            // Clear Filters
            if (_selectedType != null ||
                _selectedStatus != null ||
                _minScore != null)
              _buildFilterChip(
                label: 'Clear',
                icon: Icons.clear,
                isSelected: false,
                onTap: _clearFilters,
                color: Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? Theme.of(context).colorScheme.primary)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? Theme.of(context).colorScheme.primary)
                : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (!_hasSearched) {
      return _buildPopularSearches(isDark);
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return _buildSearchResults(isDark);
  }

  Widget _buildPopularSearches(bool isDark) {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((search) {
              return InkWell(
                onTap: () {
                  _searchController.text = search;
                  _performSearch();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        search,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Text(
            'Search Tips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildTip(
            icon: Icons.search,
            text: 'Type anime name and press Enter',
            isDark: isDark,
          ),
          _buildTip(
            icon: Icons.filter_list,
            text: 'Use filters to narrow down results',
            isDark: isDark,
          ),
          _buildTip(
            icon: Icons.star,
            text: 'Filter by minimum score for quality anime',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTip({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            const SizedBox(height: 16),
            Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or filters',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(bool isDark) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      child: ListView.builder(
        padding: ResponsiveHelper.getResponsivePadding(context),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final anime = _searchResults[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAnimeCard(anime, isDark),
          );
        },
      ),
    );
  }

  Widget _buildAnimeCard(Anime anime, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AnimeDetailPage(anime: anime)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: anime.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: anime.imageUrl!,
                      width: 100,
                      height: 140,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 100,
                        height: 140,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 100,
                        height: 140,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                        ),
                      ),
                    )
                  : Container(
                      width: 100,
                      height: 140,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                      ),
                    ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.displayTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (anime.type != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          anime.type!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (anime.score != null) ...[
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            anime.scoreString,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (anime.episodes != null) ...[
                          Icon(
                            Icons.tv,
                            size: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${anime.episodes} eps',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (anime.synopsis != null &&
                        anime.synopsis!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        anime.synopsis!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Types'),
              onTap: () {
                setState(() => _selectedType = null);
                Navigator.pop(context);
                if (_searchController.text.isNotEmpty) _performSearch();
              },
            ),
            ..._types.map(
              (type) => ListTile(
                title: Text(type),
                onTap: () {
                  setState(() => _selectedType = type);
                  Navigator.pop(context);
                  if (_searchController.text.isNotEmpty) _performSearch();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Statuses'),
              onTap: () {
                setState(() => _selectedStatus = null);
                Navigator.pop(context);
                if (_searchController.text.isNotEmpty) _performSearch();
              },
            ),
            ..._statuses.map(
              (status) => ListTile(
                title: Text(status),
                onTap: () {
                  setState(() => _selectedStatus = status);
                  Navigator.pop(context);
                  if (_searchController.text.isNotEmpty) _performSearch();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Minimum Score'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Any Score'),
              onTap: () {
                setState(() => _minScore = null);
                Navigator.pop(context);
                if (_searchController.text.isNotEmpty) _performSearch();
              },
            ),
            ...[7.0, 7.5, 8.0, 8.5, 9.0].map(
              (score) => ListTile(
                title: Text('$score and above'),
                onTap: () {
                  setState(() => _minScore = score);
                  Navigator.pop(context);
                  if (_searchController.text.isNotEmpty) _performSearch();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
