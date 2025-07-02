import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart'; // Assuming Movie model is defined here

class TMDBService {
  final Dio _dio;
  
  // Private constructor
  TMDBService._internal() : _dio = Dio() {
    _dio.options.baseUrl = dotenv.env['API_URL']!;
    _dio.options.queryParameters['api_key'] = dotenv.env['API_KEY']!;
    _dio.options.queryParameters['language'] = 'pt-BR';
  }

  // Singleton instance
  static final TMDBService _instance = TMDBService._internal();

  // Factory constructor to return the singleton instance
  factory TMDBService() {
    return _instance;
  }

  /// Fetches a list of popular movies.
  ///
  /// [page] The page number to retrieve. Defaults to 1.
  /// Returns a [Future] that completes with a list of [Movie] objects.
  /// Throws a [DioException] if the request fails.
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {'page': page},
      );
      return _parseMovieList(response);
    } on DioException catch (e) {
      throw Exception('Failed to load popular movies: ${e.message}');
    }
  }

  /// Searches for movies based on a query.
  ///
  /// [query] The search query string.
  /// [page] The page number to retrieve. Defaults to 1.
  /// Returns a [Future] that completes with a list of [Movie] objects.
  /// Throws a [DioException] if the request fails.
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '/search/movie',
        queryParameters: {'query': query, 'page': page},
      );
      return _parseMovieList(response);
    } on DioException catch (e) {
      throw Exception('Failed to search movies: ${e.message}');
    }
  }

  /// Fetches the details of a specific movie.
  ///
  /// [movieId] The ID of the movie to retrieve details for.
  /// Returns a [Future] that completes with a [Map<String, dynamic>] containing movie details.
  /// Throws a [DioException] if the request fails.
  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to load movie details: ${e.message}');
    }
  }

  /// Fetches the videos associated with a specific movie.
  ///
  /// [movieId] The ID of the movie to retrieve videos for.
  /// Returns a [Future] that completes with a list of [Map<String, dynamic>] representing video information.
  /// Throws a [DioException] if the request fails.
  Future<List<Map<String, dynamic>>> getMovieVideos(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId/videos');
      final List<dynamic> results = response.data['results'] ?? [];
      return results.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception('Failed to load movie videos: ${e.message}');
    }
  }

  List<Movie> _parseMovieList(Response response) {
    final List<dynamic> results = response.data['results'] ?? [];
    return results.map((json) => Movie.fromJson(json)).toList();
  }
}