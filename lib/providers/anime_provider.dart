import 'package:flutter/foundation.dart';
import '../models/anime.dart';
import '../services/jikan_api_service.dart';

/// Provider for managing anime data across the app
/// Handles fetching and caching of trending, seasonal, top, and genre-specific anime
class AnimeProvider extends ChangeNotifier {
  // Anime data lists
  List<Anime> _trendingAnime = [];
  List<Anime> _seasonalAnime = [];
  List<Anime> _topAnime = [];
  Map<int, List<Anime>> _genreAnimeCache = {}; // Cache by genre ID

  // Loading states
  bool _isLoadingTrending = false;
  bool _isLoadingSeasonal = false;
  bool _isLoadingTop = false;
  bool _isLoadingGenre = false;

  // Error states
  String? _errorTrending;
  String? _errorSeasonal;
  String? _errorTop;
  String? _errorGenre;

  // Getters for anime data
  List<Anime> get trendingAnime => _trendingAnime;
  List<Anime> get seasonalAnime => _seasonalAnime;
  List<Anime> get topAnime => _topAnime;

  // Getters for loading states
  bool get isLoadingTrending => _isLoadingTrending;
  bool get isLoadingSeasonal => _isLoadingSeasonal;
  bool get isLoadingTop => _isLoadingTop;
  bool get isLoadingGenre => _isLoadingGenre;

  // Getters for error states
  String? get errorTrending => _errorTrending;
  String? get errorSeasonal => _errorSeasonal;
  String? get errorTop => _errorTop;
  String? get errorGenre => _errorGenre;

  /// Load all anime data (trending, seasonal, top)
  /// Call this once when the app starts
  Future<void> loadAllAnime() async {
    await loadTrendingAnime();
    await Future.delayed(const Duration(milliseconds: 1500)); // Extra delay
    await loadSeasonalAnime();
    await Future.delayed(const Duration(milliseconds: 1500)); // Extra delay
    await loadTopAnime();
  }

  /// Load trending anime from API
  Future<void> loadTrendingAnime() async {
    // Don't reload if already loaded
    if (_trendingAnime.isNotEmpty) return;

    _isLoadingTrending = true;
    _errorTrending = null;
    notifyListeners();

    try {
      debugPrint('🔄 AnimeProvider: Loading trending anime...');
      _trendingAnime = await JikanApiService.getTopAnime(page: 1, limit: 25);
      debugPrint(
        '✅ AnimeProvider: Loaded ${_trendingAnime.length} trending anime',
      );
      _errorTrending = null;
    } catch (e, stackTrace) {
      debugPrint('❌ AnimeProvider: Error loading trending anime: $e');
      debugPrint('Stack trace: $stackTrace');
      _errorTrending = 'Failed to load trending anime: $e';
    } finally {
      _isLoadingTrending = false;
      notifyListeners();
    }
  }

  /// Load seasonal anime from API
  Future<void> loadSeasonalAnime() async {
    // Don't reload if already loaded
    if (_seasonalAnime.isNotEmpty) return;

    _isLoadingSeasonal = true;
    _errorSeasonal = null;
    notifyListeners();

    try {
      debugPrint('🔄 AnimeProvider: Loading seasonal anime...');
      _seasonalAnime = await JikanApiService.getSeasonalAnime(page: 1);
      debugPrint(
        '✅ AnimeProvider: Loaded ${_seasonalAnime.length} seasonal anime',
      );
      _errorSeasonal = null;
    } catch (e, stackTrace) {
      debugPrint('❌ AnimeProvider: Error loading seasonal anime: $e');
      debugPrint('Stack trace: $stackTrace');
      _errorSeasonal = 'Failed to load seasonal anime: $e';
    } finally {
      _isLoadingSeasonal = false;
      notifyListeners();
    }
  }

  /// Load top anime from API
  Future<void> loadTopAnime() async {
    // Don't reload if already loaded
    if (_topAnime.isNotEmpty) return;

    _isLoadingTop = true;
    _errorTop = null;
    notifyListeners();

    try {
      debugPrint('🔄 AnimeProvider: Loading top anime...');
      _topAnime = await JikanApiService.getTopAnime(page: 1, limit: 25);
      debugPrint('✅ AnimeProvider: Loaded ${_topAnime.length} top anime');
      _errorTop = null;
    } catch (e, stackTrace) {
      debugPrint('❌ AnimeProvider: Error loading top anime: $e');
      debugPrint('Stack trace: $stackTrace');
      _errorTop = 'Failed to load top anime: $e';
    } finally {
      _isLoadingTop = false;
      notifyListeners();
    }
  }

  /// Load anime by genre with caching
  Future<List<Anime>> loadGenreAnime(int genreId) async {
    // Return cached data if available
    if (_genreAnimeCache.containsKey(genreId)) {
      debugPrint('📦 AnimeProvider: Returning cached genre $genreId anime');
      return _genreAnimeCache[genreId]!;
    }

    _isLoadingGenre = true;
    _errorGenre = null;
    notifyListeners();

    try {
      debugPrint('🔄 AnimeProvider: Loading genre $genreId anime...');
      final anime = await JikanApiService.getAnimeByGenre(
        genreId: genreId,
        page: 1,
      );
      debugPrint(
        '✅ AnimeProvider: Loaded ${anime.length} genre $genreId anime',
      );

      // Cache the results
      _genreAnimeCache[genreId] = anime;
      _errorGenre = null;

      return anime;
    } catch (e, stackTrace) {
      debugPrint('❌ AnimeProvider: Error loading genre $genreId anime: $e');
      debugPrint('Stack trace: $stackTrace');
      _errorGenre = 'Failed to load genre anime: $e';
      return [];
    } finally {
      _isLoadingGenre = false;
      notifyListeners();
    }
  }

  /// Force refresh all anime data
  Future<void> refreshAllAnime() async {
    _trendingAnime = [];
    _seasonalAnime = [];
    _topAnime = [];
    _genreAnimeCache.clear();
    await loadAllAnime();
  }

  /// Clear all cached data
  void clearCache() {
    _trendingAnime = [];
    _seasonalAnime = [];
    _topAnime = [];
    _genreAnimeCache.clear();
    notifyListeners();
  }
}
