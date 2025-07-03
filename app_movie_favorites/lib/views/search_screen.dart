import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../core/utils/widgets/movie_list_item.dart';
import '../viewmodels/movie_viewmodel.dart';

/// Tela de pesquisa de filmes com debounce e tratamento de erros.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _showClearButton = false;

  // Constantes para configuração
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const int _minSearchLength = 2;

  @override
  void initState() {
    super.initState();
    _initializeSearch();
  }

  void _initializeSearch() {
    // Limpa os resultados da pesquisa ao entrar na tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MovieViewModel>().searchMovies('');
      }
    });

    // Listener para atualizar o botão de limpar
    _searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    final hasText = _searchController.text.isNotEmpty;
    if (_showClearButton != hasText) {
      setState(() {
        _showClearButton = hasText;
      });
    }
  }

  void _onSearchChanged(String query) {
    // Cancela timer anterior se existir
    _debounceTimer?.cancel();

    // Se a query está vazia, limpa imediatamente
    if (query.isEmpty) {
      if (mounted) {
        context.read<MovieViewModel>().searchMovies('');
      }
      return;
    }

    // Se a query é muito curta, não pesquisa ainda
    if (query.length < _minSearchLength) {
      return;
    }

    // Cria novo timer para debounce
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted) {
        context.read<MovieViewModel>().searchMovies(query.trim());
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    
    if (mounted) {
      context.read<MovieViewModel>().searchMovies('');
    }
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Digite algo para pesquisar',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Pesquise por filmes usando pelo menos $_minSearchLength caracteres',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.movie_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum filme encontrado',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 9),
          Text(
            'Tente uma pesquisa diferente ou verifique a ortografia.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, MovieViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erro na pesquisa',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                viewModel.clearErrors();
                if (_searchController.text.trim().isNotEmpty) {
                  viewModel.searchMovies(_searchController.text.trim());
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<dynamic> results) {
    return ListView.builder(
      itemCount: results.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        final movie = results[index];
        return MovieListItem(movie: movie);
      },
    );
  }

  Widget _buildContent(MovieViewModel viewModel) {
    // Verifica se há erro
    if (viewModel.state.errorMessage != null) {
      return _buildErrorState(viewModel.state.errorMessage!, viewModel);
    }

    // Loading state
    if (viewModel.state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final query = _searchController.text.trim();
    
    // Estado vazio - sem pesquisa
    if (query.isEmpty) {
      return _buildEmptySearchState();
    }

    // Query muito curta
    if (query.length < _minSearchLength) {
      return _buildEmptySearchState();
    }

    // Sem resultados
    if (viewModel.state.searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    // Exibe resultados
    return _buildSearchResults(viewModel.state.searchResults);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title:  Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Digite o nome do filme...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _showClearButton
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                        tooltip: 'Limpar pesquisa',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              onSubmitted: (query) {
                _debounceTimer?.cancel();
                if (query.trim().isNotEmpty && mounted) {
                  context.read<MovieViewModel>().searchMovies(query.trim());
                }
              },
            ),
          ),
          elevation: 0,
        ),
        body: Expanded(
          child: Consumer<MovieViewModel>(
            builder: (context, viewModel, child) {
              return _buildContent(viewModel);
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }
}