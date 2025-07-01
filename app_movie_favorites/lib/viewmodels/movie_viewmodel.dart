import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../repositories/tmdb_repository.dart';

class MovieViewModel extends ChangeNotifier {
  MovieRepository? _repository;

  List<Movie> _popularMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _favoriteMovies = [];
  bool _isLoading = false;
  String? _error;

  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get searchResults => _searchResults;
  List<Movie> get favoriteMovies => _favoriteMovies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  MovieRepository? get repository => _repository;

  Movie? get featuredMovie =>
      _popularMovies.isNotEmpty ? _popularMovies.first : null;

  void updateRepository(MovieRepository repository) {
    _repository = repository;
    loadPopularMovies();
    loadFavoriteMovies();
  }

  Future<void> loadPopularMovies() async {
    if (_repository == null) return;

    _setLoading(true);
    try {
      _popularMovies = await _repository!.getPopularMovies();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> searchMovies(String query) async {
    if (_repository == null) {
      return;
    }

    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      _searchResults = await _repository!.searchMovies(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _searchResults = [];
    }
    _setLoading(false);
  }

  void loadFavoriteMovies() {
    if (_repository == null) return;
    _favoriteMovies = _repository!.getFavoriteMovies();
    notifyListeners();
  }

  Future<void> toggleFavorite(Movie movie) async {
    if (_repository == null) return;

    await _repository!.toggleFavorite(movie);
    loadFavoriteMovies();
  }

  bool isFavorite(int movieId) {
    return _repository?.isFavorite(movieId) ?? false;
  }

  Future<void> rateMovie(int movieId, double rating) async {
    if (_repository == null) return;
    await _repository!.rateMovie(movieId, rating);
  }

  double? getMovieRating(int movieId) {
    return _repository?.getMovieRating(movieId);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
