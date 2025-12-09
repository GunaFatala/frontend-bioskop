import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/movie_model.dart';
import '../../services/movie_service.dart';
import 'seat_selection_screen.dart';

class DetailMovieScreen extends StatefulWidget {
  final int movieId;

  const DetailMovieScreen({super.key, required this.movieId});

  @override
  State<DetailMovieScreen> createState() => _DetailMovieScreenState();
}

class _DetailMovieScreenState extends State<DetailMovieScreen> {
  final MovieService _movieService = MovieService();
  Movie? _movie;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  void _fetchDetail() async {
    try {
      final data = await _movieService.getMovieDetail(widget.movieId);
      setState(() {
        _movie = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // Helper Format Jam (14:00)
  String formatTime(String fullDate) {
    try {
      DateTime dt = DateTime.parse(fullDate);
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return fullDate;
    }
  }

  // Helper Format Header Tanggal (Senin, 22 Des)
  String formatDateHeader(String fullDate) {
    try {
      DateTime dt = DateTime.parse(fullDate);
      return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(dt);
    } catch (e) {
      return fullDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_movie == null) {
      return const Scaffold(body: Center(child: Text("Data tidak ditemukan")));
    }

    return Scaffold(
      backgroundColor: Colors.white, // Background bersih
      body: CustomScrollView(
        slivers: [
          // 1. HEADER POSTER (Cinematic)
          SliverAppBar(
            expandedHeight: 450,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _movie!.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) =>
                        Container(color: Colors.grey[300]),
                  ),
                  // Gradient Bawah
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.9),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  // Info Judul di atas Gradient
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _movie!.title,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildGlassBadge(
                              Icons.timer_outlined,
                              "${_movie!.durationMinutes} Menit",
                            ),
                            const SizedBox(width: 8),
                            _buildGlassBadge(
                              Icons.star_rounded,
                              "4.8",
                              color: Colors.amber,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. KONTEN BODY
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SINOPSIS
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sinopsis",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _movie!.description,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                    thickness: 8,
                    color: Color(0xFFF5F7FA),
                  ), // Pemisah Tebal Abu-abu
                  // JADWAL TAYANG
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Jadwal Tayang",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Pilih waktu yang cocok buat kamu",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _movie!.showtimes.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    "Belum ada jadwal.",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            : _buildGroupedShowtimes(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIKA GROUPING JADWAL (UI RAPIH) ---
  Widget _buildGroupedShowtimes() {
    // 1. Grouping by DATE
    Map<String, List<dynamic>> groupedByDate = {};
    for (var schedule in _movie!.showtimes) {
      String dateKey = schedule.startTime.split(' ')[0];
      if (!groupedByDate.containsKey(dateKey)) {
        groupedByDate[dateKey] = [];
      }
      groupedByDate[dateKey]!.add(schedule);
    }

    return Column(
      children: groupedByDate.entries.map((entry) {
        String dateKey = entry.key;
        List<dynamic> schedulesInDate = entry.value;

        // 2. Grouping by STUDIO (Inside Date)
        Map<String, List<dynamic>> groupedByStudio = {};
        for (var schedule in schedulesInDate) {
          if (!groupedByStudio.containsKey(schedule.studioName)) {
            groupedByStudio[schedule.studioName] = [];
          }
          groupedByStudio[schedule.studioName]!.add(schedule);
        }

        // TAMPILAN PER TANGGAL (CARD)
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Tanggal (Blok Biru Muda)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatDateHeader(dateKey),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // List Studio di Tanggal Tersebut
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: groupedByStudio.entries.map((studioEntry) {
                    bool isLast = studioEntry.key == groupedByStudio.keys.last;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Studio & Icon
                        Row(
                          children: [
                            Icon(
                              Icons.theaters_rounded,
                              size: 18,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              studioEntry.key, // Nama Studio
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Grid Jam Tayang
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: studioEntry.value.map((schedule) {
                            return _buildTimeButton(schedule);
                          }).toList(),
                        ),

                        // Garis Pemisah Antar Studio (Kecuali yang terakhir)
                        if (!isLast)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Divider(color: Colors.grey[200]),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Widget Tombol Jam (Lebih Rapi & Modern)
  Widget _buildTimeButton(dynamic schedule) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeatSelectionScreen(showtime: schedule),
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 85, // Lebar fixed biar rapi sejajar
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formatTime(schedule.startTime),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "${currencyFormatter.format(schedule.price)}k", // Format 40k, 50k
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Badge Transparan di Header
  Widget _buildGlassBadge(
    IconData icon,
    String text, {
    Color color = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
