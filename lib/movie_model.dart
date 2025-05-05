import 'package:hive/hive.dart';

part 'movie_model.g.dart';

@HiveType(typeId: 0)
class Movie {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String director;

  @HiveField(2)
  final int year;

  @HiveField(3)
  final String genre;

  @HiveField(4)
  final double rating;

  @HiveField(5)
  final String? imagePath;

  Movie({
    required this.title,
    required this.director,
    required this.year,
    this.genre = 'Не указан',
    this.rating = 0,
    this.imagePath,
  });

  Movie copyWith({
    String? title,
    String? director,
    int? year,
    String? genre,
    double? rating,
    String? imagePath,
  }) {
    return Movie(
      title: title ?? this.title,
      director: director ?? this.director,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}