import 'package:flutter/material.dart';

class PressableItem extends StatelessWidget {
  const PressableItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onPress,
    this.contentPadding,
  });

  final IconData icon;
  final String text;
  final VoidCallback onPress;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: contentPadding,
      leading: Icon(icon),
      title: Text(text),
      onTap: onPress,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}