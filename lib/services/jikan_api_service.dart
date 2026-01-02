import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/anime.dart';
import '../models/api_exceptions.dart';
import 'dio_client.dart';

class JikanApiService {
  // Get Dio client instance
  static final _dio = DioClient.instance;

  // Get top anime
  static Future<List<Anime>> getTopAnime({int page = 1, int limit = 25}) async {
    try {
      final response = await _dio.get(
        '/top/anime',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> animeList = response.data['data'] ?? [];
        return animeList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw ClientException(
          message: 'Failed to load top anime',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Error fetching top anime: $e');
    }
  }

  // Get seasonal anime
  static Future<List<Anime>> getSeasonalAnime({
    int? year,
    String? season,
    int page = 1,
  }) async {
    try {
      final now = DateTime.now();
      final currentYear = year ?? now.year;
      final currentSeason = season ?? _getCurrentSeason(now.month);

      final response = await _dio.get(
        '/seasons/$currentYear/$currentSeason',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final List<dynamic> animeList = response.data['data'] ?? [];
        return animeList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw ClientException(
          message: 'Failed to load seasonal anime',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Error fetching seasonal anime: $e');
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
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final queryParams = {
        'q': query,
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
        if (status != null) 'status': status,
        if (minScore != null) 'min_score': minScore,
        if (genre != null) 'genres': genre,
      };

      final response = await _dio.get('/anime', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> animeList = response.data['data'] ?? [];
        return animeList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw ClientException(
          message: 'Failed to search anime',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Error searching anime: $e');
    }
  }

  // Get top manga
  static Future<List<Anime>> getTopManga({int page = 1, int limit = 25}) async {
    try {
      final response = await _dio.get(
        '/top/manga',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> mangaList = response.data['data'] ?? [];
        return mangaList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw ClientException(
          message: 'Failed to load top manga',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Error fetching top manga: $e');
    }
  }

  // Get anime by ID
  static Future<Anime> getAnimeById(int id) async {
    try {
      final response = await _dio.get('/anime/$id');

      if (response.statusCode == 200) {
        return Anime.fromJson(response.data['data']);
      } else {
        throw ClientException(
          message: 'Failed to load anime details',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Error fetching anime details: $e');
    }
  }

  // Get anime episodes
  static Future<List<Map<String, dynamic>>> getAnimeEpisodes(
    int animeId,
  ) async {
    try {
      final response = await _dio.get('/anime/$animeId/episodes');

      if (response.statusCode == 200) {
        final List<dynamic> episodesList = response.data['data'] ?? [];
        return episodesList.cast<Map<String, dynamic>>();
      } else {
        throw ClientException(
          message: 'Failed to load episodes',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Error fetching episodes: $e');
    }
  }

  // Get anime recommendations
  static Future<List<Anime>> getRecommendations({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/recommendations/anime',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final List<dynamic> recommendations = response.data['data'] ?? [];

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
        throw ClientException(
          message: 'Failed to load recommendations',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Error fetching recommendations: $e');
    }
  }

  // Get anime by genre
  static Future<List<Anime>> getAnimeByGenre({
    required int genreId,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/anime',
        queryParameters: {'genres': genreId, 'page': page},
      );

      if (response.statusCode == 200) {
        final List<dynamic> animeList = response.data['data'] ?? [];
        return animeList.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw ClientException(
          message: 'Failed to load anime by genre',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Error fetching anime by genre: $e');
    }
  }

  // Get magazines
  static Future<List<Map<String, dynamic>>> getMagazines({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/magazines',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final List<dynamic> magazinesList = response.data['data'] ?? [];
        return magazinesList.cast<Map<String, dynamic>>();
      } else {
        throw ClientException(
          message: 'Failed to load magazines',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Error fetching magazines: $e');
    }
  }

  // Helper method to get current season
  static String _getCurrentSeason(int month) {
    if (month >= 1 && month <= 3) return 'winter';
    if (month >= 4 && month <= 6) return 'spring';
    if (month >= 7 && month <= 9) return 'summer';
    return 'fall';
  }

  // Helper method to handle Dio errors
  static ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();

      case DioExceptionType.connectionError:
        return NetworkException();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          if (statusCode == 429) {
            return RateLimitException();
          } else if (statusCode >= 500) {
            return ServerException(
              statusCode: statusCode,
              data: error.response?.data,
            );
          } else if (statusCode >= 400) {
            return ClientException(
              message: error.response?.data?['message'] ?? 'Client error',
              statusCode: statusCode,
              data: error.response?.data,
            );
          }
        }
        return ServerException(message: error.message, statusCode: statusCode);

      case DioExceptionType.cancel:
        return ApiException(message: 'Request cancelled');

      case DioExceptionType.badCertificate:
        return ApiException(message: 'Bad certificate');

      case DioExceptionType.unknown:
      default:
        return ApiException(message: error.message ?? 'Unknown error occurred');
    }
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
