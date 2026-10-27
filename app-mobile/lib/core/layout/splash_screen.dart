import 'package:flutter/material.dart';

import '../theme/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.primario.c400),
      child: Padding(
        padding: .all(16),
        child: Column(
          mainAxisAlignment: .center,
          spacing: 24,
          children: [
            Image.asset(
              'assets/images/cart_logo.png',
              width:175,
              height: 175,
              fit: BoxFit.contain,
            ),
            CircularProgressIndicator(color: Colors.white)
          ],
        ),
      ),
    );
  }
}