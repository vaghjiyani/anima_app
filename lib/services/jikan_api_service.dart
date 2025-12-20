import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/anime.dart';

class JikanApiService {
  static const String _baseUrl = 'https://api.jikan.moe/v4';

  // Rate limiting: Jikan API has a rate limit of 3 requests per second
  static DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(milliseconds: 350);

  // Helper method to respect rate limiting
  static Future<void> _respectRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        await Future.delayed(_minRequestInterval - timeSinceLastRequest);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  // Get top anime
  static Future<List<Anime>> getTopAnime({int page = 1, int limit = 25}) async {
    await _respectRateLimit();

    try {
      final url = '$_baseUrl/top/anime?page=$page&limit=$limit';
      debugPrint('📡 API Request: $url');

      final response = await http.get(Uri.parse(url));

      debugPrint('📥 API Response Status: ${response.statusCode}');
      debugPrint('📥 API Response Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> animeList = data['data'] ?? [];
        debugPrint('📊 Parsed ${animeList.length} anime from API');
        return animeList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load top anime: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('💥 Exception in getTopAnime: $e');
      throw Exception('Error fetching top anime: $e');
    }
  }

  // Get seasonal anime
  static Future<List<Anime>> getSeasonalAnime({
    int? year,
    String? season,
    int page = 1,
  }) async {
    await _respectRateLimit();

    try {
      final now = DateTime.now();
      final currentYear = year ?? now.year;
      final currentSeason = season ?? _getCurrentSeason(now.month);

      final response = await http.get(
        Uri.parse('$_baseUrl/seasons/$currentYear/$currentSeason?page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> animeList = data['data'] ?? [];
        return animeList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load seasonal anime: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching seasonal anime: $e');
    }
  }

  // Search anime
  static Future<List<Anime>> searchAnime({
    required String query,
    int page = 1,
    int limit = 25,
    String? type,
    String? status,
    double? minScore,
    String? genre,
  }) async {
    await _respectRateLimit();

    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final queryParams = {
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
        if (type != null) 'type': type,
        if (status != null) 'status': status,
        if (minScore != null) 'min_score': minScore.toString(),
        if (genre != null) 'genres': genre,
      };

      final uri = Uri.parse(
        '$_baseUrl/anime',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> animeList = data['data'] ?? [];
        return animeList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search anime: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching anime: $e');
    }
  }

  // Get top manga
  static Future<List<Anime>> getTopManga({int page = 1, int limit = 25}) async {
    await _respectRateLimit();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/top/manga?page=$page&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> mangaList = data['data'] ?? [];
        return mangaList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load top manga: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching top manga: $e');
    }
  }

  // Get anime by ID
  static Future<Anime> getAnimeById(int id) async {
    await _respectRateLimit();

    try {
      final response = await http.get(Uri.parse('$_baseUrl/anime/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Anime.fromJson(data['data']);
      } else {
        throw Exception('Failed to load anime details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching anime details: $e');
    }
  }

  // Get anime episodes
  static Future<List<Map<String, dynamic>>> getAnimeEpisodes(
    int animeId,
  ) async {
    await _respectRateLimit();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/anime/$animeId/episodes'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> episodesList = data['data'] ?? [];
        return episodesList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load episodes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching episodes: $e');
    }
  }

  // Get anime recommendations
  static Future<List<Anime>> getRecommendations({int page = 1}) async {
    await _respectRateLimit();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/recommendations/anime?page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> recommendations = data['data'] ?? [];

        // Extract anime from recommendations
        final List<Anime> animeList = [];
        for (var rec in recommendations) {
          if (rec['entry'] != null && rec['entry'].isNotEmpty) {
            for (var entry in rec['entry']) {
              try {
                animeList.add(Anime.fromJson(entry));
              } catch (e) {
                // Skip invalid entries
                continue;
              }
            }
          }
        }

        return animeList.take(25).toList();
      } else {
        throw Exception(
          'Failed to load recommendations: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching recommendations: $e');
    }
  }

  // Get anime by genre
  static Future<List<Anime>> getAnimeByGenre({
    required int genreId,
    int page = 1,
  }) async {
    await _respectRateLimit();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/anime?genres=$genreId&page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> animeList = data['data'] ?? [];
        return animeList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load anime by genre: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching anime by genre: $e');
    }
  }

  // Helper method to get current season
  static String _getCurrentSeason(int month) {
    if (month >= 1 && month <= 3) return 'winter';
    if (month >= 4 && month <= 6) return 'spring';
    if (month >= 7 && month <= 9) return 'summer';
    return 'fall';
  }

  // Genre IDs for reference
  static const Map<String, int> genreIds = {
    'Action': 1,
    'Adventure': 2,
    'Comedy': 4,
    'Drama': 8,
    'Fantasy': 10,
    'Romance': 22,
    'Sci-Fi': 24,
    'Slice of Life': 36,
    'Sports': 30,
    'Supernatural': 37,
    'Thriller': 41,
  };
}
