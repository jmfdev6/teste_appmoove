import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/movie.dart';
import '../viewmodels/movie_viewmodel.dart';
import '../core/utils/widgets/rating_widget.dart';
import '../core/utils/widgets/genre_chip.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  MovieDetailsScreenState createState() => MovieDetailsScreenState();
}

class MovieDetailsScreenState extends State<MovieDetailsScreen> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    loadMovieDetails();
  }

  void loadMovieDetails() {
    // CORREÇÃO: Adicionar o parâmetro Duration que é esperado
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      Provider.of<MovieViewModel>(context, listen: false)
          .loadMovieDetails(widget.movieId);
    });
  }

  void _initializeYoutubePlayer(List<Map<String, dynamic>> videos) {
    // Localiza trailer YouTube
    final trailer = videos.firstWhere(
      (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
      orElse: () => {},
    );

    if (trailer.isNotEmpty && trailer['key'] != null) {
      final videoKey = trailer['key'] as String;
      // Se controller inexistente ou vídeo diferente, (re)inicializa
      if (_youtubeController == null || _youtubeController!.initialVideoId != videoKey) {
        // descarta anterior
        _youtubeController?.pause();
        _youtubeController?.dispose();
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoKey,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      }
    } else {
      // Sem trailer, descarta
      _youtubeController?.pause();
      _youtubeController?.dispose();
      _youtubeController = null;
    }
  }

  @override
  void dispose() {
    _youtubeController?.pause();
    _youtubeController?.dispose();
    super.dispose();
  }

  Widget _buildErrorWidget(BuildContext context, String? error, MovieViewModel viewModel) {
    return Scaffold(
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
                error ?? 'Detalhes não disponíveis.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => viewModel.loadMovieDetails(widget.movieId),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieHeader(BuildContext context, Map<String, dynamic> movie, MovieViewModel viewModel) {
    // CORREÇÃO: Remover markdown da URL do poster
    final posterUrl = movie['poster_path'] != null
        ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
        : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              ElevatedButton.icon(
                onPressed: () async {
                  final movieObj = Movie.fromJson(movie);
                  await viewModel.toggleFavorite(movieObj);
                },
                icon: Icon(viewModel.isFavorite(widget.movieId)
                    ? Icons.favorite
                    : Icons.favorite_border),
                label: Text(viewModel.isFavorite(widget.movieId)
                    ? 'Favorito'
                    : 'Favoritar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: viewModel.isFavorite(widget.movieId)
                      ? Colors.red
                      : null,
                  foregroundColor: viewModel.isFavorite(widget.movieId)
                      ? Colors.white
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.state.isMovieDetailLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.state.movieDetailError != null ||
            viewModel.state.currentMovieDetails == null) {
          return _buildErrorWidget(
            context,
            viewModel.state.movieDetailError,
            viewModel,
          );
        }

        final movie = viewModel.state.currentMovieDetails!;
        final videos = viewModel.state.currentMovieVideos;

        // Atualiza o player sempre que vídeos mudam
        WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
          _initializeYoutubePlayer(videos);
        });

        final backdropUrl = movie['backdrop_path'] != null
            ? 'https://image.tmdb.org/t/p/w780${movie['backdrop_path']}'
            : '';

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    movie['title'] ?? '',
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMovieHeader(context, movie, viewModel),
                      const SizedBox(height: 24),
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
                      if (movie['overview'] != null && movie['overview'].isNotEmpty)
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
                      if (_youtubeController != null)
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
                              onEnded: (_) {
                                _youtubeController?.seekTo(Duration.zero);
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      RatingWidget(
                        movieId: widget.movieId,
                        initialRating: viewModel.getMovieRating(widget.movieId),
                        onRatingUpdate: (rating) {
                          viewModel.rateMovie(widget.movieId, rating);
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