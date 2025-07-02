import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../models/movie.dart';
import '../../../viewmodels/movie_viewmodel.dart';
import '../routes/app_routes.dart';

class MovieListItem extends StatelessWidget {
  final Movie movie;
  
  const MovieListItem({super.key, required this.movie});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => context.push('${AppRouter.movieDetails}/${movie.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Poster
              SizedBox(
                width: 80,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: movie.posterUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: movie.posterUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.movie, size: 24),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.movie, size: 24),
                        ),
                ),
              ),
              
              SizedBox(width: 12),
              
              // Movie info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 4),
                    
                    Text(
                      movie.releaseDate.isNotEmpty ? movie.releaseDate : 'Data não disponível',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    
                    SizedBox(height: 8),
                    
                    Text(
                      movie.overview,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        
                        Spacer(),
                        
                        Consumer<MovieViewModel>(
                          builder: (context, viewModel, child) {
                            final isFavorite = viewModel.isFavorite(movie.id);
                            return IconButton(
                              onPressed: () => viewModel.toggleFavorite(movie),
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : null,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}