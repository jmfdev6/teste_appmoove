import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/widgets/movie_list_item.dart';
import '../viewmodels/movie_viewmodel.dart';

/// Tela de pesquisa de filmes.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Limpa os resultados da pesquisa ao entrar na tela,
    // garantindo que não haja resultados de uma pesquisa anterior.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieViewModel>(context, listen: false).searchMovies('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16), // Adicionado const
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Digite o nome do filme...',
                  prefixIcon: const Icon(Icons.search), // Adicionado const
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear), // Adicionado const
                          onPressed: () {
                            _searchController.clear();
                            // Limpa os resultados da pesquisa no ViewModel
                            context.read<MovieViewModel>().searchMovies('');
                            // setState para atualizar a visibilidade do botão de limpar
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                onChanged: (query) {
                  // Chama a pesquisa no ViewModel a cada mudança no texto
                  context.read<MovieViewModel>().searchMovies(query);
                  // setState para atualizar a visibilidade do botão de limpar
                  setState(() {});
                },
              ),
            ),
      
            Expanded(
              child: Consumer<MovieViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator()); // Adicionado const
                  }
      
                  // Mensagem para quando a caixa de pesquisa está vazia
                  if (_searchController.text.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search, size: 64, color: Colors.grey), // Adicionado const
                          const SizedBox(height: 16), // Adicionado const
                          Text(
                            'Digite algo para pesquisar',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
      
                  // Mensagem para quando a pesquisa não retorna resultados
                  if (viewModel.searchResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.movie_outlined,
                            size: 64,
                            color: Colors.grey,
                          ), // Adicionado const
                          const SizedBox(height: 16), // Adicionado const
                          Text(
                            'Nenhum filme encontrado',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8), // Adicionado const
                          Text(
                            'Tente uma pesquisa diferente.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
      
                  // Exibe a lista de resultados da pesquisa
                  return ListView.builder(
                    itemCount: viewModel.searchResults.length,
                    itemBuilder: (context, index) {
                      final movie = viewModel.searchResults[index];
                      return MovieListItem(movie: movie);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
