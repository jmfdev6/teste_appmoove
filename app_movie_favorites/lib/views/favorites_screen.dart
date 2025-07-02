import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/widgets/movie_list_item.dart';
import '../viewmodels/movie_viewmodel.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key}); 

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieViewModel>(context, listen: false).loadFavoriteMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'), 
      ),
      body: Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          // Exibe mensagem de "nenhum filme favorito" se a lista estiver vazia
          if (viewModel.favoriteMovies.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0), 
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey,
                    ), 
                    const SizedBox(height: 16), 
                    Text(
                      'Nenhum filme favorito',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8), 
                    Text(
                      'Adicione filmes aos seus favoritos!',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Lista de filmes favoritos
          return ListView.builder(
            itemCount: viewModel.favoriteMovies.length,
            itemBuilder: (context, index) {
              final movie = viewModel.favoriteMovies[index];
              return MovieListItem(movie: movie);
            },
          );
        },
      ),
    );
  }
}
