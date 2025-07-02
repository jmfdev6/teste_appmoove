import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import '../models/movie.dart';
import '../services/tmdb_services.dart';

/// Repositório responsável por abstrair a fonte de dados para filmes.
/// Ele interage com o TMDBService para dados remotos e com Hive para dados locais (favoritos e avaliações).
class MovieRepository {
  final TMDBService _tmdbService;
  final Box<Movie> _favoritesBox;
  final Box<double> _ratingsBox;

  /// Construtor que recebe o TMDBService e as boxes do Hive como dependências.
  /// As boxes devem ser abertas antes de instanciar o repositório.
  MovieRepository(this._tmdbService)
    : _favoritesBox = Hive.box<Movie>('favorites'),
      _ratingsBox = Hive.box<double>('ratings');

  /// Busca filmes populares da API TMDB.
  ///
  /// [page] O número da página a ser recuperada. Padrão é 1.
  /// Retorna uma [Future] que completa com uma lista de objetos [Movie].
  /// Lança [DioException] em caso de falha na requisição.
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      return await _tmdbService.getPopularMovies(page: page);
    } on DioException {
      // Re-lança a exceção Dio para que o ViewModel possa tratá-la
      rethrow;
    } catch (e) {
      // Envolve outras exceções em uma exceção mais genérica ou específica do repositório
      throw Exception('Erro inesperado ao buscar filmes populares: $e');
    }
  }

  /// Pesquisa filmes na API TMDB com base em uma consulta.
  ///
  /// [query] A string de consulta.
  /// [page] O número da página a ser recuperada. Padrão é 1.
  /// Retorna uma [Future] que completa com uma lista de objetos [Movie].
  /// Lança [DioException] em caso de falha na requisição.
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    try {
      return await _tmdbService.searchMovies(query, page: page);
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Erro inesperado ao pesquisar filmes: $e');
    }
  }

  /// Obtém os detalhes de um filme específico da API TMDB.
  ///
  /// [movieId] O ID do filme.
  /// Retorna uma [Future] que completa com um [Map<String, dynamic>] dos detalhes do filme.
  /// Lança [DioException] em caso de falha na requisição.
  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    try {
      return await _tmdbService.getMovieDetails(movieId);
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Erro inesperado ao buscar detalhes do filme: $e');
    }
  }

  /// Obtém os vídeos associados a um filme específico da API TMDB.
  ///
  /// [movieId] O ID do filme.
  /// Retorna uma [Future] que completa com uma lista de [Map<String, dynamic>] de informações de vídeo.
  /// Lança [DioException] em caso de falha na requisição.
  Future<List<Map<String, dynamic>>> getMovieVideos(int movieId) async {
    try {
      return await _tmdbService.getMovieVideos(movieId);
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('Erro inesperado ao buscar vídeos do filme: $e');
    }
  }

  /// Retorna uma lista de filmes marcados como favoritos.
  List<Movie> getFavoriteMovies() {
    return _favoritesBox.values.toList();
  }

  /// Verifica se um filme está marcado como favorito.
  ///
  /// [movieId] O ID do filme a ser verificado.
  bool isFavorite(int movieId) {
    return _favoritesBox.containsKey(movieId);
  }

  /// Alterna o status de favorito de um filme. Se já for favorito, remove; caso contrário, adiciona.
  ///
  /// [movie] O objeto [Movie] a ser alternado.
  Future<void> toggleFavorite(Movie movie) async {
    if (isFavorite(movie.id)) {
      await _favoritesBox.delete(movie.id);
    } else {
      await _favoritesBox.put(movie.id, movie);
    }
  }

  /// Obtém a avaliação de um filme.
  ///
  /// [movieId] O ID do filme.
  /// Retorna a avaliação [double] ou `null` se o filme não foi avaliado.
  double? getMovieRating(int movieId) {
    return _ratingsBox.get(movieId);
  }

  /// Avalia um filme com uma pontuação específica.
  ///
  /// [movieId] O ID do filme a ser avaliado.
  /// [rating] A pontuação [double] a ser atribuída ao filme.
  Future<void> rateMovie(int movieId, double rating) async {
    await _ratingsBox.put(movieId, rating);
  }
}
