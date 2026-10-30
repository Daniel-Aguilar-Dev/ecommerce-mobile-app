import 'package:flutter/material.dart';

import 'package:ecommerce_app/core/theme/colors.dart';

class ModalCancelButton extends StatelessWidget{
  const ModalCancelButton({ super.key, required this.onPressed });
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onPressed, style: _buttonStyle, child: const Text("Cancelar"),);
  }
}

final _buttonStyle = ButtonStyle(
  foregroundColor: WidgetStatePropertyAll(AppColors.primario.c400),
  textStyle: WidgetStatePropertyAll(
    TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  ),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
  ),
);