import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'movie_model.dart';
import 'movie_list_screen.dart';
import 'settings_screen.dart';
import 'theme_cubit.dart';
import 'movie_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MovieAdapter());
  final moviesBox = await Hive.openBox<Movie>('moviesBox');
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()..init()),
        BlocProvider(create: (_) => MovieCubit(moviesBox)..loadMovies()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDarkMode) {
        return MaterialApp(
          title: 'Мои любимые фильмы',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            appBarTheme: const AppBarTheme(
              color: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.blueGrey,
            appBarTheme: const AppBarTheme(
              color: Colors.blueGrey,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.blueGrey,
            ),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const MovieListScreen(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}