import 'package:flutter/material.dart';

import 'package:ecommerce_app/core/theme/colors.dart';

class ModalConfirmButton extends StatelessWidget{
  const ModalConfirmButton({ super.key, required this.onPressed, required this.isLoading });
  final VoidCallback onPressed;
  final bool isLoading;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: _buttonStyle,
      onPressed: onPressed,
      child: isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        :
        const Text("Confirmar")
    );
  }
}

final _buttonStyle = ButtonStyle(
  backgroundColor: WidgetStatePropertyAll(AppColors.primario.c400),
  foregroundColor: WidgetStatePropertyAll(Colors.white),
  textStyle: WidgetStatePropertyAll(
    TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  ),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
  ),
);