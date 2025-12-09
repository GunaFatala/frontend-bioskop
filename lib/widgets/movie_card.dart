import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/movie_model.dart';
import '../screens/movie/detail_movie_screen.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailMovieScreen(movieId: movie.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Poster Film (Clean, tanpa rating overlay)
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  movie.posterUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Loading builder biar rapi saat gambar belum muncul
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.movie,
                          color: Colors.grey[300],
                          size: 40,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (ctx, err, stack) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Judul & Info Bawah
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Durasi (Warna abu)
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${movie.durationMinutes} mnt",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 3. Rating & Tombol Beli (GANTINYA HARGA)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating Bintang
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "4.8", // Rating Dummy (bisa dirandom kalau mau variasi)
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      // Tombol "Beli" Kecil
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Pesan",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
