import 'package:flutter/material.dart';

class ColorScale {
  final Color c50, c100, c200, c300, c400, c500, c600, c700, c800, c900, c950;
  const ColorScale({
    required this.c50, required this.c100, required this.c200,
    required this.c300, required this.c400, required this.c500,
    required this.c600, required this.c700, required this.c800,
    required this.c900, required this.c950,
  });
}

/// Color semántico: principal, fondo suave y texto sobre el fondo
class SemanticColor {
  final Color main, soft, onSoft;
  const SemanticColor({required this.main, required this.soft, required this.onSoft});
}

class AppColors {
  AppColors._();

  static const primario = ColorScale(
    c50: Color(0xFFFFF6ED),
    c100: Color(0xFFFFEAD4),
    c200: Color(0xFFFFD2A8),
    c300: Color(0xFFFFB271),
    c400: Color(0xFFFF8A3D),  //Principal
    c500: Color(0xFFFE6511),
    c600: Color(0xFFEF4A07),
    c700: Color(0xFFC63508),
    c800: Color(0xFF9D2B0F),
    c900: Color(0xFF7E2610),
    c950: Color(0xFF441006),
  );

  static const secundario = ColorScale(
    c50: Color(0xFFFFF8EB),
    c100: Color(0xFFFFECC6),
    c200: Color(0xFFFFCF70),  //Principal
    c300: Color(0xFFFFBC4A),
    c400: Color(0xFFFFA320),
    c500: Color(0xFFF97E07),
    c600: Color(0xFFDD5A02),
    c700: Color(0xFFB73B06),
    c800: Color(0xFF942D0C),
    c900: Color(0xFF7A260D),
    c950: Color(0xFF461002),
  );

  static const terciario = ColorScale(
    c50: Color(0xFFFFF4ED),
    c100: Color(0xFFFFE6D4),
    c200: Color(0xFFFFCAA9),
    c300: Color(0xFFFFA97A),  //Principal
    c400: Color(0xFFFE7339),
    c500: Color(0xFFFC4E13),
    c600: Color(0xFFED3309),
    c700: Color(0xFFC52209),
    c800: Color(0xFF9C1D10),
    c900: Color(0xFF7E1B10),
    c950: Color(0xFF440A06),
  );

  static const texto = ColorScale(
    c50: Color(0xFFF5F7FA),
    c100: Color(0xFFEAEDF4),
    c200: Color(0xFFD1D9E6),
    c300: Color(0xFFA8B8D1),
    c400: Color(0xFF7A92B6),
    c500: Color(0xFF59759E),
    c600: Color(0xFF455C84),
    c700: Color(0xFF394B6B),
    c800: Color(0xFF32405A),
    c900: Color(0xFF2F3A4F),  //Principal
    c950: Color(0xFF1E2533),
  );

  static const superficie = ColorScale(
    c50: Color(0xFFFFFAF0),  //Principal
    c100: Color(0xFFFFF2D5),
    c200: Color(0xFFFEE0AA),
    c300: Color(0xFFFDC974),
    c400: Color(0xFFFBA73C),
    c500: Color(0xFFF98C16),
    c600: Color(0xFFEA710C),
    c700: Color(0xFFC2550C),
    c800: Color(0xFF9A4312),
    c900: Color(0xFF7C3912),
    c950: Color(0xFF431B07),
  );


  static const success = SemanticColor(
    main: Color(0xFF16A34A), soft: Color(0xFFDCFCE7), onSoft: Color(0xFF14532D),
  );
  static const error = SemanticColor(
    main: Color(0xFFDC2626), soft: Color(0xFFFEE2E2), onSoft: Color(0xFF7F1D1D),
  );
  static const warning = SemanticColor(
    main: Color(0xFFB45309), soft: Color(0xFFFEF3C7), onSoft: Color(0xFF78350F),
  );
  static const info = SemanticColor(
    main: Color(0xFF2563EB), soft: Color(0xFFDBEAFE), onSoft: Color(0xFF1E3A8A),
  );
}