import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';
import '../models/booking_model.dart';

class BookingService {
  final Dio _dio = Dio();

  // 1. Cek Kursi yang sudah laku (Warna Merah)
  Future<List<String>> getBookedSeats(int showtimeId) async {
    try {
      // Ambil token dulu
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/showtimes/$showtimeId/seats',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Wajib bawa token
          },
        ),
      );

      if (response.statusCode == 200) {
        // Konversi ["A1", "A2"] jadi List<String>
        return List<String>.from(response.data);
      }
      return [];
    } catch (e) {
      return []; // Kalau error, anggap kosong dulu
    }
  }

  // 2. Beli Tiket
  Future<bool> createBooking(int showtimeId, List<String> seats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.post(
        ApiConstants.bookings,
        data: {'showtime_id': showtimeId, 'seats': seats},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Gagal booking: $e');
    }
  }

  // 3. Ambil Riwayat Booking (Tiket Saya)
  Future<List<Booking>> getMyBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.get(
        ApiConstants.baseUrl +
            '/my-bookings', // Pastikan endpoint ini benar di api_constants
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Gagal mengambil riwayat: $e');
    }
  }
}
