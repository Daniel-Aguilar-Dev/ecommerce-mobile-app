import 'package:flutter/material.dart';

class BottomSheetContainer extends StatelessWidget {
  const BottomSheetContainer({ super.key, required this.children, this.spacing = 0 });
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            )
        ),
        padding: .all(24),
        child: SafeArea(
          top: false,
          child: Column(
            spacing: spacing,
            mainAxisAlignment: .start,
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            children: [
              ...children,
            ],
          ),
        )
    );
  }
}