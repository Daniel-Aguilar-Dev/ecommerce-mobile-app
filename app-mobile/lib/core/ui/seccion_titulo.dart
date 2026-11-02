import 'package:flutter/material.dart';

class SeccionTitulo extends StatelessWidget {
  const SeccionTitulo({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final color = Color(0xFF767778);
    return Row(
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: color,
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: .start,
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(title, style: TextStyle(color: color)),
                const SizedBox(height: 4)
              ],
            ),
          ),
        )
      ],
    );
  }
}