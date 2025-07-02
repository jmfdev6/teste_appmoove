import 'package:app_movie_favorites/viewmodels/movie_viewmodel.dart';
import 'package:app_movie_favorites/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mockito/mockito.dart';

// Mock da classe MovieViewModel para controlar seu estado nos testes de UI
class MockViewModel extends Mock implements MovieViewModel {}

void main() {
  // Teste para verificar se o indicador de carregamento é exibido inicialmente
  testWidgets('shows loading indicator initially', (WidgetTester tester) async {
    final mockVm = MockViewModel();
    // Configura o mock para ter isLoading como true
    when(mockVm.state).thenReturn( MovieState(isLoading: true));

    await tester.pumpWidget(
      ChangeNotifierProvider<MovieViewModel>.value(
        value: mockVm,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Verifica se um CircularProgressIndicator está presente
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // Teste para verificar se a mensagem de erro é exibida em caso de falha
  testWidgets('shows error message on error', (WidgetTester tester) async {
    final mockVm = MockViewModel();
    // Configura o mock para ter uma mensagem de erro
    when(mockVm.state).thenReturn(MovieState(
      isLoading: false,
      popularMovies: [],
      errorMessage: 'Error',
    ));

    await tester.pumpWidget(
      ChangeNotifierProvider<MovieViewModel>.value(
        value: mockVm,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Verifica se as mensagens de erro esperadas estão presentes
    expect(find.text('Erro ao carregar filmes'), findsOneWidget);
    expect(find.text('Error'), findsOneWidget);
  });
}