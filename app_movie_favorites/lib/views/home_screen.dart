import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // Importe GoRouter para context.go
import '../core/utils/routes/app_routes.dart';
import '../core/utils/widgets/featured_movie_card.dart';
import '../core/utils/widgets/movie_card.dart' show MovieCard;
import '../viewmodels/movie_viewmodel.dart';

/// Tela inicial que exibe filmes populares e um filme em destaque.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // Adicione const constructor

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Garante que o ViewModel seja acessado após o build inicial
    // e que os filmes populares sejam carregados uma vez.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieViewModel>(context, listen: false).loadPopularMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filmes Populares'), 
        actions: [
          IconButton(
            icon: const Icon(Icons.search), 
            onPressed: () => context.push(AppRouter.search),
          ),
          IconButton(
            icon: const Icon(Icons.favorite), 
            onPressed: () => context.push(AppRouter.favorites),
          ),
        ],
      ),
      body: Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          // Exibe um indicador de carregamento inicial se não houver dados ainda
          if (viewModel.state.isLoading && viewModel.state.popularMovies.isEmpty) {
            return const Center(child: CircularProgressIndicator()); 
          }

          // Exibe mensagem de erro se houver um erro e nenhuma lista de filmes
          if (viewModel.state.errorMessage != null && viewModel.state.popularMovies.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0), 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red), 
                    const SizedBox(height: 16), 
                    Text(
                      'Erro ao carregar filmes',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8), 
                    Text(
                      viewModel.state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16), // Adicione const
                    ElevatedButton.icon( // Use ElevatedButton.icon para melhor UX
                      onPressed: () => viewModel.loadPopularMovies(),
                      icon: const Icon(Icons.refresh), // Adicione const
                      label: const Text('Tentar novamente'), // Adicione const
                    ),
                  ],
                ),
              ),
            );
          }

          // Exibe mensagem de "nenhum filme encontrado" se a lista estiver vazia após carregamento
          if (viewModel.state.popularMovies.isEmpty) {
            return const Center( 
              child: Text('Nenhum filme encontrado.'), 
            );
          }

          // Conteúdo principal da tela
          return RefreshIndicator(
            onRefresh: () => viewModel.loadPopularMovies(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filme em destaque
                  if (viewModel.state.featuredMovie != null)
                    FeaturedMovieCard(movie: viewModel.state.featuredMovie!),

                  const SizedBox(height: 24), 

                  // Título da seção "Populares"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16), 
                    child: Text(
                      'Populares',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),

                  const SizedBox(height: 12), 

                  // Lista horizontal de filmes populares
                  SizedBox(
                    height: 280, // Altura fixa para a lista horizontal
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16), 
                      itemCount: viewModel.state.popularMovies.length,
                      itemBuilder: (context, index) {
                        final movie = viewModel.state.popularMovies[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12), 
                          child: MovieCard(movie: movie),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20), 
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
