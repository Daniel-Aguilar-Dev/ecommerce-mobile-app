import 'package:ecommerce_app/features/categorias/presentation/categorias_page.dart';
import 'package:ecommerce_app/features/productos/presentation/productos_management_page.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:ecommerce_app/core/layout/layout_admin.dart';
import 'package:ecommerce_app/core/layout/layout_cliente.dart';
import 'package:ecommerce_app/core/layout/layout_empleado.dart';
import 'package:ecommerce_app/features/auth/presentation/auth_view_model.dart';

//Importar páginas aquí
import 'package:ecommerce_app/features/auth/presentation/profile_page.dart';
import 'package:ecommerce_app/features/carrito/presentation/main_menu.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>{
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    /*
    * Para probar los roles:
    * late final role = "EMPLEADO";
    * late final role = "ADMINISTRADOR";
    * late final role = "CLIENTE";
     */
    late final role = context.select<AuthViewModel, String?>((a) => a.session?.usuario.rol);

    final items = switch (role) {
      "EMPLEADO" => [for (final i in listEmpleado) NavigationDestination(icon: Icon(i.icon), label: i.label)],
      _ => [for (final i in listCliente) NavigationDestination(icon: Icon(i.icon), label: i.label)],
    };

    final pages = switch (role) {
      "EMPLEADO" => listEmpleado,
      "ADMINISTRADOR" => listAdmin,
      _ => listCliente,
    };

    final index = _index.clamp(0, items.length - 1);

    return Scaffold(
      appBar: switch (role) {
      "ADMINISTRADOR" => AppBarAdmin(title: listAdmin[index].title),
      "EMPLEADO" => AppBarEmpleado(title: listEmpleado[index].title),
      _ => AppBarCliente(title: listCliente[index].title),
      },
      drawer: role == "ADMINISTRADOR" ? AdminDrawer(items: listAdmin, index: index, onSelect: (i) => setState(() => _index = i)) : null,
      body: SafeArea(child:
        IndexedStack(
          index: index,
          children: [for (final i in pages) i.page],
        ),
      ),
      bottomNavigationBar: role != "ADMINISTRADOR" ?
        DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
          ),
          child: NavigationBar(
            backgroundColor: Colors.white,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: items,
            elevation: 0,
            indicatorColor: Colors.transparent,
          ),
        )
        :
        null,
    );
  }
}

class NavItem {
  const NavItem(this.label, this.icon, this.page, this.title);
  final String label;
  final IconData icon;
  final Widget page;
  final String title;
}

List<NavItem> listCliente = [
  NavItem('Inicio', LucideIcons.home, const MainMenu(), "¿Qué necesitas hoy?"),
  NavItem('Pedidos', LucideIcons.package, const Text("Pedidos"), "Tus pedidos"),
  NavItem('Carrito', LucideIcons.shoppingCart, const Text("Carrito"), "Tu carrito"),
  NavItem('Pagos', LucideIcons.banknote, const Text("Pagos"), "Pagos pendientes"),
  NavItem('Cuenta', LucideIcons.user, const ProfileScreen(), "Cuenta"),
];

List<NavItem> listEmpleado = [
  NavItem('Inicio', LucideIcons.home, const Text("Inicio"), "Inicio"),
  NavItem('Pedidos', LucideIcons.clipboardList, const Text("Inicio"), "Pedidos"),
  NavItem('Escanear', LucideIcons.scanBox, const Text("Inicio"), "Escanear producto"),
  NavItem('Inventario', LucideIcons.packageOpen, const ProductosManagementPage(), "Inventario"),
  NavItem('Ventas', LucideIcons.chartColumn, const Text("Inicio"), "Ventas"),
];

List<NavItem> listAdmin = [
  NavItem('Inicio', LucideIcons.layoutDashboard, const Text("Dashboard"), "Inicio"),
  NavItem('Usuarios', LucideIcons.userRoundGroup, const Text("Usuarios"), "Gestión de usuarios"),
  NavItem('Pedidos', LucideIcons.clipboardList, const Text("Pediods"), "Gestión de pedidos"),
  NavItem('Productos', LucideIcons.carton, ProductosManagementPage(), "Gestión de productos"),
  NavItem('Categorías', LucideIcons.tags, const CategoriasPage(), "Gestión de categorías"),
  NavItem('Ventas', LucideIcons.fileChartColumn, const Text("Ventas"), "Ventas"),
  NavItem('Entradas', LucideIcons.packagePlus, const Text("Entradas"), "Entradas"),
  NavItem('Salidas', LucideIcons.packageMinus, const Text("Salidas"), "Salidas"),
  NavItem('Pagos pendientes', LucideIcons.wallet, const Text("Pagos"), "Pagos pendientes"),
];