import 'package:flutter/material.dart';

class AetheraTheme {
  // Deep Cosmic Backgrounds
  static const Color spaceBg = Color(0xFF06060F);
  static const Color cardBg = Color(0xFF0F0E26);
  static const Color darkBlue = Color(0xFF09081B);
  
  // Neon Accents
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color neonMagenta = Color(0xFFD946EF);
  static const Color neonGreen = Color(0xFF10B981);
  static const Color neonRed = Color(0xFFEF4444);

  // Gradient definitions
  static const LinearGradient purpleCyanGrad = LinearGradient(
    colors: [neonPurple, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient magicGrad = LinearGradient(
    colors: [neonPurple, neonMagenta, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient spaceGrad = LinearGradient(
    colors: [Color(0xFF160E36), Color(0xFF06060F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Custom Glassmorphic Decoration
  static Decoration glassDecoration({
    double opacity = 0.08,
    double borderOpacity = 0.15,
    double radius = 24.0,
    Color glowColor = neonPurple,
    double glowOpacity = 0.0,
  }) {
    return BoxDecoration(
      color: Color(0xFF1A1738).withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: 1.0,
      ),
      boxShadow: glowOpacity > 0.0
          ? [
              BoxShadow(
                color: glowColor.withOpacity(glowOpacity),
                blurRadius: 16,
                spreadRadius: 1,
              )
            ]
          : null,
    );
  }

  // Neon text styling
  static TextStyle neonTextStyle({
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.normal,
    double glowRadius = 8.0,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: Colors.white,
      shadows: [
        Shadow(
          blurRadius: glowRadius,
          color: color,
        ),
      ],
    );
  }
}
