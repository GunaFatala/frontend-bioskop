class Booking {
  final int id;
  final String bookingCode;
  final int totalPrice;
  final String status;
  final String movieTitle;
  final String posterUrl;
  final String studioName;
  final String startTime;
  final List<String> seats;

  Booking({
    required this.id,
    required this.bookingCode,
    required this.totalPrice,
    required this.status,
    required this.movieTitle,
    required this.posterUrl,
    required this.studioName,
    required this.startTime,
    required this.seats,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Parsing data bersarang (Nested JSON) dari Laravel
    var showtime = json['showtime'];
    var movie = showtime['movie'];
    var studio = showtime['studio'];
    var tickets = json['tickets'] as List;

    return Booking(
      id: json['id'],
      bookingCode: json['booking_code'],
      totalPrice: json['total_price'],
      status: json['status'],
      movieTitle: movie['title'],
      posterUrl: movie['poster_url'] ?? 'https://via.placeholder.com/150',
      studioName: studio['name'],
      startTime: showtime['start_time'],
      // Ambil semua nomor kursi dari list tiket
      seats: tickets.map((t) => t['seat_number'] as String).toList(),
    );
  }
}
