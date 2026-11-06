import 'package:ecommerce_app/core/layout/status_view.dart';
import 'package:ecommerce_app/features/carrito/domain/carrito.dart';
import 'package:ecommerce_app/features/carrito/presentation/viewmodel/carrito_view_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class CarritoPage extends StatefulWidget{
  const CarritoPage({super.key});

  @override
  State<StatefulWidget> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage>{
  Carrito carrito = Carrito.vacio();

  @override
  Widget build(BuildContext context) {
    carrito = context.watch<CarritoViewModel>().obtenerCarrito();
    return Scaffold(
      body: Padding(
        padding: .all(16),
        child: carrito.estaVacio ? StatusView(
          title: "Tu carrito está vacío",
          subtitle: "Empieza a agregar tus productos favoritos.",
          icon: LucideIcons.shoppingCart,
        ) : Column(
          spacing: 16,
          children: [
            Flex(
              direction: Axis.vertical,
              children: [
                SingleChildScrollView(
                  child:  Column(
                    children: [
                      Text("Tiene productos ${carrito.items.length}")
                    ],
                  ),
                )
              ],
            ),
            Row()
          ],
        ),
      )
    );
  }
}