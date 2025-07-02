import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:go_router/go_router.dart'; // Importe para context.pop()
import '../models/movie.dart';
import '../viewmodels/movie_viewmodel.dart';
import '../core/utils/widgets/rating_widget.dart';
import '../core/utils/widgets/genre_chip.dart';
import 'package:cached_network_image/cached_network_image.dart';


class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {

  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    // Garante que o carregamento dos detalhes do filme seja iniciado
    // após a conclusão da construção do primeiro frame da UI.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieViewModel>(context, listen: false).loadMovieDetails(widget.movieId);
    });
  }

  void _initializeYoutubePlayer(List<Map<String, dynamic>> videos) {
    // Tenta encontrar o primeiro vídeo que seja um 'Trailer' do 'YouTube'.
    final Map<String, dynamic> trailer = videos.firstWhere(
      (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
      orElse: () => <String, dynamic>{}, // Retorna um mapa vazio se nenhum trailer for encontrado.
    );

    // Verifica se um trailer válido com uma chave de vídeo foi encontrado.
    if (trailer.isNotEmpty && trailer['key'] != null) {
      final String videoKey = trailer['key'];

      if (_youtubeController == null || _youtubeController!.initialVideoId != videoKey) {
        _youtubeController?.dispose(); // Libera recursos do controlador anterior.
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoKey,
          flags: const YoutubePlayerFlags(
            autoPlay: false, // O vídeo não inicia automaticamente.
            mute: false, // O vídeo não inicia mutado.
          ),
        );
      }
    } else {

      _youtubeController?.dispose();
      _youtubeController = null;
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usa Consumer para reconstruir a UI sempre que o MovieViewModel notificar mudanças.
    return Consumer<MovieViewModel>(
      builder: (context, viewModel, child) {
        // Extrai os estados relevantes do ViewModel para maior legibilidade.
        final bool isLoading = viewModel.isMovieDetailLoading;
        final String? error = viewModel.movieDetailErrorMessage;
        final Map<String, dynamic>? movieDetails = viewModel.currentMovieDetails;
        final List<Map<String, dynamic>> videos = viewModel.currentMovieVideos;

        // Chama _initializeYoutubePlayer para garantir que o controlador esteja atualizado
        // apenas quando os dados de vídeo estiverem disponíveis e não houver erro.
        if (!isLoading && error == null && videos.isNotEmpty) {
          _initializeYoutubePlayer(videos);
        }

        // Exibe um indicador de carregamento enquanto os detalhes do filme estão sendo buscados.
        if (isLoading) {
          return Scaffold(
            appBar: AppBar(), // Uma AppBar simples durante o carregamento.
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Exibe uma mensagem de erro se a busca falhar ou os detalhes não forem encontrados.
        if (error != null || movieDetails == null) {
          return Scaffold(
            appBar: AppBar(
              // Botão de fechar na AppBar para retornar à tela anterior.
              actions: [
                IconButton(
                  onPressed: () {
                    context.pop(); // Utiliza go_router para desempilhar a rota atual.
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Erro ao carregar detalhes do filme',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error ?? 'Detalhes não disponíveis.', // Exibe a mensagem de erro ou um fallback.
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    // Botão para tentar recarregar os detalhes do filme.
                    ElevatedButton.icon(
                      onPressed: () {
                        viewModel.loadMovieDetails(widget.movieId);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Se os detalhes do filme foram carregados com sucesso, exibe o conteúdo principal.
        final Map<String, dynamic> movie = movieDetails; // Alias para facilitar o acesso.
        final String backdropUrl = movie['backdrop_path'] != null
            ? 'https://image.tmdb.org/t/p/w780${movie['backdrop_path']}'
            : '';
        final String posterUrl = movie['poster_path'] != null
            ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
            : '';

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // SliverAppBar expansível para o cabeçalho do filme.
              SliverAppBar(
                expandedHeight: 300,
                pinned: true, // A barra de aplicativo permanece visível ao rolar.
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    movie['title'] ?? '', // Título do filme na barra.
                    style: const TextStyle(
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                    ),
                  ),
                  background: backdropUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: backdropUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.movie, size: 64, color: Colors.black54),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.movie, size: 64, color: Colors.black54),
                        ),
                ),
              ),

              // Conteúdo principal dos detalhes do filme.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seção de informações básicas: pôster, título, data de lançamento, avaliação.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pôster do filme.
                          SizedBox(
                            width: 120,
                            height: 180,
                            child: posterUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: posterUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[300],
                                      child: const Center(child: CircularProgressIndicator()),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.movie, size: 32, color: Colors.black54),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.movie, size: 32, color: Colors.black54),
                                  ),
                          ),

                          const SizedBox(width: 16),

                          // Detalhes textuais do filme.
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie['title'] ?? '',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  'Lançamento: ${movie['release_date'] ?? 'N/A'}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${(movie['vote_average'] as num?)?.toStringAsFixed(1) ?? '0.0'}/10',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Botão para favoritar/desfavoritar o filme.
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        // Cria o objeto Movie a partir dos detalhes carregados.
                                        final Movie movieObj = Movie.fromJson(movie);
                                        await viewModel.toggleFavorite(movieObj);
                                      },
                                      icon: Icon(viewModel.isFavorite(widget.movieId) ? Icons.favorite : Icons.favorite_border),
                                      label: Text(viewModel.isFavorite(widget.movieId) ? 'Favorito' : 'Favoritar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: viewModel.isFavorite(widget.movieId) ? Colors.red : null,
                                        foregroundColor: viewModel.isFavorite(widget.movieId) ? Colors.white : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Seção de Gêneros do filme.
                      if (movie['genres'] != null && (movie['genres'] as List).isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gêneros',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (movie['genres'] as List<dynamic>).map<Widget>((genre) {
                                return GenreChip(genreName: genre['name']);
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),

                      // Seção de Sinopse do filme.
                      if (movie['overview'] != null && (movie['overview'] as String).isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sinopse',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              movie['overview'],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),

                      // Seção de Trailer do filme (exibida apenas se houver um controlador de YouTube válido).
                      if (_youtubeController != null && videos.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trailer',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            YoutubePlayer(
                              controller: _youtubeController!,
                              showVideoProgressIndicator: true,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),

                      // Widget para o usuário avaliar o filme.
                      RatingWidget(
                        movieId: widget.movieId,
                        initialRating: viewModel.getMovieRating(widget.movieId),
                        onRatingUpdate: (rating) async {
                          await viewModel.rateMovie(widget.movieId, rating);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}