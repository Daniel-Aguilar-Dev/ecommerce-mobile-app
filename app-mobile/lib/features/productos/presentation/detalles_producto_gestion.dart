import 'package:ecommerce_app/core/layout/layout_externo.dart';
import 'package:ecommerce_app/core/layout/status_view.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/features/inventario/presentation/widgets/entrada_individual_modal.dart';
import 'package:ecommerce_app/features/inventario/presentation/widgets/perdida_individual_modal.dart';
import 'package:ecommerce_app/features/productos/domain/producto.dart';
import 'package:ecommerce_app/features/productos/presentation/viewmodel/producto_view_model.dart';
import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';
import 'package:ecommerce_app/features/productos/presentation/widgets/detalles_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DetallesProductoGestion extends StatelessWidget {
  const DetallesProductoGestion({ super.key, required this.productoId });
  final int productoId;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProductoViewModel(
        productoRepository: ctx.read<ProductoRepository>(),
      ),
      child: _DetallesView(productoId: productoId)
    );
  }
}

class _DetallesView extends StatefulWidget{
  const _DetallesView({ required this.productoId });
  final int productoId;

  @override
  State<StatefulWidget> createState() => _DetallesViewState();
}

class _DetallesViewState extends State<_DetallesView> {
  late final productoId = widget.productoId;

  late final Future<Producto?> _productoFuture;

  @override
  void initState() {
    super.initState();
    _productoFuture =
        context.read<ProductoRepository>().unoPorId(productoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarExterno(title: "Detalles del producto"),
      body: FutureBuilder<Producto?>(
        future: _productoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: AppColors.primario.c400,
                semanticsLabel: "Cargando...",
              ),
            );
          }

          if (snapshot.hasError) {
            return StatusView.error(message: snapshot.error.toString());
          }

          final prod = snapshot.data;
          if (prod == null) {
            // HU-2.3: si no se encuentra, pantalla de registro no encontrado
            return StatusView.error(message: "Producto no encontrado");
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: DetallesSection(prod: prod),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                  ),
                  child: Padding(
                    padding: .all(16),
                    child: Row(
                      mainAxisSize: .min,
                      spacing: 8,
                      children: [
                        Expanded(child:
                        OutlinedButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => PerdidaIndividualModal(producto: prod)
                          ),
                          style: ButtonStyle(
                            foregroundColor: WidgetStatePropertyAll(AppColors.primario.c400),
                            backgroundColor: const WidgetStatePropertyAll(Colors.white),
                            textStyle: const WidgetStatePropertyAll(
                              TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            side: WidgetStatePropertyAll(
                              BorderSide(color: AppColors.primario.c400, width: 2),
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          child: Row(mainAxisAlignment: .center, spacing: 4, children: [const Icon(LucideIcons.packageMinus), const Text("Merma")]),
                        )
                        ),
                        Expanded(child:
                        FilledButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => EntradaIndividualModal(producto: prod)
                          ),
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(AppColors.primario.c400),
                            foregroundColor: WidgetStatePropertyAll(Colors.white),
                            textStyle: WidgetStatePropertyAll(
                              TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                            ),
                          ),
                          child: Row(mainAxisAlignment: .center, spacing: 4, children: [const Icon(LucideIcons.packagePlus), const Text("Entrada")]),
                        )
                        )
                      ]
                    ),
                  )
                )
              ]
            ),
          );
        }
      ),
    );
  }
}