import 'package:flutter/material.dart';

import '../theme/colors.dart';

InputDecoration customInputDecoration({
  String? hint,
  IconData? icon,
  Widget? suffix,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AppColors.texto.c400, fontSize: 13),
    prefixIcon:
    icon != null ? Icon(icon, size: 19, color: AppColors.texto.c900) : null,
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
    border: border(AppColors.border),
    enabledBorder: border(AppColors.border),
    focusedBorder: border(AppColors.texto.c900, 1.4),
    errorBorder: border(AppColors.error.main),
    focusedErrorBorder: border(AppColors.error.main, 1.4),
  );
}