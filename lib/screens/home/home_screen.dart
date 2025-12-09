import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/movie_service.dart';
import '../../models/movie_model.dart';
import '../../widgets/movie_card.dart';
import '../auth/login_screen.dart';
import '../booking/my_booking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MovieService _movieService = MovieService();
  final TextEditingController _searchController = TextEditingController();

  List<Movie> _allMovies = []; // Data Asli dari Server
  List<Movie> _filteredMovies = []; // Data yang ditampilkan (hasil search)

  bool _isLoading = true;
  String _userName = "User"; // Default name

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchMovies();
  }

  // Ambil nama user dari SharedPrefs (kalau ada)
  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Movie Lover";
    });
  }

  void _fetchMovies() async {
    try {
      final movies = await _movieService.getAllMovies();
      setState(() {
        _allMovies = movies;
        _filteredMovies = movies; // Awalnya tampilkan semua
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Logic Pencarian (Filter Lokal)
  void _filterMovies(String query) {
    setState(() {
      _filteredMovies = _allMovies
          .where(
            (movie) => movie.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Putih keabuan modern
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70, // AppBar agak tinggi biar lega
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, $_userName 👋",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            Text(
              "Mau nonton apa?",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          // Tombol Tiket (Style Baru)
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.1),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.confirmation_number_outlined,
                color: Colors.blueAccent,
              ),
              tooltip: 'Tiket Saya',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyBookingScreen(),
                  ),
                );
              },
            ),
          ),

          // Tombol Logout
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.1),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () async {
                await AuthService().logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar Area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: Colors.white, // Gabung sama AppBar warnanya
            child: TextField(
              controller: _searchController,
              onChanged: _filterMovies,
              decoration: InputDecoration(
                hintText: "Cari film favoritmu...",
                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // 2. Grid Film
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMovies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Film tidak ditemukan",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => _fetchMovies(),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredMovies.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7, // Proporsi kartu Poster
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemBuilder: (context, index) {
                        return MovieCard(movie: _filteredMovies[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
