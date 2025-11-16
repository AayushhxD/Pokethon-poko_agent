import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6); // Violet
  static const Color accentColor = Color(0xFFEC4899); // Pink
  static const Color backgroundColor = Color(0xFF000029); // Deep navy blue
  static const Color surfaceColor = Color(0xFF0A0A3A); // Slightly lighter navy
  static const Color cardColor = Color(0xFF151545); // Card background

  // Type Colors
  static const Color fireColor = Color(0xFFFF6B6B);
  static const Color waterColor = Color(0xFF4ECDC4);
  static const Color electricColor = Color(0xFFFFC233);
  static const Color psychicColor = Color(0xFFB794F6);
  static const Color grassColor = Color(0xFF51CF66);
  static const Color iceColor = Color(0xFF74C0FC);

  // Pokémon-inspired Colors
  static const Color pokedexRed = Color(0xFFE63946);
  static const Color pokedexBlue = Color(0xFF457B9D);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color silverColor = Color(0xFFC0C0C0);
  static const Color bronzeColor = Color(0xFFCD7F32);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF000029), Color(0xFF0A0A3A), Color(0xFF151545)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient pokeballGradient = LinearGradient(
    colors: [pokedexRed, Color(0xFFFFFFFF), pokedexBlue],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient getTypeGradient(String type) {
    final color = getTypeColor(type);
    return LinearGradient(
      colors: [color, color.withOpacity(0.6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getShimmerGradient() {
    return const LinearGradient(
      colors: [Color(0x00FFFFFF), Color(0x40FFFFFF), Color(0x00FFFFFF)],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment(-1.0, 0.0),
      end: Alignment(1.0, 0.0),
    );
  }

  // Get Type Color
  static Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return fireColor;
      case 'water':
        return waterColor;
      case 'electric':
        return electricColor;
      case 'psychic':
        return psychicColor;
      case 'grass':
        return grassColor;
      case 'ice':
        return iceColor;
      default:
        return primaryColor;
    }
  }

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Custom Decorations
  static BoxDecoration glowingCardDecoration(Color color) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.5), width: 2),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static BoxDecoration gradientCardDecoration() {
    return BoxDecoration(
      gradient: primaryGradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }

  // Pokédex-style card decoration
  static BoxDecoration pokedexCardDecoration(String type) {
    final color = getTypeColor(type);
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [color.withOpacity(0.2), cardColor, cardColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color, width: 3),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // Premium holographic effect decoration
  static BoxDecoration holographicCardDecoration(String type) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [getTypeColor(type), goldColor, getTypeColor(type)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: goldColor.withOpacity(0.5),
          blurRadius: 25,
          spreadRadius: 3,
        ),
      ],
    );
  }

  // Badge decoration
  static BoxDecoration badgeDecoration(Color color, {bool unlocked = true}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient:
          unlocked
              ? RadialGradient(colors: [color, color.withOpacity(0.6)])
              : RadialGradient(
                colors: [Colors.grey.shade800, Colors.grey.shade900],
              ),
      border: Border.all(color: unlocked ? color : Colors.grey, width: 3),
      boxShadow:
          unlocked
              ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
              : [],
    );
  }
}
