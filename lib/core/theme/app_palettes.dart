import 'package:flutter/material.dart';

class AppPalettes {
  static const Color gold = Color(0xFFD4AF37);
  static const Color navy = Color(0xFF0A192F);
  static const Color red = Color(0xFFCF6679);
  static const Color green = Color(0xFF00E5FF);
  static const Color offWhite = Color(0xFFF8F8F8);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFFDD835)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyGradient = LinearGradient(
    colors: [Color(0xFF0A192F), Color(0xFF112240)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Shader textGoldGradient = const LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFFFF176)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
}
