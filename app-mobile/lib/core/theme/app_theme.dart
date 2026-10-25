import 'package:flutter/material.dart';
import 'colors.dart';

class ECommerceAppTheme {
  ECommerceAppTheme._();

  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: .fromSeed(seedColor: AppColors.primario.c400).copyWith(
        surface: Colors.white,
        primary: AppColors.primario.c400,
        onPrimary: Colors.white,
        secondary: AppColors.secundario.c200,
        tertiary: AppColors.terciario.c300,
        error: AppColors.error.main
      ),
      fontFamily: 'PlusJakartaSans',
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
          bodyColor: AppColors.texto.c900,
          displayColor: AppColors.texto.c900
      ),
    );
  }
}