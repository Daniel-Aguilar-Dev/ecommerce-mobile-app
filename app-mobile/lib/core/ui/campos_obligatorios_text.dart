import 'package:flutter/material.dart';
import 'package:ecommerce_app/core/theme/colors.dart';

class CamposObligatoriosText extends StatelessWidget{
  const CamposObligatoriosText({super.key});

  @override
  Widget build(BuildContext context) {
    return  Text('* Campos obligatorios', style: Theme.of(context).textTheme.labelLarge!.copyWith(color: AppColors.error.main));
  }
}