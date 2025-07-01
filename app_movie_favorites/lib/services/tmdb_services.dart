import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';

class TMDBService {
  final String _baseUrl = dotenv.env['API_URL']!;
  final String _apiKey = dotenv.env['API_KEY']!; // Substitua pela sua API key
  
  final Dio _dio = Dio();
  
  TMDBService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.queryParameters['api_key'] = _apiKey;
    _dio.options.queryParameters['language'] = 'pt-BR';
  }
  
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _dio.get('/movie/popular', 
        queryParameters: {'page': page});
      
      final List results = response.data['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar filmes populares: $e');
    }
  }
  
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await _dio.get('/search/movie', 
        queryParameters: {'query': query, 'page': page});
      
      final List results = response.data['results'] ?? [];
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao pesquisar filmes: $e');
    }
  }
  
  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId');
      return response.data;
    } catch (e) {
      throw Exception('Erro ao buscar detalhes: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getMovieVideos(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId/videos');
      final List results = response.data['results'] ?? [];
      return results.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Erro ao buscar vídeos: $e');
    }
  }
}