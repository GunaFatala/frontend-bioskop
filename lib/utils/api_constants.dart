class ApiConstants {
  // ✅ KHUSUS CHROME / FLUTTER WEB
  // Gunakan localhost atau 127.0.0.1 dan port server Laravel kamu (biasanya 8000)
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // -- Endpoints --
  static const String login = "$baseUrl/login";
  static const String register = "$baseUrl/register";
  static const String movies = "$baseUrl/movies";
  static const String bookings = "$baseUrl/bookings";
  static const String myBookings = "$baseUrl/my-bookings";

  // URL untuk gambar dummy
  static const String imageBaseUrl = "https://via.placeholder.com/300";
}
