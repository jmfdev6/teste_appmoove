import 'dart:ui'; // ADICIONADO: Para o efeito de blur
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
  // --- TODA A LÓGICA PERMANECE A MESMA ---
  YoutubePlayerController? _youtubeController;
  String? _initializedVideoKey;
  bool _isPlayerFullScreen = false;

  @override
  void initState() {
    super.initState();
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
      _resetPlayerState();
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
      });
    }
  }

  @override
  void dispose() {
    _disposePlayer();
    _exitFullScreen();
    super.dispose();
  }

  void _disposePlayer() {
    _youtubeController?.removeListener(_fullScreenListener);
    _youtubeController?.dispose();
    _youtubeController = null;
  }

  Future<void> _fullScreenListener() async {
    if (_youtubeController == null) return;
    if (_youtubeController!.value.isFullScreen != _isPlayerFullScreen) {
      if (_youtubeController!.value.isFullScreen) {
        await _enterFullScreen();
      } else {
        await _exitFullScreen();
      }
      if (mounted) {
        setState(() {
          _isPlayerFullScreen = _youtubeController!.value.isFullScreen;
        });
      }
    }
  }

  Future<void> _enterFullScreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _exitFullScreen() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _initializePlayer(String key) {
    _disposePlayer();
    _youtubeController = YoutubePlayerController(
      initialVideoId: key,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        forceHD: false,
        enableCaption: false,
      ),
    )..addListener(_fullScreenListener);
    if (mounted) {
      setState(() {
        _initializedVideoKey = key;
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
  // --- FIM DA LÓGICA ---

  // ✅ --- INÍCIO DA NOVA UI --- ✅
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MovieViewModel>();
    final trailerKey = _getTrailerKey(vm.state);

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _youtubeController ?? YoutubePlayerController(initialVideoId: ''),
      ),
      builder: (context, player) {
        return PopScope(
          canPop: !_isPlayerFullScreen,
          onPopInvoked: (didPop) {
            if (didPop) return;
            if (_isPlayerFullScreen) {
              _youtubeController?.toggleFullScreenMode();
            }
          },
          child: Scaffold(
            body: _isPlayerFullScreen
                ? Center(child: player)
                : _buildNormalUI(vm, trailerKey, player),
          ),
        );
      },
    );
  }

  Widget _buildNormalUI(MovieViewModel vm, String? trailerKey, Widget player) {
    final state = vm.state;
    if (state.isMovieDetailLoading || !vm.isMovieDataValid(widget.movieId)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.movieDetailError != null) {
      return _buildErrorWidget(context, state.movieDetailError, vm);
    }
    
    final movie = state.currentMovieDetails!;
    final backdropPath = movie['backdrop_path'] as String?;
    final backdropUrl = backdropPath?.isNotEmpty == true
        ? '$_kTmdbImageBaseUrl$_kBackdropSize$backdropPath'
        : null;

    // A UI agora é um Stack para o efeito de fundo
    return Stack(
      children: [
        // 1. O fundo com blur
        if (backdropUrl != null) ...[
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: backdropUrl,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
        ],

        // 2. Conteúdo rolável sobre o fundo
        CustomScrollView(
          slivers: [
            // AppBar transparente com botões de voltar e favoritar
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(vm.isFavorite(widget.movieId) ? Icons.favorite : Icons.favorite_border, size: 28),
                  color: vm.isFavorite(widget.movieId) ? Colors.redAccent : Colors.white,
                  onPressed: () => vm.toggleFavorite(Movie.fromJson(movie)),
                )
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMovieHeader(context, movie), // Header redesenhado
                    const SizedBox(height: 24),
                    if ((movie['genres'] as List).isNotEmpty) ...[
                      _buildSectionTitle('Gêneros'),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8, children: (movie['genres'] as List).map((g) => GenreChip(genreName: g['name'] ?? '')).toList()),
                      const SizedBox(height: 24),
                    ],
                    if (trailerKey != null) ...[
                      _buildSectionTitle('Trailer'),
                      const SizedBox(height: 12),
                      _buildTrailerSection(trailerKey, player),
                      const SizedBox(height: 24),
                    ],
                    if ((movie['overview'] as String).isNotEmpty) ...[
                      _buildSectionTitle('Sinopse'),
                      const SizedBox(height: 8),
                      Text(movie['overview'] as String, style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5, fontSize: 15)),
                      const SizedBox(height: 24),
                    ],
                    const SizedBox(height: 8),
                    RatingWidget(
                      movieId: widget.movieId,
                      initialRating: vm.getMovieRating(widget.movieId),
                      onRatingUpdate: (r) => vm.rateMovie(widget.movieId, r),
                    ),
                    const SizedBox(height: 40), // Espaço extra no final
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  // Widget helper para os títulos das seções
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  // Header redesenhado para a nova UI
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
          width: 140,
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: posterUrl != null
                ? CachedNetworkImage(imageUrl: posterUrl, fit: BoxFit.cover)
                : Container(color: Colors.grey[800], child: const Icon(Icons.movie, color: Colors.white24)),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10), // Alinhamento vertical
              Text(
                movie['title'] as String? ?? 'Título não disponível',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (releaseDate != null && releaseDate.isNotEmpty)
                _buildInfoRow(Icons.calendar_today_outlined, 'Lançamento: $releaseDate'),
              const SizedBox(height: 8),
              if (rating != null && rating > 0)
                _buildInfoRow(Icons.star_rate_rounded, '${rating.toStringAsFixed(1)}/10 (${voteCount ?? 0} votos)'),
            ],
          ),
        ),
      ],
    );
  }

  // Widget helper para as linhas de informação (data, avaliação)
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14))),
      ],
    );
  }

  // O resto dos widgets (trailer, erro) permanecem iguais
  Widget _buildTrailerSection(String trailerKey, Widget player) {
    if (_youtubeController != null && _initializedVideoKey == trailerKey) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: player,
      );
    }
    return GestureDetector(
      onTap: () => _initializePlayer(trailerKey),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: 'https://img.youtube.com/vi/$trailerKey/maxresdefault.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              Container(color: Colors.black.withOpacity(0.3)),
              const Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
            ],
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
              Text(error ?? 'Erro ao carregar detalhes', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
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


}