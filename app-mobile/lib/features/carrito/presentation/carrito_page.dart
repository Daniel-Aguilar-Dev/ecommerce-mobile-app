import 'package:ecommerce_app/core/layout/status_view.dart';
import 'package:ecommerce_app/core/ui/cantidad_input.dart';
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
    final theme = Theme.of(context);
    carrito = context.watch<CarritoViewModel>().obtenerCarrito();
    final total = carrito.items.fold(0.0, (sum, item) => sum + item.producto.precio);
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
            Expanded(
              child: SingleChildScrollView(
                child:  Column(
                  children: [
                    Text("Tiene productos ${carrito.items.length}"),
                    CantidadInput(max: 10, min: 0, onChange: (val) => debugPrint("[DEBUG] Es: $val"))
                  ],
                ),
              )
            ),
            Row(
              crossAxisAlignment: .center,
              mainAxisAlignment: .spaceBetween,
              children: [
                Column(
                  mainAxisSize: .min,
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .start,
                  children: [
                    Text("Total", style: theme.textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w500)),
                    Text("\$ ${total.toStringAsFixed(2)} MXN", style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold))
                  ],
                ),
                FilledButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                    ),
                  ),
                  child: const Text("Confirmar")
                )
              ],
            )
          ],
        ),
      )
    );
  }
}