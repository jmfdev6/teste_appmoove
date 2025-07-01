import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../core/utils/routes/app_routes.dart' show AppRouter;
import '../core/utils/widgets/featured_movie_card.dart';
import '../core/utils/widgets/movie_card.dart' show MovieCard;
import '../viewmodels/movie_viewmodel.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filmes Populares'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => context.go(AppRouter.search),
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => context.go(AppRouter.favorites),
          ),
        ],
      ),
      body: Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.popularMovies.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (viewModel.error != null && viewModel.popularMovies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Erro ao carregar filmes',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(viewModel.error!),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadPopularMovies(),
                    child: Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }
          
          if (viewModel.popularMovies.isEmpty) {
            return Center(
              child: Text('Nenhum filme encontrado'),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => viewModel.loadPopularMovies(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (viewModel.featuredMovie != null)
                    FeaturedMovieCard(movie: viewModel.featuredMovie!),
                  
                  SizedBox(height: 24),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Populares',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 12),
                  
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: viewModel.popularMovies.length,
                      itemBuilder: (context, index) {
                        final movie = viewModel.popularMovies[index];
                        return Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: MovieCard(movie: movie),
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}