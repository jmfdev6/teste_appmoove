// test/movie_viewmodel_test.dart
import 'package:app_movie_favorites/models/movie.dart';
import 'package:app_movie_favorites/repositories/movie_repository.dart';
import 'package:app_movie_favorites/viewmodels/movie_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';


// Mock da classe MovieRepository para isolar o MovieViewModel
class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository mockRepo;
  late MovieViewModel viewModel;

  // Configuração inicial para cada teste
  setUp(() {
    mockRepo = MockMovieRepository();
    // Configura o mock para retornar um stream vazio para favoritesStream
    when(mockRepo.favoritesStream).thenAnswer((_) => const Stream.empty());
    // Configura o mock para retornar uma lista vazia para getFavoriteMovies
    when(mockRepo.getFavoriteMovies()).thenReturn([]);
    viewModel = MovieViewModel(repository: mockRepo);
  });

  // Teste para verificar o carregamento bem-sucedido de filmes populares
  test('loadPopularMovies success updates state', () async {
    final movies = [
      Movie(id: 1, title: 'Test', posterPath: '', voteAverage: 0.0, releaseDate: 'ijjoijioj', overview: 'ijijojoji', genreIds: [1,4,3,4,5,67,7,8])
    ];
    // Configura o mock para retornar uma lista de filmes ao chamar getPopularMovies
    when(mockRepo.getPopularMovies(page: 1)).thenAnswer((_) async => movies);

    await viewModel.loadPopularMovies();

    // Verifica se o estado do ViewModel foi atualizado corretamente
    expect(viewModel.state.popularMovies, movies);
    expect(viewModel.state.currentPage, 1);
    expect(viewModel.state.hasMore, true);
    expect(viewModel.state.errorMessage, isNull);
  });

  // Teste para verificar o tratamento de erro ao carregar filmes populares
  test('loadPopularMovies failure sets errorMessage', () async {
    // Configura o mock para lançar uma exceção ao chamar getPopularMovies
    when(mockRepo.getPopularMovies(page: 1)).thenThrow(Exception('fail'));

    await viewModel.loadPopularMovies();

    // Verifica se a mensagem de erro foi definida e a lista de filmes está vazia
    expect(viewModel.state.errorMessage, contains('Erro ao carregar filmes'));
    expect(viewModel.state.popularMovies, isEmpty);
  });
}