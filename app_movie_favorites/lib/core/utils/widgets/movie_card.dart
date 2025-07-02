import 'package:app_movie_favorites/models/movie.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';


class MovieCard extends StatelessWidget {
  final Movie movie;
  
  const MovieCard({super.key, required this.movie});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('${AppRouter.movieDetails}/${movie.id}'),
      child: SizedBox(
        width: 140,
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              SizedBox(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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
                            child: Icon(Icons.movie, size: 32),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.movie, size: 32),
                        ),
                ),
              ),
              
              // Movie info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      Spacer(),
                      
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          SizedBox(width: 2),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
