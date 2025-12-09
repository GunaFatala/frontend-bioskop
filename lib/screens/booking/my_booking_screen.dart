import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  final BookingService _bookingService = BookingService();
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() async {
    try {
      final data = await _bookingService.getMyBookings();
      setState(() {
        _bookings = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String formatDate(String dateString) {
    try {
      DateTime dt = DateTime.parse(dateString);
      return DateFormat('EEE, d MMM yyyy', 'id_ID').format(dt);
    } catch (e) {
      return dateString;
    }
  }

  String formatTime(String dateString) {
    try {
      DateTime dt = DateTime.parse(dateString);
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Abu modern
      appBar: AppBar(
        title: Text(
          "Tiket Saya",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- PERBAIKAN DI SINI ---
                  // Ganti icon yang error dengan icon yang valid
                  const Icon(
                    Icons.confirmation_number_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada tiket aktif",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                return _buildTicketCard(_bookings[index]);
              },
            ),
    );
  }

  Widget _buildTicketCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
        children: [
          // BAGIAN ATAS: Info Film
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster Kecil
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    booking.posterUrl,
                    width: 70,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      width: 70,
                      height: 100,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Judul & Tanggal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.movieTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formatDate(booking.startTime),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formatTime(booking.startTime),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
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

          // GARIS PUTUS-PUTUS (Dashed Line)
          _buildDashedDivider(),

          // BAGIAN BAWAH: Detail Kursi & QR
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Info Studio & Kursi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Studio",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      booking.studioName,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Kursi",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      booking.seats.join(", "),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),

                // Kode Booking & QR Dummy
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "LUNAS",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Dummy QR Icon
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 40,
                      color: Colors.black87,
                    ),
                    Text(
                      booking.bookingCode,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Garis Putus-Putus Manual
  Widget _buildDashedDivider() {
    return Row(
      children: [
        // Lekukan Kiri
        const SizedBox(
          width: 20,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFF5F7FA), // Warna background Scaffold
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
        ),
        // Garis Tengah
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  (constraints.constrainWidth() / 10).floor(),
                  (index) => const SizedBox(
                    width: 5,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Lekukan Kanan
        const SizedBox(
          width: 20,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFF5F7FA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
