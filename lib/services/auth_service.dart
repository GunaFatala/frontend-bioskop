import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

class AuthService {
  final Dio _dio = Dio();

  // --- FUNGSI LOGIN ---
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];

        // Simpan Token & Nama User ke Memori HP
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // PENTING: Ambil nama dari response backend dan simpan
        if (data['user'] != null) {
          await prefs.setString('user_name', data['user']['name']);
        }

        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Login Gagal');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // --- FUNGSI REGISTER ---
  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', token);
        // Simpan nama langsung dari inputan (karena user baru daftar)
        await prefs.setString('user_name', name);

        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal Mendaftar');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus Token & Nama
  }

  // --- CEK STATUS LOGIN ---
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }
}
