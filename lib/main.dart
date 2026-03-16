import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Katalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0077B6),
          primary: const Color(0xFF0077B6),
          secondary: const Color(0xFF00B4D8),
          tertiary: const Color(0xFF90E0EF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F9FF),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0077B6),
            elevation: 0,
          ),
      ),
      home: const HomeScreen(),
    );
  }
}