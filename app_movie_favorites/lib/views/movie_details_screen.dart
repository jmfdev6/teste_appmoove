import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Hive, video_player e chewie não são mais necessários para o player
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // ADICIONADO
import '../models/movie.dart';
import '../viewmodels/movie_viewmodel.dart';
import '../core/utils/widgets/rating_widget.dart';
import '../core/utils/widgets/genre_chip.dart';
import 'package:cached_network_image/cached_network_image.dart';

const String _kTmdbImageBaseUrl = 'https://image.tmdb.org/t/p/';
const String _kBackdropSize = 'w780';
const String _kPosterSize = 'w500';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;
  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  MovieDetailsScreenState createState() => MovieDetailsScreenState();
}

class MovieDetailsScreenState extends State<MovieDetailsScreen> {
  // MUITO MAIS SIMPLES AGORA
  YoutubePlayerController? _youtubeController;
  String? _initializedVideoKey;
  bool _isInitializingPlayer = false;

  @override
  void initState() {
    super.initState();
    // Não precisa mais de _openCache para o player
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = Provider.of<MovieViewModel>(context, listen: false);
    if (!vm.isMovieDataValid(widget.movieId)) {
       vm.loadMovieDetails(widget.movieId);
    }
  }

  @override
  void didUpdateWidget(covariant MovieDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movieId != widget.movieId) {
      _resetPlayerState(); // Agora isso só lida com o YoutubePlayerController
      final vm = Provider.of<MovieViewModel>(context, listen: false);
      vm.clearMovieDetails();
      vm.loadMovieDetails(widget.movieId);
    }
  }

  void _resetPlayerState() {
    _disposePlayer();
    if (mounted) {
      setState(() {
        _initializedVideoKey = null;
        _isInitializingPlayer = false;
      });
    }
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  void _disposePlayer() {
    _youtubeController?.dispose();
    _youtubeController = null;
  }

  // 👇 VEJA COMO ESTE MÉTODO FICOU SIMPLES 👇
  void _initializePlayer(String key) {
    if (_isInitializingPlayer) return;
    if (mounted) setState(() => _isInitializingPlayer = true);

    _disposePlayer(); // Garante que o controller antigo seja descartado

    // Apenas cria um novo controller. Sem try/catch, sem manifest!
    _youtubeController = YoutubePlayerController(
      initialVideoId: key,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        forceHD: false, // Pode forçar HD se quiser
      ),
    );

    if (mounted) {
      setState(() {
        _initializedVideoKey = key;
        _isInitializingPlayer = false; // Pode ser falso, o player tem seu próprio loading
      });
    }
  }
  
  String? _getTrailerKey(MovieState state) {
    if (state.currentMovieVideos.isEmpty) return null;
    final validVideos = state.currentMovieVideos.where((v) =>
        v['site']?.toLowerCase() == 'youtube' &&
        (v['key'] as String?)?.isNotEmpty == true);
    if (validVideos.isEmpty) return null;
    return validVideos.firstWhere(
      (v) => v['type']?.toLowerCase() == 'trailer',
      orElse: () => validVideos.first,
    )['key'];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieViewModel>(
      builder: (context, vm, _) {
        final state = vm.state;
        if (state.isMovieDetailLoading || !vm.isMovieDataValid(widget.movieId)) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state.movieDetailError != null) {
          return _buildErrorWidget(context, state.movieDetailError, vm);
        }

        final movie = state.currentMovieDetails!;
        final trailerKey = _getTrailerKey(state);
        final backdropPath = movie['backdrop_path'] as String?;
        final backdropUrl = backdropPath?.isNotEmpty == true
            ? '$_kTmdbImageBaseUrl$_kBackdropSize$backdropPath'
            : null;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                actions: [
                  IconButton(
                    icon: Icon(vm.isFavorite(widget.movieId) ? Icons.favorite : Icons.favorite_border, size: 30),
                    color: vm.isFavorite(widget.movieId) ? Colors.redAccent : Colors.white,
                    onPressed: () => vm.toggleFavorite(Movie.fromJson(movie)),
                  )
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(movie['title'] as String? ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, shadows: [Shadow(offset: Offset(1.0, 1.0), blurRadius: 3.0, color: Colors.black54)])),
                  background: backdropUrl != null
                      ? CachedNetworkImage(imageUrl: backdropUrl, fit: BoxFit.cover, errorWidget: (c, u, e) => Container(color: Colors.grey[300], child: const Icon(Icons.error, color: Colors.grey)))
                      : Container(color: Colors.grey[300], child: const Icon(Icons.movie, size: 48, color: Colors.grey)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMovieHeader(context, movie),
                      const SizedBox(height: 24),
                      if (trailerKey != null) ...[
                        Text('Trailer', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildTrailerSection(trailerKey), // 👇 UI ATUALIZADA
                        const SizedBox(height: 24),
                      ],
                      if (movie['genres'] != null && (movie['genres'] as List).isNotEmpty) ...[
                        Text('Gêneros', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, runSpacing: 8, children: (movie['genres'] as List).map((g) => GenreChip(genreName: g['name'] ?? '')).toList()),
                        const SizedBox(height: 24),
                      ],
                      if (movie['overview'] != null && (movie['overview'] as String).isNotEmpty) ...[
                        Text('Sinopse', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(movie['overview'] as String, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
                        const SizedBox(height: 24),
                      ],
                      RatingWidget(
                        movieId: widget.movieId,
                        initialRating: vm.getMovieRating(widget.movieId),
                        onRatingUpdate: (r) => vm.rateMovie(widget.movieId, r),
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

  // 👇 UI DO TRAILER ATUALIZADA PARA O NOVO PACOTE
  Widget _buildTrailerSection(String trailerKey) {
    if (_youtubeController != null && _initializedVideoKey == trailerKey) {
      return Container(
        // ignore: deprecated_member_use
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.redAccent,
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () => _initializePlayer(trailerKey),
      child: Container(
        // ignore: deprecated_member_use
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: 'https://img.youtube.com/vi/$trailerKey/maxresdefault.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorWidget: (context, url, error) => Container(color: Colors.grey[300], child: const Icon(Icons.error, color: Colors.grey)),
                ),
                // ignore: deprecated_member_use
                Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)]))),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                    SizedBox(height: 8),
                    Text('Ver trailer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
   Widget _buildErrorWidget(BuildContext context, String? error, MovieViewModel vm) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erro')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                error ?? 'Erro ao carregar detalhes',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  vm.clearMovieDetails();
                  vm.loadMovieDetails(widget.movieId);
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieHeader(BuildContext context, Map<String, dynamic> movie) {
    final posterPath = movie['poster_path'] as String?;
    final posterUrl = posterPath?.isNotEmpty == true
        ? '$_kTmdbImageBaseUrl$_kPosterSize$posterPath'
        : null;
    
    final releaseDate = movie['release_date'] as String?;
    final rating = movie['vote_average'];
    final voteCount = movie['vote_count'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 120,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: posterUrl != null
                ? CachedNetworkImage(
                    imageUrl: posterUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.movie, color: Colors.grey),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.movie, color: Colors.grey),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie['title'] as String? ?? 'Título não disponível',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (releaseDate != null && releaseDate.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Lançamento: $releaseDate',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (rating != null && rating > 0) ...[
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${rating.toStringAsFixed(1)}/10',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (voteCount != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        '($voteCount votos)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ... (Widgets _buildErrorWidget e _buildMovieHeader permanecem os mesmos)
}