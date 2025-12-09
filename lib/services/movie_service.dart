import 'package:dio/dio.dart';
import '../models/movie_model.dart';
import '../utils/api_constants.dart';

class MovieService {
  final Dio _dio = Dio();

  // Fungsi ambil semua film
  Future<List<Movie>> getAllMovies() async {
    try {
      final response = await _dio.get(ApiConstants.movies);

      if (response.statusCode == 200) {
        // response.data adalah List JSON
        List<dynamic> data = response.data;
        // Ubah List JSON jadi List Movie
        return data.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data film');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
