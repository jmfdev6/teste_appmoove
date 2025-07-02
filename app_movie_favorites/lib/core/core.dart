import 'package:app_movie_favorites/core/utils/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/movie_repository.dart';

import '../services/tmdb_services.dart';
import '../viewmodels/movie_viewmodel.dart';
import 'utils/app_theme.dart';

class Core extends StatelessWidget {
  const Core({super.key});

  @override
  Widget build(BuildContext context) {
  

    return MultiProvider(
      providers: [
        // Fornece o TMDBService
        Provider(create: (_) => TMDBService()),
        
        // Fornece o MovieRepository, que depende do TMDBService
        ProxyProvider<TMDBService, MovieRepository>(
          update: (_, tmdbService, __) => MovieRepository(tmdbService),
        ),
        
        // Fornece o MovieViewModel, que depende do MovieRepository.
        // O `update` é chamado quando o MovieRepository está disponível.
        ChangeNotifierProxyProvider<MovieRepository, MovieViewModel>(

          create: (context) => MovieViewModel(repository: Provider.of<MovieRepository>(context, listen: false)),
          update: (context, repo, previousViewModel) {

            return MovieViewModel(repository: repo);
          },
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'TMDB Movies',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}