import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_600.dart';

class AppBarExterno extends StatelessWidget implements PreferredSizeWidget{
  const AppBarExterno({super.key, required this.title, this.onReturn});

  final String title;

  final VoidCallback? onReturn;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    void volver(){
      onReturn?.call();
      Navigator.pop(context);
    }

    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(onPressed: volver, icon: const Icon(LucideIcons600.arrowLeft)),
      title: Text(title, style: TextStyle().copyWith(fontWeight: FontWeight.bold)),
      centerTitle: false,
    );
  }
}
