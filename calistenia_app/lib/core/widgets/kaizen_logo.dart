import 'package:flutter/material.dart';
import 'package:calistenia_app/core/constants/app_colors.dart';

// Logo de la app — kanji 改善 (kaizen: cambio para mejor) + nombre
// Reutilizable en login, register y home
class KaizenLogo extends StatelessWidget {
  // Tamaño del kanji — permite usar una versión más chica en el AppBar
  final double tamanioKanji;
  final bool mostrarSubtitulo;

  const KaizenLogo({
    super.key,
    this.tamanioKanji = 64,
    this.mostrarSubtitulo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Los kanji 改 (kai - cambio) y 善 (zen - mejora)
        Text(
          '改善',
          style: TextStyle(
            fontSize: tamanioKanji,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            height: 1,
          ),
        ),
        SizedBox(height: tamanioKanji * 0.15),
        Text(
          'KAIZEN',
          style: TextStyle(
            fontSize: tamanioKanji * 0.34,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: tamanioKanji * 0.09,
          ),
        ),
        if (mostrarSubtitulo) ...[
          const SizedBox(height: 2),
          Text(
            'CALISTENIA',
            style: TextStyle(
              fontSize: tamanioKanji * 0.17,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: tamanioKanji * 0.05,
            ),
          ),
        ],
      ],
    );
  }
}