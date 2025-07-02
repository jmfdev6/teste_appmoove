// test/movie_details_screen_test.dart
import 'package:app_movie_favorites/viewmodels/movie_viewmodel.dart';
import 'package:app_movie_favorites/views/movie_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mockito/mockito.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Mock da classe MovieViewModel para controlar seu estado nos testes de UI
class MockViewModel extends Mock implements MovieViewModel {}

void main() {
  // Teste para verificar se o trailer é exibido quando disponível
  testWidgets('displays trailer when available', (WidgetTester tester) async {
    final mockVm = MockViewModel();
    // Configura o mock para ter detalhes do filme e um trailer disponível
    when(mockVm.state).thenReturn( MovieState(
      isMovieDetailLoading: false,
      currentMovieDetails: {
        'title': 'Test',
        'backdrop_path': null,
        'poster_path': null,
        'vote_average': 0.0,
        'release_date': '',
        'genres': [],
        'overview': ''
      },
      currentMovieVideos: [
        {'type': 'Trailer', 'site': 'YouTube', 'key': 'abc123'}
      ],
    ));

    await tester.pumpWidget(
      ChangeNotifierProvider<MovieViewModel>.value(
        value: mockVm,
        child: const MaterialApp(
          home: MovieDetailsScreen(movieId: 1),
        ),
      ),
    );

    // Aguarda que todas as animações e operações assíncronas sejam concluídas
    await tester.pumpAndSettle();

    // Verifica se o widget YoutubePlayer está presente
    // (Certifique-se de que o import para YoutubePlayer está correto no seu arquivo de teste)
    expect(find.byType(YoutubePlayer), findsOneWidget);
  });
}