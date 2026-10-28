import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/features/auth/presentation/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_600.dart';

class AppBarEmpleado extends StatefulWidget implements PreferredSizeWidget{
  const AppBarEmpleado({super.key, required this.title, this.avatarText});

  final String title;
  final String? avatarText;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<StatefulWidget> createState() => _AppBarEmpleadoState();
}

class _AppBarEmpleadoState extends State<AppBarEmpleado>{
  void _irAlPerfil(){
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const ProfilePage()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(widget.title, style: TextStyle().copyWith(fontWeight: FontWeight.bold)),
      centerTitle: false,
      actions: [
        Padding(
          padding: .only(right: 12),
          child: GestureDetector(
            onTap: _irAlPerfil,
            child: CircleAvatar(
                backgroundColor: AppColors.primario.c400,
                child: widget.avatarText != null ?
                  Text(widget.avatarText ?? "UE", style: TextStyle().copyWith(fontWeight: FontWeight.bold, color: Colors.white))
                    :
                  Icon(LucideIcons600.user, color: Colors.white,)
            ),
          ),
        )
      ],
    );
  }
}
