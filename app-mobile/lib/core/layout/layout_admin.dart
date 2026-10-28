import 'package:ecommerce_app/features/auth/presentation/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_600.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'app_shell.dart';

class AppBarAdmin extends StatefulWidget implements PreferredSizeWidget {
  const AppBarAdmin({super.key, required this.title, this.avatarText});

  final String title;
  final String? avatarText;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<StatefulWidget> createState() => _AppBarAdminState();
}

class _AppBarAdminState extends State<AppBarAdmin>{
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
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(LucideIcons600.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: Text(widget.title, style: TextStyle().copyWith(fontWeight: FontWeight.bold)),
      centerTitle: true,
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

class AdminDrawer extends StatefulWidget{
  const AdminDrawer({ super.key, required this.items, required this.index, required this.onSelect });

  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  State<StatefulWidget> createState() => _AdminDrawerState();

}

class _AdminDrawerState extends State<AdminDrawer>{
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: .zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primario.c400,
              border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/cart_logo.png',
                  width:90,
                  height: 90,
                  fit: BoxFit.contain,
                ),
                Text(
                  'Administración',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ),
          for (var i = 0; i < widget.items.length; i++)
            ListTile(
              leading: Icon(widget.items[i].icon),
              title: Text(widget.items[i].label, style: TextStyle().copyWith(fontWeight: i != widget.index ? FontWeight.w400 : FontWeight.w600)),
              selected: i == widget.index,
              onTap: () {
                Navigator.pop(context); // cierra el drawer
                widget.onSelect(i);
              },
            ),
        ],
      ),
    );
  }
}