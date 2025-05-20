import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'movie_model.dart';

class MovieCubit extends Cubit<List<Movie>> {
  final Box<Movie> _moviesBox;

  MovieCubit(this._moviesBox) : super(_moviesBox.values.toList());

  void loadMovies() {
    emit(_moviesBox.values.toList());
  }

  void addMovie(Movie movie) {
    _moviesBox.add(movie);
    loadMovies();
  }

  void updateMovie(int index, Movie movie) {
    _moviesBox.putAt(index, movie);
    loadMovies();
  }

  void deleteMovie(int index) {
    _moviesBox.deleteAt(index);
    loadMovies();
  }

  void sortMovies(String sortBy) {
    final movies = List<Movie>.from(state);
    
    switch (sortBy) {
      case 'title_asc':
        movies.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'title_desc':
        movies.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'year_asc':
        movies.sort((a, b) => a.year.compareTo(b.year));
        break;
      case 'year_desc':
        movies.sort((a, b) => b.year.compareTo(a.year));
        break;
      case 'rating_asc':
        movies.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case 'rating_desc':
        movies.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    emit(movies);
  }
}