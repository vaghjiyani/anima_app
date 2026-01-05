import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/anime.dart';
import '../services/jikan_api_service.dart';

/// Provider for managing search state and results
/// Implements debounced search to avoid excessive API calls
class SearchProvider extends ChangeNotifier {
  List<Anime> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';
  String? _error;

  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  // Getters
  List<Anime> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  String? get error => _error;
  bool get hasResults => _searchResults.isNotEmpty;

  /// Search for anime with debouncing
  /// Waits 500ms after user stops typing before making API call
  void searchAnime(String query) {
    _searchQuery = query.trim();

    // Cancel previous timer if exists
    _debounceTimer?.cancel();

    // Clear results if query is empty
    if (_searchQuery.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      _error = null;
      notifyListeners();
      return;
    }

    // Show loading state immediately
    _isSearching = true;
    _error = null;
    notifyListeners();

    // Start new debounce timer
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(_searchQuery);
    });
  }

  /// Perform the actual search API call
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    try {
      debugPrint('🔍 SearchProvider: Searching for "$query"...');
      final results = await JikanApiService.searchAnime(
        query: query,
        page: 1,
        limit: 25,
      );

      // Only update if this is still the current search query
      if (_searchQuery == query) {
        _searchResults = results;
        _error = null;
        debugPrint(
          '✅ SearchProvider: Found ${results.length} results for "$query"',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ SearchProvider: Error searching for "$query": $e');
      debugPrint('Stack trace: $stackTrace');

      if (_searchQuery == query) {
        _error = 'Failed to search: $e';
        _searchResults = [];
      }
    } finally {
      if (_searchQuery == query) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  /// Clear search results and query
  void clearSearch() {
    _debounceTimer?.cancel();
    _searchQuery = '';
    _searchResults = [];
    _isSearching = false;
    _error = null;
    notifyListeners();
    debugPrint('🗑️ SearchProvider: Cleared search');
  }

  /// Dispose timer when provider is disposed
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
