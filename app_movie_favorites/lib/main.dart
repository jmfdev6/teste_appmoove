import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'core/core.dart';
import 'models/movie.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Erro ao carregar .env: \$e');
  }
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
