import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bioskop App',
      debugShowCheckedModeBanner: false,

      // --- TEMA TERANG (LIGHT THEME) ---
      theme: ThemeData(
        // Pakai warna dasar Biru
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,

        // Background Putih Bersih
        scaffoldBackgroundColor: Colors.white,

        // Font Poppins (Otomatis warna hitam di mode terang)
        textTheme: GoogleFonts.poppinsTextTheme(),

        // App Bar Putih
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // Teks & Ikon Hitam
          elevation: 0,
        ),
      ),

      home: const LoginScreen(),
    );
  }
}
