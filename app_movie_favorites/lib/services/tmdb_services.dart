import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';

class TMDBService {
  static final TMDBService _instance = TMDBService._internal();
  final Dio _dio;
  final Map<String, dynamic> _cache = {};

  factory TMDBService() => _instance;

  TMDBService._internal()
      : _dio = Dio(BaseOptions(
          baseUrl: dotenv.env['API_URL']!,
          queryParameters: {
            'api_key': dotenv.env['API_KEY']!,
            'language': 'pt-BR',
          },
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        )) {
    _dio.interceptors.add(LogInterceptor(responseBody: false));
  }

  Future<Map<String, dynamic>> _getWithCache(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final cacheKey = '$path?${query?.toString()}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await _dio.get(path, queryParameters: query);
      _cache[cacheKey] = response.data;
      return response.data;
    } on DioException catch (e) {
      throw TMDBException.fromDioError(e);
    }
  }

  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final data = await _getWithCache('/movie/popular', query: {'page': page});
    return _parseMovieList(data);
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final data = await _getWithCache(
      '/search/movie',
      query: {'query': query, 'page': page},
    );
    return _parseMovieList(data);
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    return _getWithCache('/movie/$movieId');
  }

  Future<List<Map<String, dynamic>>> getMovieVideos(int movieId) async {
    final data = await _getWithCache('/movie/$movieId/videos');
    return (data['results'] as List).cast<Map<String, dynamic>>();
  }

  List<Movie> _parseMovieList(Map<String, dynamic> data) {
    return (data['results'] as List)
        .map((json) => Movie.fromJson(json))
        .toList();
  }
}

class TMDBException implements Exception {
  final String message;
  final int? statusCode;

  TMDBException(this.message, {this.statusCode});

  factory TMDBException.fromDioError(DioException e) {
    return TMDBException(
      e.response?.data['status_message'] ?? e.message ?? 'Unknown error',
      statusCode: e.response?.statusCode,
    );
  }

  @override
  String toString() => 'TMDBException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}