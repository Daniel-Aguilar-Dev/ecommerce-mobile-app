import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'notificaciones_page.dart';

class AppBarCliente extends StatefulWidget implements PreferredSizeWidget {
  const AppBarCliente({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<StatefulWidget> createState() => _AppBarClienteState();
}

class _AppBarClienteState extends State<AppBarCliente>{
  void _abrirNotificaciones(){
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const NotificacionesPage()
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(widget.title, style: TextStyle().copyWith(fontWeight: FontWeight.bold),),
      centerTitle: false,
      actions: [
        Padding(
        padding: .only(right: 8),
        child: IconButton(
            onPressed: _abrirNotificaciones,
            icon: const Icon(LucideIcons.bell),
            padding: .all(4),
            style: IconButton.styleFrom(
              side: BorderSide(color: AppColors.border, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        )
      ],
    );
  }
}