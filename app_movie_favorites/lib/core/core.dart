import 'package:app_movie_favorites/core/utils/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/tmdb_repository.dart';

import '../services/tmdb_services.dart';
import '../viewmodels/movie_viewmodel.dart';
import 'utils/app_theme.dart';

class Core extends StatelessWidget {
  const Core({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hive já inicializado em main

    return MultiProvider(
      providers: [
        Provider(create: (_) => TMDBService()),
        ProxyProvider<TMDBService, MovieRepository>(
          update: (_, api, __) => MovieRepository(api),
        ),
        ChangeNotifierProxyProvider<MovieRepository, MovieViewModel>(
          create: (_) => MovieViewModel(),
          update: (_, repo, vm) => vm!..updateRepository(repo),
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
