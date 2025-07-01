import 'package:app_movie_favorites/services/tmdb_services.dart';

import '../models/movie.dart';
import 'package:hive/hive.dart';

class MovieRepository {
  final TMDBService _tmdbService;
  final Box<Movie> _favoritesBox = Hive.box<Movie>('favorites');
  final Box<double> _ratingsBox = Hive.box<double>('ratings'); // ← CORREÇÃO: tipo específico
  
  MovieRepository(this._tmdbService);
  
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    return await _tmdbService.getPopularMovies(page: page);
  }
  
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    return await _tmdbService.searchMovies(query, page: page);
  }
  
  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    return await _tmdbService.getMovieDetails(movieId);
  }
  
  Future<List<Map<String, dynamic>>> getMovieVideos(int movieId) async {
    return await _tmdbService.getMovieVideos(movieId);
  }
  
  List<Movie> getFavoriteMovies() {
    return _favoritesBox.values.toList();
  }
  
  bool isFavorite(int movieId) {
    return _favoritesBox.containsKey(movieId);
  }
  
  Future<void> toggleFavorite(Movie movie) async {
    if (isFavorite(movie.id)) {
      await _favoritesBox.delete(movie.id);
    } else {
      await _favoritesBox.put(movie.id, movie);
    }
  }
  
  double? getMovieRating(int movieId) {
    return _ratingsBox.get(movieId); // Agora retorna double? corretamente
  }
  
  Future<void> rateMovie(int movieId, double rating) async {
    await _ratingsBox.put(movieId, rating); // Agora aceita apenas double
  }
}