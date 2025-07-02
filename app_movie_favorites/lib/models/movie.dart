import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'movie.g.dart';

@HiveType(typeId: 0)
// ignore: must_be_immutable
class Movie extends HiveObject with EquatableMixin {
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
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Sem título',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String? ?? 'Desconhecido',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      genreIds: (json['genre_ids'] as List<dynamic>?)?.cast<int>() ?? const [],
    );
  }
  
  String get posterUrl => posterPath != null 
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';
      
  String get backdropUrl => backdropPath != null 
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : '';

  Movie copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    String? releaseDate,
    double? voteAverage,
    List<int>? genreIds,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      releaseDate: releaseDate ?? this.releaseDate,
      voteAverage: voteAverage ?? this.voteAverage,
      genreIds: genreIds ?? this.genreIds,
    );
  }

  @override
  List<Object?> get props => [id];
}