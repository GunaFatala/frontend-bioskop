import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/movie_model.dart';
import '../../services/booking_service.dart';
import '../home/home_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Showtime showtime;

  const SeatSelectionScreen({super.key, required this.showtime});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final BookingService _bookingService = BookingService();

  List<String> _bookedSeats = [];
  final List<String> _selectedSeats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookedSeats();
  }

  void _fetchBookedSeats() async {
    try {
      final seats = await _bookingService.getBookedSeats(widget.showtime.id);
      setState(() {
        _bookedSeats = seats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _buyTickets() async {
    if (_selectedSeats.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      bool success = await _bookingService.createBooking(
        widget.showtime.id,
        _selectedSeats,
      );

      if (success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  "Booking Berhasil!",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tiket telah disimpan di menu Tiket Saya.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text(
                      "OK, MANTAP",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getSeatNumber(int row, int col) {
    String rowCode = String.fromCharCode(65 + row);
    String colCode = (col + 1).toString();
    return "$rowCode$colCode";
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final totalPrice = _selectedSeats.length * widget.showtime.price;

    return Scaffold(
      backgroundColor: const Color(0xFF151720), // Background gelap bioskop
      appBar: AppBar(
        title: Text(
          widget.showtime.studioName,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF151720),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. LAYAR BIOSKOP (GLOWING EFFECT)
          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 40),
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.4),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: CustomPaint(
              painter:
                  ScreenPainter(), // Custom Painter biar bentuknya melengkung dikit
              child: Center(
                child: Text(
                  "SCREEN",
                  style: GoogleFonts.poppins(
                    color: Colors.white24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),
          ),

          // 2. GRID KURSI
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : InteractiveViewer(
                    // Biar bisa di-zoom in/out kalau kursi banyak
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children:
                                _buildSeatRows(), // Logika baris & jarak ada di sini
                          ),
                        ),
                      ),
                    ),
                  ),
          ),

          // 3. LEGEND
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFF3C4048), "Tersedia"),
                const SizedBox(width: 20),
                _buildLegendItem(Colors.blueAccent, "Dipilih"),
                const SizedBox(width: 20),
                _buildLegendItem(const Color(0xFFE31A1A), "Terjual"),
              ],
            ),
          ),

          // 4. BOTTOM BAR
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Harga",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                    Text(
                      currencyFormatter.format(totalPrice),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _selectedSeats.isEmpty ? null : _buyTickets,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "BELI TIKET",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIKA PEMBUATAN BARIS DENGAN JARAK (TANGGA) ---
  List<Widget> _buildSeatRows() {
    List<Widget> rows = [];
    int totalRows = widget.showtime.rows;
    int totalCols = widget.showtime.cols;

    for (int rowIndex = 0; rowIndex < totalRows; rowIndex++) {
      // LOGIKA JARAK: Setiap 2 baris, kasih jarak agak jauh (simulasi tangga)
      // Kecuali di baris pertama
      if (rowIndex > 0 && rowIndex % 2 == 0) {
        rows.add(const SizedBox(height: 20)); // Jarak "Tangga"
      } else {
        rows.add(const SizedBox(height: 8)); // Jarak normal antar kursi
      }

      // Buat Baris Kursi
      List<Widget> cols = [];
      for (int colIndex = 0; colIndex < totalCols; colIndex++) {
        // LOGIKA AISLE (LORONG TENGAH):
        // Jika kolom ada di tengah-tengah, kasih jarak lorong
        if (colIndex > 0 && colIndex == (totalCols / 2).floor()) {
          cols.add(const SizedBox(width: 20)); // Lorong tengah
        }

        String seatId = _getSeatNumber(rowIndex, colIndex);
        bool isBooked = _bookedSeats.contains(seatId);
        bool isSelected = _selectedSeats.contains(seatId);

        cols.add(
          GestureDetector(
            onTap: isBooked
                ? null
                : () {
                    setState(() {
                      if (isSelected) {
                        _selectedSeats.remove(seatId);
                      } else {
                        _selectedSeats.add(seatId);
                      }
                    });
                  },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                // Warna Kursi
                color: isBooked
                    ? const Color(0xFFE31A1A) // Merah Gelap (Terjual)
                    : isSelected
                    ? Colors
                          .blueAccent // Biru (Dipilih)
                    : const Color(0xFF3C4048), // Abu Gelap (Tersedia)
                // Bentuk Kursi (Atas rounded, bawah tajam)
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                  bottom: Radius.circular(4),
                ),

                // Efek Shadow dikit biar timbul
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                seatId,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isBooked ? Colors.white30 : Colors.white,
                ),
              ),
            ),
          ),
        );
      }
      rows.add(
        Row(mainAxisAlignment: MainAxisAlignment.center, children: cols),
      );
    }
    return rows;
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

// Custom Painter untuk bikin garis layar melengkung (Efek Proyektor)
class ScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..shader = LinearGradient(
        colors: [Colors.blueAccent, Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    // Gambar kurva melengkung ke atas
    path.moveTo(0, 10);
    path.quadraticBezierTo(size.width / 2, -10, size.width, 10);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
