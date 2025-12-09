class Movie {
  final int id;
  final String title;
  final String description;
  final String posterUrl;
  final int durationMinutes;
  final int price;
  final List<Showtime> showtimes; // <--- Kita tambah ini

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.durationMinutes,
    this.price = 50000,
    this.showtimes = const [],
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    // Cek apakah ada data 'showtimes' di JSON? Kalau ada, kita parsing.
    var list = json['showtimes'] as List?;
    List<Showtime> scheduleList = list != null
        ? list.map((i) => Showtime.fromJson(i)).toList()
        : [];

    return Movie(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      posterUrl: json['poster_url'] ?? 'https://via.placeholder.com/300',
      durationMinutes: json['duration_minutes'],
      showtimes: scheduleList,
    );
  }
}

class Showtime {
  final int id;
  final String startTime;
  final int price;
  final String studioName;
  final int rows; // Tambahan: Jumlah baris
  final int cols; // Tambahan: Jumlah kolom

  Showtime({
    required this.id,
    required this.startTime,
    required this.price,
    required this.studioName,
    required this.rows,
    required this.cols,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    return Showtime(
      id: json['id'],
      startTime: json['start_time'],
      price: json['price'],
      studioName: json['studio'] != null
          ? json['studio']['name']
          : 'Unknown Studio',
      // Ambil ukuran studio, default 8x10 kalau null
      rows: json['studio'] != null ? json['studio']['total_rows'] : 8,
      cols: json['studio'] != null ? json['studio']['total_cols'] : 10,
    );
  }
}
