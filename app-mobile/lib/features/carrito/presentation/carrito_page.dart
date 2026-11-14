import 'package:ecommerce_app/core/layout/status_view.dart';
import 'package:ecommerce_app/core/ui/app_toast.dart';
import 'package:ecommerce_app/core/ui/cantidad_input.dart';
import 'package:ecommerce_app/features/carrito/domain/carrito.dart';
import 'package:ecommerce_app/features/carrito/presentation/viewmodel/carrito_view_model.dart';
import 'package:ecommerce_app/features/carrito/presentation/widgets/carrito_card.dart';
import 'package:ecommerce_app/features/productos/data/models/stock_linea_response_dto.dart';
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
  List<StockLineaResponseDto> carritoErrors = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<CarritoViewModel>();
    carrito = vm.obtenerCarrito();
    final total = carrito.items.fold(0.0, (sum, item) => sum + (item.producto.precio * item.cantidad));
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
                    for (final i in carrito.items) CarritoCard(
                      item: i,
                      onUpdate: (cantidad) {
                        final list = List<CarritoItem>.from(carrito.items);
                        final index = list.indexOf(i);
                        final carritoItem = CarritoItem(producto: i.producto, cantidad: cantidad);
                        list[index] = carritoItem;
                        final copy = Carrito(items: list, cantidad: carrito.cantidad);
                        vm.actualizarCarrito(copy);
                      },
                      deleteFunction: () => vm.removerDelCarrito(i.producto),
                      stockResponse: carritoErrors
                          .where((e) => e.nombre == i.producto.nombre)
                          .firstOrNull,
                    ),
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
                  onPressed: () async {
                    if(vm.isLoading) return;
                    final res = await vm.checarStockCarrito(carrito);
                    debugPrint("[CARRITO] devolvió: ${res.length}");
                    if(res.isNotEmpty){
                      setState(() {
                        carritoErrors = res;
                      });
                      if(vm.errorMessage != null) AppToast.show(context, variant: ToastType.error, title: vm.errorMessage ?? "Carrito no válido");
                    } else {
                      //TODO Función para generar el pedido posteriormente
                      AppToast.show(
                        context, variant: ToastType.success,
                        title: "¡Éxito!",
                        message: "Pedido generado"
                      );
                    }
                  },
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                    ),
                  ),
                  child: vm.isLoading
                      ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      :
                      const Text("Confirmar")
                )
              ],
            )
          ],
        ),
      )
    );
  }
}