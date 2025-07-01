import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../core/utils/routes/app_routes.dart';
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
  Map<String, dynamic>? movieDetails;
  List<Map<String, dynamic>> videos = [];
  bool isLoading = true;
  String? error;
  YoutubePlayerController? _youtubeController;
  
  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }
  
  Future<void> _loadMovieDetails() async {
    try {
      final repository = context.read<MovieViewModel>().repository;
      if (repository != null) {
        final details = await repository.getMovieDetails(widget.movieId);
        final movieVideos = await repository.getMovieVideos(widget.movieId);
        
        setState(() {
          movieDetails = details;
          videos = movieVideos;
          isLoading = false;
        });
        
        _initializeYoutubePlayer();
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }
  
  void _initializeYoutubePlayer() {
    final trailer = videos.firstWhere(
      (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
      orElse: () => {},
    );
    
    if (trailer.isNotEmpty) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: trailer['key'],
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (error != null) {
      return Scaffold(
        appBar: AppBar(
           actions: [
          IconButton(
            onPressed: () {
              AppRouter.router.pop();
            },
            icon: Icon(Icons.close),
          ),
        ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Erro ao carregar detalhes'),
              SizedBox(height: 8),
              Text(error!),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    error = null;
                  });
                  _loadMovieDetails();
                },
                child: Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    
    final movie = movieDetails!;
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
                style: TextStyle(
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
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.movie, size: 64),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.movie, size: 64),
                    ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                  // Informações básicas
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster
                      Container(
                        width: 120,
                        height: 180,
                        child: movie['poster_path'] != null
                            ? CachedNetworkImage(
                                imageUrl: 'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.movie, size: 32),
                                ),
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.movie, size: 32),
                              ),
                      ),
                      
                      SizedBox(width: 16),
                      
                      // Informações
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
                            
                            SizedBox(height: 8),
                            
                            Text(
                              'Lançamento: ${movie['release_date'] ?? 'N/A'}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            
                            SizedBox(height: 8),
                            
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  '${movie['vote_average']?.toString() ?? '0'}/10',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Botões de ação
                            Consumer<MovieViewModel>(
                              builder: (context, viewModel, child) {
                                final isFav = viewModel.isFavorite(widget.movieId);
                                
                                return Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final movieObj = Movie(
                                          id: movie['id'],
                                          title: movie['title'] ?? '',
                                          overview: movie['overview'] ?? '',
                                          posterPath: movie['poster_path'],
                                          backdropPath: movie['backdrop_path'],
                                          releaseDate: movie['release_date'] ?? '',
                                          voteAverage: (movie['vote_average'] ?? 0).toDouble(),
                                          genreIds: List<int>.from(movie['genres']?.map((g) => g['id']) ?? []),
                                                                                );
                                        await viewModel.toggleFavorite(movieObj);
                                      },
                                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                                      label: Text(isFav ? 'Favorito' : 'Favoritar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isFav ? Colors.red : null,
                                        foregroundColor: isFav ? Colors.white : null,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Gêneros
                  if (movie['genres'] != null && movie['genres'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gêneros',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: movie['genres'].map<Widget>((genre) {
                            return GenreChip(genreName: genre['name']);
                          }).toList(),
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  
                  // Sinopse
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
                        SizedBox(height: 8),
                        Text(
                          movie['overview'],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  
                  // Trailer
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
                        SizedBox(height: 8),
                        YoutubePlayer(
                          controller: _youtubeController!,
                          showVideoProgressIndicator: true,
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  
                  // Avaliação do usuário
                  Consumer<MovieViewModel>(
                    builder: (context, viewModel, child) {
                      return RatingWidget(
                        movieId: widget.movieId,
                        initialRating: viewModel.getMovieRating(widget.movieId),
                        onRatingUpdate: (rating) async {
                          await viewModel.rateMovie(widget.movieId, rating);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}