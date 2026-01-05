import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime.dart';

/// Provider for managing favorite anime with persistence
/// Favorites are saved to SharedPreferences and persist across app restarts
class FavoritesProvider extends ChangeNotifier {
  static const String _favoritesKey = 'favorite_anime';

  List<Anime> _favorites = [];
  bool _isLoading = true;

  // Getters
  List<Anime> get favorites => _favorites;
  bool get isLoading => _isLoading;
  int get favoritesCount => _favorites.length;

  /// Initialize and load favorites from storage
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🔄 FavoritesProvider: Loading favorites from storage...');
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      _favorites = favoritesJson
          .map((jsonStr) => Anime.fromJson(json.decode(jsonStr)))
          .toList();

      debugPrint('✅ FavoritesProvider: Loaded ${_favorites.length} favorites');
    } catch (e) {
      debugPrint('❌ FavoritesProvider: Error loading favorites: $e');
      _favorites = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save favorites to storage
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favorites
          .map((anime) => json.encode(anime.toJson()))
          .toList();

      await prefs.setStringList(_favoritesKey, favoritesJson);
      debugPrint('💾 FavoritesProvider: Saved ${_favorites.length} favorites');
    } catch (e) {
      debugPrint('❌ FavoritesProvider: Error saving favorites: $e');
    }
  }

  /// Check if an anime is in favorites
  bool isFavorite(int animeId) {
    return _favorites.any((anime) => anime.malId == animeId);
  }

  /// Add anime to favorites
  Future<void> addFavorite(Anime anime) async {
    if (!isFavorite(anime.malId)) {
      _favorites.add(anime);
      await _saveFavorites();
      notifyListeners();
      debugPrint('⭐ FavoritesProvider: Added ${anime.title} to favorites');
    }
  }

  /// Remove anime from favorites
  Future<void> removeFavorite(int animeId) async {
    final removedAnime = _favorites.firstWhere(
      (anime) => anime.malId == animeId,
      orElse: () => _favorites.first,
    );

    _favorites.removeWhere((anime) => anime.malId == animeId);
    await _saveFavorites();
    notifyListeners();
    debugPrint(
      '💔 FavoritesProvider: Removed ${removedAnime.title} from favorites',
    );
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(Anime anime) async {
    if (isFavorite(anime.malId)) {
      await removeFavorite(anime.malId);
    } else {
      await addFavorite(anime);
    }
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    _favorites.clear();
    await _saveFavorites();
    notifyListeners();
    debugPrint('🗑️ FavoritesProvider: Cleared all favorites');
  }

  /// Get favorite by ID
  Anime? getFavoriteById(int animeId) {
    try {
      return _favorites.firstWhere((anime) => anime.malId == animeId);
    } catch (e) {
      return null;
    }
  }
}
