import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/core.dart';
import 'models/movie.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  Hive.registerAdapter(MovieAdapter());
  if (!Hive.isBoxOpen('favorites')) {
    await Hive.openBox<Movie>('favorites');
  }
  if (!Hive.isBoxOpen('ratings')) {
    await Hive.openBox<double>('ratings');
  }
  runApp(const Core());
}
