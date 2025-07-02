import 'package:hive/hive.dart';
import '../models/movie.dart';
import '../services/tmdb_services.dart';
// ignore: depend_on_referenced_packages
import 'package:rxdart/rxdart.dart';

class MovieRepository {
  final TMDBService _tmdbService;
  final Box<Movie> _favoritesBox;
  final Box<double> _ratingsBox;
  final BehaviorSubject<List<Movie>> _favoritesStream;

  MovieRepository(this._tmdbService)
      : _favoritesBox = Hive.box<Movie>('favorites'),
        _ratingsBox = Hive.box<double>('ratings'),
        _favoritesStream = BehaviorSubject.seeded(Hive.box<Movie>('favorites').values.toList()) {
    _favoritesBox.watch().listen((_) {
      _favoritesStream.add(_favoritesBox.values.toList());
    });
  }

  Stream<List<Movie>> get favoritesStream => _favoritesStream.stream;

  Future<List<Movie>> getPopularMovies({int page = 1}) => 
      _tmdbService.getPopularMovies(page: page);

  Future<List<Movie>> searchMovies(String query, {int page = 1}) => 
      _tmdbService.searchMovies(query, page: page);

  Future<Map<String, dynamic>> getMovieDetails(int movieId) => 
      _tmdbService.getMovieDetails(movieId);

  Future<List<Map<String, dynamic>>> getMovieVideos(int movieId) => 
      _tmdbService.getMovieVideos(movieId);

  List<Movie> getFavoriteMovies() => _favoritesBox.values.toList();

  bool isFavorite(int movieId) => _favoritesBox.containsKey(movieId);

  Future<void> toggleFavorite(Movie movie) async {
    isFavorite(movie.id) 
        ? await _favoritesBox.delete(movie.id)
        : await _favoritesBox.put(movie.id, movie);
  }

  double? getMovieRating(int movieId) => _ratingsBox.get(movieId);

  Future<void> rateMovie(int movieId, double rating) async {
    await _ratingsBox.put(movieId, rating);
  }

  void dispose() {
    _favoritesStream.close();
  }
}