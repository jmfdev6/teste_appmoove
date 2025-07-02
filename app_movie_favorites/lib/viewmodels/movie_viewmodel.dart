import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';
import '../services/tmdb_services.dart';

class MovieState {
  final List<Movie> popularMovies;
  final List<Movie> searchResults;
  final List<Movie> favoriteMovies;
  final Map<String, dynamic>? currentMovieDetails;
  final List<Map<String, dynamic>> currentMovieVideos;
  final String? errorMessage;
  final String? movieDetailError;
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isMovieDetailLoading;
   Movie? get featuredMovie => popularMovies.isNotEmpty 
      ? popularMovies.first 
      : null;

  MovieState({
    this.popularMovies = const [],
    this.searchResults = const [],
    this.favoriteMovies = const [],
    this.currentMovieDetails,
    this.currentMovieVideos = const [],
    this.errorMessage,
    this.movieDetailError,
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isMovieDetailLoading = false,
  });

  MovieState copyWith({
    List<Movie>? popularMovies,
    List<Movie>? searchResults,
    List<Movie>? favoriteMovies,
    Map<String, dynamic>? currentMovieDetails,
    List<Map<String, dynamic>>? currentMovieVideos,
    String? errorMessage,
    String? movieDetailError,
    int? currentPage,
    int? totalPages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isMovieDetailLoading,
  }) {
    return MovieState(
      popularMovies: popularMovies ?? this.popularMovies,
      searchResults: searchResults ?? this.searchResults,
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
      currentMovieDetails: currentMovieDetails ?? this.currentMovieDetails,
      currentMovieVideos: currentMovieVideos ?? this.currentMovieVideos,
      errorMessage: errorMessage,
      movieDetailError: movieDetailError,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMovieDetailLoading: isMovieDetailLoading ?? this.isMovieDetailLoading,
    );
  }
}

class MovieViewModel extends ChangeNotifier {
  final MovieRepository _repository;
  MovieState _state = MovieState();
  StreamSubscription? _favoritesSubscription;

  MovieState get state => _state;

  MovieViewModel({required MovieRepository repository})
      : _repository = repository {
    _init();
  }

  void _init() {
    _loadInitialData();
    _favoritesSubscription = _repository.favoritesStream.listen((favorites) {
      _updateFavorites(favorites);
    });
  }

  Future<void> _loadInitialData() async {
    await loadPopularMovies();
    _updateFavorites(_repository.getFavoriteMovies());
  }

  void _updateState(MovieState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _updateFavorites(List<Movie> favorites) {
    _updateState(_state.copyWith(favoriteMovies: favorites));
  }

  Future<void> loadPopularMovies({bool reset = true}) async {
    if (_state.isLoading || _state.isLoadingMore) return;
    
    _updateState(_state.copyWith(
      isLoading: reset,
      isLoadingMore: !reset,
      errorMessage: null,
    ));

    try {
      final movies = await _repository.getPopularMovies(
        page: reset ? 1 : _state.currentPage + 1,
      );
      
      _updateState(_state.copyWith(
        popularMovies: reset ? movies : [..._state.popularMovies, ...movies],
        currentPage: reset ? 1 : _state.currentPage + 1,
      ));
    } on TMDBException catch (e) {
      _updateState(_state.copyWith(
        errorMessage: 'Erro ao carregar filmes: ${e.message}',
      ));
    } finally {
      _updateState(_state.copyWith(
        isLoading: false,
        isLoadingMore: false,
      ));
    }
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _updateState(_state.copyWith(searchResults: []));
      return;
    }

    _updateState(_state.copyWith(
      isLoading: true,
      errorMessage: null,
    ));

    try {
      final results = await _repository.searchMovies(query);
      _updateState(_state.copyWith(searchResults: results));
    } on TMDBException catch (e) {
      _updateState(_state.copyWith(
        errorMessage: 'Erro na pesquisa: ${e.message}',
        searchResults: [],
      ));
    } finally {
      _updateState(_state.copyWith(isLoading: false));
    }
  }

  Future<void> loadMovieDetails(int movieId) async {
    _updateState(_state.copyWith(
      isMovieDetailLoading: true,
      movieDetailError: null,
    ));

    try {
      final details = await _repository.getMovieDetails(movieId);
      final videos = await _repository.getMovieVideos(movieId);
      
      _updateState(_state.copyWith(
        currentMovieDetails: details,
        currentMovieVideos: videos,
      ));
    } on TMDBException catch (e) {
      _updateState(_state.copyWith(
        movieDetailError: 'Erro ao carregar detalhes: ${e.message}',
      ));
    } finally {
      _updateState(_state.copyWith(isMovieDetailLoading: false));
    }
  }

  Future<void> toggleFavorite(Movie movie) async {
    try {
      await _repository.toggleFavorite(movie);
    } on TMDBException catch (e) {
      _updateState(_state.copyWith(
        errorMessage: 'Erro ao favoritar: ${e.message}',
      ));
    }
  }

  Future<void> rateMovie(int movieId, double rating) async {
    try {
      await _repository.rateMovie(movieId, rating);
    } on TMDBException catch (e) {
      _updateState(_state.copyWith(
        errorMessage: 'Erro ao avaliar: ${e.message}',
      ));
    }
  }

  bool isFavorite(int movieId) => _repository.isFavorite(movieId);
  double? getMovieRating(int movieId) => _repository.getMovieRating(movieId);

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    _repository.dispose();
    super.dispose();
  }
}