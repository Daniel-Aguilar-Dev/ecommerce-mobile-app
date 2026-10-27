import 'package:ecommerce_app/features/clientes/presentation/detalles_producto.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>{

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Text("Lista de productos"),
        FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetallesProducto()
              ),
            ),
            child: Text("Ver producto")
        ),
      ],
    );
  }
}