import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'movie_model.dart';
import 'movie_cubit.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои любимые фильмы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: BlocBuilder<MovieCubit, List<Movie>>(
        builder: (context, movies) {
          if (movies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie, size: 50, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Список фильмов пуст',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Нажмите "+" чтобы добавить фильм'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _addOrEditMovie(context, index: index),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: movie.imagePath != null
                              ? Image.file(
                                  File(movie.imagePath!),
                                  width: 80,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 80,
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.movie, size: 40),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Режиссер: ${movie.director}',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Год: ${movie.year} • Жанр: ${movie.genre}',
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber[600], size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    movie.rating.toStringAsFixed(1),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Text('/10'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _addOrEditMovie(context, index: index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMovie(context, index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditMovie(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  static Future<void> _addOrEditMovie(BuildContext context, {int? index}) async {
    final cubit = context.read<MovieCubit>();
    final isEditing = index != null;
    final movie = isEditing ? cubit.state[index] : null;
    final _genreOptions = [
      'Боевик', 'Комедия', 'Драма', 'Фантастика', 'Ужасы', 
      'Триллер', 'Романтика', 'Анимация', 'Документальный', 'Не указан'
    ];
    final _picker = ImagePicker();

    final titleController = TextEditingController(text: movie?.title ?? '');
    final directorController = TextEditingController(text: movie?.director ?? '');
    final yearController = TextEditingController(text: movie?.year.toString() ?? '');
    final ratingController = TextEditingController(text: movie?.rating.toString() ?? '0');
    String selectedGenre = movie?.genre ?? 'Не указан';
    String? imagePath = movie?.imagePath;
    File? imageFile;

    if (isEditing && imagePath != null) {
      imageFile = File(imagePath);
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? 'Редактировать фильм' : 'Добавить фильм'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final source = await showDialog<ImageSource>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Выберите источник'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, ImageSource.camera),
                              child: const Text('Камера'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, ImageSource.gallery),
                              child: const Text('Галерея'),
                            ),
                          ],
                        ),
                      );
                      if (source != null) {
                        final image = await _picker.pickImage(source: source);
                        if (image != null) {
                          setState(() {
                            imageFile = File(image.path);
                            imagePath = image.path;
                          });
                        }
                      }
                    },
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        image: imageFile != null || imagePath != null
                            ? DecorationImage(
                                image: FileImage(imageFile ?? File(imagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imageFile == null && imagePath == null
                          ? const Icon(Icons.add_a_photo, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Название фильма*',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: directorController,
                    decoration: const InputDecoration(
                      labelText: 'Режиссер*',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: yearController,
                    decoration: const InputDecoration(
                      labelText: 'Год выпуска*',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedGenre,
                    items: _genreOptions.map((genre) {
                      return DropdownMenuItem(
                        value: genre,
                        child: Text(genre),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGenre = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Жанр',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ratingController,
                    decoration: const InputDecoration(
                      labelText: 'Рейтинг (0-10)',
                      hintText: 'Введите число от 0 до 10',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty &&
                      directorController.text.isNotEmpty &&
                      yearController.text.isNotEmpty) {
                    final rating = double.tryParse(ratingController.text) ?? 0;
                    final newMovie = Movie(
                      title: titleController.text,
                      director: directorController.text,
                      year: int.parse(yearController.text),
                      genre: selectedGenre,
                      rating: rating.clamp(0, 10),
                      imagePath: imagePath,
                    );

                    if (isEditing) {
                      cubit.updateMovie(index!, newMovie);
                    } else {
                      cubit.addMovie(newMovie);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(isEditing ? 'Сохранить' : 'Добавить'),
              ),
            ],
          );
        },
      ),
    );
  }

  static void _deleteMovie(BuildContext context, int index) {
    final cubit = context.read<MovieCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить фильм?'),
        content: const Text('Вы уверены, что хотите удалить этот фильм из списка?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              cubit.deleteMovie(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Фильм удален')),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void _showSortOptions(BuildContext context) {
  final cubit = context.read<MovieCubit>();
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(13.0),
                child: Text(
                  'Сортировать по',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.sort_by_alpha),
                      title: const Text('Названию (А-Я)'),
                      onTap: () {
                        cubit.sortMovies('title_asc');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.sort_by_alpha),
                      title: const Text('Названию (Я-А)'),
                      onTap: () {
                        cubit.sortMovies('title_desc');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Году (новые)'),
                      onTap: () {
                        cubit.sortMovies('year_desc');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Году (старые)'),
                      onTap: () {
                        cubit.sortMovies('year_asc');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.star),
                      title: const Text('Рейтингу (высокий)'),
                      onTap: () {
                        cubit.sortMovies('rating_desc');
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.star_border),
                      title: const Text('Рейтингу (низкий)'),
                      onTap: () {
                        cubit.sortMovies('rating_asc');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}