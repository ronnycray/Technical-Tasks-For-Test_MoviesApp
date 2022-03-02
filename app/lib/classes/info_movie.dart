import 'package:MoveisApp/classes/cast.dart';
import 'package:MoveisApp/classes/movie.dart';

class MovieInformation {
  Movie movie;
  List<Cast> casts;

  MovieInformation({required this.movie, required this.casts});
}
