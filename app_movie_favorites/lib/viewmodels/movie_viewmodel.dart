// movie_viewmodel.dart
import 'dart:async';
import 'dart:developer' as developer;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';

class MovieState extends Equatable {
  final List<Movie> popularMovies;
  final List<Movie> searchResults;
  final List<Movie> favoriteMovies;
  final Map<String, dynamic>? currentMovieDetails;
  final List<Map<String, dynamic>> currentMovieVideos;
  final int? currentMovieDetailsId;
  final String? errorMessage;
  final String? movieDetailError;
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isMovieDetailLoading;
  final bool hasMore;

  Movie? get featuredMovie => popularMovies.isNotEmpty ? popularMovies.first : null;

  const MovieState({
    this.popularMovies = const [],
    this.searchResults = const [],
    this.favoriteMovies = const [],
    this.currentMovieDetails,
    this.currentMovieVideos = const [],
    this.currentMovieDetailsId,
    this.errorMessage,
    this.movieDetailError,
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isMovieDetailLoading = false,
    this.hasMore = true,
  });

  MovieState copyWith({
    List<Movie>? popularMovies,
    List<Movie>? searchResults,
    List<Movie>? favoriteMovies,
    Map<String, dynamic>? currentMovieDetails,
    List<Map<String, dynamic>>? currentMovieVideos,
    int? currentMovieDetailsId,
    String? errorMessage,
    String? movieDetailError,
    int? currentPage,
    int? totalPages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isMovieDetailLoading,
    bool? hasMore,
    bool clearErrors = false,
    bool clearMovieDetails = false,
  }) {
    return MovieState(
      popularMovies: popularMovies ?? this.popularMovies,
      searchResults: searchResults ?? this.searchResults,
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
      currentMovieDetails: clearMovieDetails ? null : (currentMovieDetails ?? this.currentMovieDetails),
      currentMovieVideos: clearMovieDetails ? [] : (currentMovieVideos ?? this.currentMovieVideos),
      currentMovieDetailsId: currentMovieDetailsId ?? (clearMovieDetails ? null : this.currentMovieDetailsId),
      errorMessage: clearErrors ? null : (errorMessage ?? this.errorMessage),
      movieDetailError: clearMovieDetails ? null : (movieDetailError ?? this.movieDetailError),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMovieDetailLoading: isMovieDetailLoading ?? this.isMovieDetailLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
  
  @override
  List<Object?> get props => [
        popularMovies,
        searchResults,
        favoriteMovies,
        currentMovieDetails,
        currentMovieVideos,
        currentMovieDetailsId,
        errorMessage,
        movieDetailError,
        currentPage,
        totalPages,
        isLoading,
        isLoadingMore,
        isMovieDetailLoading,
        hasMore,
      ];
}

class MovieViewModel extends ChangeNotifier {
  final MovieRepository _repository;
  StreamSubscription<List<Movie>>? _favoritesSubscription;
  bool _disposed = false;
  MovieState _state = const MovieState();

  MovieState get state => _state;

  MovieViewModel({required MovieRepository repository}) : _repository = repository {
    _init();
  }

  void _init() {
    _loadInitialData();
    _favoritesSubscription = _repository.favoritesStream.listen((favorites) {
      if (!_disposed) {
        _updateState(_state.copyWith(favoriteMovies: favorites));
      }
    });
  }

  Future<void> _loadInitialData() async {
    try {
      await loadPopularMovies();
      if (!_disposed) {
        _updateState(_state.copyWith(
          favoriteMovies: _repository.getFavoriteMovies(),
        ));
      }
    } catch (e) {
      if (!_disposed) {
        _updateState(_state.copyWith(errorMessage: 'Erro ao carregar dados iniciais: $e'));
      }
    }
  }

  Future<void> loadPopularMovies({bool reset = true}) async {
    if (_disposed || _state.isLoading || _state.isLoadingMore) return;

    _updateState(_state.copyWith(
      isLoading: reset,
      isLoadingMore: !reset,
      clearErrors: true,
    ));

    try {
      final movies = await _repository.getPopularMovies(
          page: reset ? 1 : _state.currentPage + 1);
      if (!_disposed) {
        _updateState(_state.copyWith(
          popularMovies:
              reset ? movies : [..._state.popularMovies, ...movies],
          currentPage: reset ? 1 : _state.currentPage + 1,
          hasMore: movies.isNotEmpty,
          isLoading: false,
          isLoadingMore: false,
        ));
      }
    } catch (e) {
      if (!_disposed) {
        _updateState(
            _state.copyWith(
              errorMessage: 'Erro ao carregar filmes: $e',
              isLoading: false,
              isLoadingMore: false
            ));
      }
    }
  }

  Future<void> searchMovies(String query) async {
    if (_disposed) return;
    if (query.isEmpty) {
      _updateState(_state.copyWith(
        searchResults: [],
        clearErrors: true,
      ));
      return;
    }
    _updateState(_state.copyWith(isLoading: true, clearErrors: true));

    try {
      final results = await _repository.searchMovies(query);
      if (!_disposed) {
        _updateState(_state.copyWith(searchResults: results));
      }
    } catch (e) {
      if (!_disposed) {
        _updateState(_state.copyWith(
          errorMessage: 'Erro na pesquisa: $e',
          searchResults: [],
        ));
      }
    } finally {
      if (!_disposed) {
        _updateState(_state.copyWith(isLoading: false));
      }
    }
  }

  Future<void> loadMovieDetails(int movieId) async {
    if (_disposed) return;

    developer.log('🎬 [ViewModel] Carregando detalhes para filme ID: $movieId');
    
    if (_state.isMovieDetailLoading && _state.currentMovieDetailsId == movieId) {
      developer.log('⚠️ [ViewModel] Já está carregando este filme, ignorando requisição duplicada');
      return;
    }

    _updateState(_state.copyWith(
      currentMovieDetailsId: movieId,
      clearMovieDetails: true,
      isMovieDetailLoading: true,
    ));

    try {
      developer.log('🔄 [ViewModel] Fazendo requisições para filme $movieId');
      
      final results = await Future.wait([
        _repository.getMovieDetails(movieId),
        _repository.getMovieVideos(movieId),
      ]);

      final details = results[0] as Map<String, dynamic>;
      final videos = results[1] as List<Map<String, dynamic>>;

      developer.log('✅ [ViewModel] Detalhes carregados para filme ${details['id']}');
      developer.log('✅ [ViewModel] Vídeos recebidos: ${videos.length}');

      if (!_disposed && _state.currentMovieDetailsId == movieId) {
        _updateState(_state.copyWith(
          currentMovieDetails: details,
          currentMovieVideos: videos,
          isMovieDetailLoading: false, // Define loading como false junto com os dados
        ));
        developer.log('✅ [ViewModel] Estado atualizado para filme $movieId');
      } else {
        developer.log('⚠️ [ViewModel] Descartando dados - filme mudou ou widget disposed');
        if (!_disposed && _state.currentMovieDetailsId != movieId) {
           _updateState(_state.copyWith(isMovieDetailLoading: false));
        }
      }
    } catch (e) {
      developer.log('❌ [ViewModel] Erro ao carregar filme $movieId: $e');
      if (!_disposed && _state.currentMovieDetailsId == movieId) {
        _updateState(_state.copyWith(
          movieDetailError: 'Erro: ${e.toString()}',
          isMovieDetailLoading: false,
        ));
      }
    }
  }

  void clearMovieDetails() {
    if (!_disposed) {
      developer.log('🧹 [ViewModel] Limpando dados de detalhes do filme');
      _updateState(_state.copyWith(clearMovieDetails: true));
    }
  }

  bool isMovieDataValid(int movieId) {
    return _state.currentMovieDetailsId == movieId && 
           _state.currentMovieDetails != null &&
           _state.currentMovieDetails!['id'] == movieId;
  }

  Future<void> toggleFavorite(Movie movie) async {
    if (_disposed) return;
    try {
      await _repository.toggleFavorite(movie);
    } catch (e) {
      if (!_disposed) {
        _updateState(
            _state.copyWith(errorMessage: 'Erro ao favoritar: $e'));
      }
    }
  }

  Future<void> rateMovie(int movieId, double rating) async {
    if (_disposed) return;
    try {
      await _repository.rateMovie(movieId, rating);
    } catch (e) {
      if (!_disposed) {
        _updateState(
            _state.copyWith(errorMessage: 'Erro ao avaliar: $e'));
      }
    }
  }

  void clearErrors() {
    if (!_disposed) {
      _updateState(_state.copyWith(clearErrors: true));
    }
  }

  bool isFavorite(int movieId) => _repository.isFavorite(movieId);
  double? getMovieRating(int movieId) =>
      _repository.getMovieRating(movieId);

  void _updateState(MovieState newState) {
    if (!_disposed && _state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _favoritesSubscription?.cancel();
    _repository.dispose();
    super.dispose();
  }
}