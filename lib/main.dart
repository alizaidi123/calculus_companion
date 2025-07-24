// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculus Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
          accentColor: const Color(0xFFF78888),
        ).copyWith(
          primary: const Color(0xFF4A6572), // Deep Teal/Blue-Grey
          onPrimary: Colors.white,
          secondary: const Color(0xFFF78888), // Soft Coral
          onSecondary: Colors.white,
          surface: Colors.white, // Card/input background
          onSurface: Colors.grey.shade800,
          background: const Color(
              0xFFF8F8F8), // Very light grey background (will be overridden by gradient)
          onBackground: Colors.grey.shade800,
          error: Colors.red.shade700,
          onError: Colors.white,
        ),
        // Scaffold background will be a gradient in HomeScreen
        scaffoldBackgroundColor: Colors
            .transparent, // Set to transparent here to allow gradient from body
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: Colors.grey.shade800,
          displayColor: Colors.grey.shade800,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.8, // Slightly more spacious title
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF4A6572),
            shadowColor: Colors.grey.shade400
                .withOpacity(0.6), // Stronger, slightly colored shadow
            elevation: 8, // Increased elevation
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFF78888), width: 2),
          ),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        cardTheme: CardThemeData(
          elevation: 10, // Even higher elevation for cards
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.white,
          shadowColor: Colors.grey.withOpacity(0.3),
          margin: const EdgeInsets.symmetric(
              vertical: 10.0), // More vertical margin
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
