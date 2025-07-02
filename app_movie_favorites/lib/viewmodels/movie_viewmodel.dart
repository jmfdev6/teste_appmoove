import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../repositories/tmdb_repository.dart';
import 'package:dio/dio.dart'; 

/// ViewModel responsável por gerenciar o estado da tela de filmes,
/// interagindo com o MovieRepository para buscar dados e manipular favoritos/avaliações.
class MovieViewModel extends ChangeNotifier {
  // O repositório é injetado no construtor, tornando a dependência explícita e não-nula.
  final MovieRepository _repository;

  // Estados para a lista de filmes populares e resultados de pesquisa.
  List<Movie> _popularMovies = [];
  List<Movie> _searchResults = [];
  bool _isLoading = false; // Indica se há um carregamento principal em andamento.
  String? _errorMessage; // Mensagem de erro para operações principais.

  // Estados para a lista de filmes favoritos.
  List<Movie> _favoriteMovies = [];

  // Estados específicos para detalhes e vídeos de um filme.
  Map<String, dynamic>? _currentMovieDetails;
  List<Map<String, dynamic>> _currentMovieVideos = [];
  bool _isMovieDetailLoading = false; // Indica se os detalhes de um filme estão carregando.
  String? _movieDetailErrorMessage; // Mensagem de erro para detalhes de filme.

  // Getters para acessar os estados de forma segura e imutável.
  List<Movie> get popularMovies => List.unmodifiable(_popularMovies);
  List<Movie> get searchResults => List.unmodifiable(_searchResults);
  List<Movie> get favoriteMovies => List.unmodifiable(_favoriteMovies);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Movie? get featuredMovie => _popularMovies.isNotEmpty ? _popularMovies.first : null;

  Map<String, dynamic>? get currentMovieDetails => _currentMovieDetails;
  List<Map<String, dynamic>> get currentMovieVideos => List.unmodifiable(_currentMovieVideos);
  bool get isMovieDetailLoading => _isMovieDetailLoading;
  String? get movieDetailErrorMessage => _movieDetailErrorMessage;

  /// Construtor que recebe o [MovieRepository] como dependência obrigatória.
  /// Isso facilita testes e a gestão de dependências.
  MovieViewModel({required MovieRepository repository}) : _repository = repository {
    // Carrega os filmes populares e favoritos assim que o ViewModel é criado.
    _initializeData();
  }

  /// Método de inicialização para carregar dados iniciais do aplicativo.
  Future<void> _initializeData() async {
    await loadPopularMovies();
    loadFavoriteMovies(); // Não é assíncrono, então não precisa de 'await'.
  }

  /// Define o estado de carregamento principal e notifica os listeners.
  void _setLoading(bool loading) {
    if (_isLoading != loading) { // Evita notificar se o estado não mudou.
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Define a mensagem de erro principal e notifica os listeners.
  void _setErrorMessage(String? message) {
    if (_errorMessage != message) { // Evita notificar se a mensagem não mudou.
      _errorMessage = message;
      notifyListeners();
    }
  }

  /// Define o estado de carregamento para detalhes do filme e notifica os listeners.
  void _setMovieDetailLoading(bool loading) {
    if (_isMovieDetailLoading != loading) { // Evita notificar se o estado não mudou.
      _isMovieDetailLoading = loading;
      notifyListeners();
    }
  }

  /// Define a mensagem de erro para detalhes do filme e notifica os listeners.
  void _setMovieDetailErrorMessage(String? message) {
    if (_movieDetailErrorMessage != message) { // Evita notificar se a mensagem não mudou.
      _movieDetailErrorMessage = message;
      notifyListeners();
    }
  }

  /// Carrega a lista de filmes populares do repositório.
  /// Atualiza os estados de carregamento e erro.
  Future<void> loadPopularMovies() async {
    _setLoading(true);
    _setErrorMessage(null); // Limpa qualquer erro anterior.
    try {
      _popularMovies = await _repository.getPopularMovies();
    } on DioException catch (e) {
      // Captura exceções específicas do Dio para mensagens mais detalhadas.
      _setErrorMessage('Falha ao carregar filmes populares: ${e.message}');
    } catch (e) {
      // Captura outras exceções genéricas.
      _setErrorMessage('Ocorreu um erro inesperado ao carregar filmes populares: $e');
    } finally {
      _setLoading(false); // Garante que o estado de carregamento seja desativado.
      // notifyListeners() já é chamado por _setLoading e _setErrorMessage,
      // então não é necessário aqui novamente.
    }
  }

  /// Pesquisa filmes com base em uma consulta.
  /// Se a consulta estiver vazia, limpa os resultados da pesquisa.
  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _setErrorMessage(null);
      notifyListeners(); // Notifica para limpar a UI imediatamente.
      return;
    }

    _setLoading(true);
    _setErrorMessage(null); // Limpa qualquer erro anterior.
    try {
      _searchResults = await _repository.searchMovies(query);
    } on DioException catch (e) {
      _setErrorMessage('Falha ao pesquisar filmes: ${e.message}');
      _searchResults = []; // Limpa resultados em caso de erro.
    } catch (e) {
      _setErrorMessage('Ocorreu um erro inesperado ao pesquisar filmes: $e');
      _searchResults = [];
    } finally {
      _setLoading(false); // Garante que o estado de carregamento seja desativado.
      // notifyListeners() já é chamado por _setLoading e _setErrorMessage.
    }
  }

  /// Carrega os detalhes de um filme específico e seus vídeos.
  /// Atualiza os estados de carregamento e erro específicos para detalhes.
  Future<void> loadMovieDetails(int movieId) async {
    _setMovieDetailLoading(true);
    _setMovieDetailErrorMessage(null);
    try {
      _currentMovieDetails = await _repository.getMovieDetails(movieId);
      _currentMovieVideos = await _repository.getMovieVideos(movieId);
    } on DioException catch (e) {
      _setMovieDetailErrorMessage('Falha ao carregar detalhes do filme: ${e.message}');
      _currentMovieDetails = null;
      _currentMovieVideos = [];
    } catch (e) {
      _setMovieDetailErrorMessage('Ocorreu um erro inesperado ao carregar detalhes: $e');
      _currentMovieDetails = null;
      _currentMovieVideos = [];
    } finally {
      _setMovieDetailLoading(false); // Garante que o estado de carregamento seja desativado.
      // notifyListeners() já é chamado por _setMovieDetailLoading e _setMovieDetailErrorMessage.
    }
  }

  /// Carrega a lista de filmes favoritos do repositório.
  /// Notifica os listeners para atualizar a UI.
  void loadFavoriteMovies() {
    _favoriteMovies = _repository.getFavoriteMovies();
    notifyListeners();
  }

  /// Alterna o status de favorito de um filme.
  /// Adiciona ou remove o filme da lista de favoritos e recarrega a lista.
  Future<void> toggleFavorite(Movie movie) async {
    _setErrorMessage(null); // Limpa mensagens de erro anteriores para esta operação.
    try {
      await _repository.toggleFavorite(movie);
      loadFavoriteMovies(); // Recarrega a lista de favoritos após a alteração.
    } catch (e) {
      _setErrorMessage('Falha ao alternar favorito: $e');
    }
  }

  /// Verifica se um filme é favorito.
  ///
  /// Retorna `true` se o filme com o [movieId] especificado estiver na lista de favoritos,
  /// `false` caso contrário.
  bool isFavorite(int movieId) {
    return _repository.isFavorite(movieId);
  }

  /// Avalia um filme com uma determinada pontuação.
  ///
  /// [movieId] O ID do filme a ser avaliado.
  /// [rating] A pontuação [double] a ser atribuída ao filme.
  Future<void> rateMovie(int movieId, double rating) async {
    _setErrorMessage(null); // Limpa mensagens de erro anteriores para esta operação.
    try {
      await _repository.rateMovie(movieId, rating);
      // Opcional: notifyListeners() aqui se a UI precisar reagir a uma avaliação
      // que afete algo além do RatingWidget (que já tem seu próprio callback).
    } catch (e) {
      _setErrorMessage('Falha ao avaliar filme: $e');
    }
  }

  /// Obtém a avaliação de um filme.
  ///
  /// Retorna a avaliação [double] do filme com o [movieId] especificado,
  /// ou `null` se o filme não foi avaliado.
  double? getMovieRating(int movieId) {
    return _repository.getMovieRating(movieId);
  }
}
