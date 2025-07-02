import 'package:go_router/go_router.dart';
import '../../../views/favorites_screen.dart' show FavoritesScreen;
import '../../../views/home_screen.dart';
import '../../../views/movie_details_screen.dart';
import '../../../views/search_screen.dart';


class AppRouter {
  static const String home = '/home';
  static const String search = '/search';
  static const String movieDetails = '/movie';
  static const String favorites = '/favorites';
  
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
    
      GoRoute(
        path: home,
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: search,
        builder: (context, state) => SearchScreen(),
      ),
      GoRoute(
        path: '$movieDetails/:id',
        builder: (context, state) {
          final movieId = int.parse(state.pathParameters['id']!);
          return MovieDetailsScreen(movieId: movieId);
        },
      ),
      GoRoute(
        path: favorites,
        builder: (context, state) => FavoritesScreen(),
      ),
    ],
  );
}