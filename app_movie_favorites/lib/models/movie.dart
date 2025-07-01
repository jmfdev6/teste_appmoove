import 'package:hive/hive.dart';

part 'movie.g.dart';

@HiveType(typeId: 0)
class Movie extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String overview;
  
  @HiveField(3)
  final String? posterPath;
  
  @HiveField(4)
  final String? backdropPath;
  
  @HiveField(5)
  final String releaseDate;
  
  @HiveField(6)
  final double voteAverage;
  
  @HiveField(7)
  final List<int> genreIds;
  
  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.genreIds,
  });
  
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      genreIds: List<int>.from(json['genre_ids'] ?? []),
    );
  }
  
  String get posterUrl => posterPath != null 
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';
      
  String get backdropUrl => backdropPath != null 
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';
}
