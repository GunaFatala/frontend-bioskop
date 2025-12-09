class Movie {
  final int id;
  final String title;
  final String description;
  final String posterUrl;
  final int durationMinutes;
  final int price; // Asumsi harga terendah/start from

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.durationMinutes,
    this.price = 50000, // Default value dulu
  });

  // Mengubah JSON dari API menjadi Object Dart
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      posterUrl: json['poster_url'] ?? 'https://via.placeholder.com/300',
      durationMinutes: json['duration_minutes'],
    );
  }
}
