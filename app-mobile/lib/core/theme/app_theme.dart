import 'package:flutter/material.dart';
import 'colors.dart';

class ECommerceAppTheme {
  ECommerceAppTheme._();

  static ThemeData build() {
    const foreground = Color(0xFF2F3A4F);
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
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.primario.c400 : AppColors.texto.c900,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.primario.c400 : AppColors.texto.c900,
          );
        }),
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
          bodyColor: AppColors.texto.c900,
          displayColor: AppColors.texto.c900
      ),
    );
  }
}