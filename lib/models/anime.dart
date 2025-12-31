import 'package:intl/intl.dart';

class Anime {
  final int id;
  final String title;
  final String? titleEnglish;
  final String? titleJapanese;
  final String? imageUrl;
  final String? synopsis;
  final double? score;
  final int? episodes;
  final String? status;
  final String? type;
  final List<String> genres;
  final int? year;
  final String? season;
  final int? rank;
  final int? popularity;

  Anime({
    required this.id,
    required this.title,
    this.titleEnglish,
    this.titleJapanese,
    this.imageUrl,
    this.synopsis,
    this.score,
    this.episodes,
    this.status,
    this.type,
    this.genres = const [],
    this.year,
    this.season,
    this.rank,
    this.popularity,
  });

  int get malId => id;

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['mal_id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      titleEnglish: json['title_english'],
      titleJapanese: json['title_japanese'],
      imageUrl:
          json['images']?['jpg']?['large_image_url'] ??
          json['images']?['jpg']?['image_url'],
      synopsis: json['synopsis'],
      score: json['score']?.toDouble(),
      episodes: json['episodes'],
      status: json['status'],
      type: json['type'],
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((g) => g['name'] as String)
              .toList() ??
          [],
      year: json['year'],
      season: json['season'],
      rank: json['rank'],
      popularity: json['popularity'],
    );
  }

  factory Anime.fromFavorite(Map<String, dynamic> data) {
    return Anime(
      id: data['malId'] ?? 0,
      title: data['title'] ?? 'Unknown',
      imageUrl: data['imageUrl'],
      score: data['score']?.toDouble(),
      episodes: data['episodes'],
      status: data['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mal_id': id,
      'title': title,
      'title_english': titleEnglish,
      'title_japanese': titleJapanese,
      'images': {
        'jpg': {'image_url': imageUrl},
      },
      'synopsis': synopsis,
      'score': score,
      'episodes': episodes,
      'status': status,
      'type': type,
      'genres': genres.map((g) => {'name': g}).toList(),
      'year': year,
      'season': season,
      'rank': rank,
      'popularity': popularity,
    };
  }

  String get displayTitle => titleEnglish ?? title;

  String get genresString => genres.join(', ');

  String get scoreString {
    if (score == null) return 'N/A';
    final formatter = NumberFormat('#0.00');
    return formatter.format(score);
  }

  String get episodesString =>
      episodes != null ? '$episodes episodes' : 'Unknown';
}
