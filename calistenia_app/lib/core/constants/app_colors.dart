import 'package:flutter/material.dart';

// Paleta de colores de Kaizen Calistenia
class AppColors {
  // Color primario — amarillo energético
  static const Color primary = Color(0xFFFFD600);

  // Variantes del amarillo
  static const Color primaryDark = Color(0xFFC7A500);
  static const Color primaryLight = Color(0xFFFFE680);

  // Fondos
  static const Color background = Color(0xFF0A0A0A);    // negro profundo
  static const Color surface = Color(0xFF1A1A1A);       // negro suave para cards
  static const Color surfaceLight = Color(0xFF2A2A2A);  // negro medio para inputs

  // Textos
  static const Color textPrimary = Color(0xFFFFFFFF);   // blanco puro
  static const Color textSecondary = Color(0xFFB0B0B0); // gris claro
  static const Color textDark = Color(0xFF0A0A0A);      // negro para texto sobre amarillo

  // Estados
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFD600);

  // Bordes
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderFocus = Color(0xFFFFD600); // amarillo al enfocar input
}