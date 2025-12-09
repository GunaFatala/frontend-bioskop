import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

class AuthService {
  final Dio _dio = Dio();

  // Fungsi Login
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Wajib buat Laravel
            'Accept': 'application/json',
          },
          validateStatus: (status) =>
              status! < 500, // Biar 401 gak dianggap crash
        ),
      );

      if (response.statusCode == 200) {
        // Login Sukses!
        final token = response.data['token'];

        // Simpan Token di HP biar gak login-login terus
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // Simpan juga nama user kalau perlu (opsional)
        // await prefs.setString('user_name', response.data['user']['name']);

        return true;
      } else {
        // Login Gagal (Password salah / Email gak ada)
        throw Exception(response.data['message'] ?? 'Login Gagal');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data login dari HP
  }

  // Cek apakah user sudah login sebelumnya
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }
}
