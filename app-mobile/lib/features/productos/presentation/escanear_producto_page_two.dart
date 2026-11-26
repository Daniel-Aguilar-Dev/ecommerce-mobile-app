import 'package:ecommerce_app/core/layout/layout_externo.dart';
import 'package:ecommerce_app/core/layout/status_view.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/features/productos/domain/producto.dart';
import 'package:ecommerce_app/features/productos/presentation/viewmodel/producto_view_model.dart';
import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';
import 'package:ecommerce_app/features/productos/presentation/widgets/detalles_section.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class EscanearProductoPageTwo extends StatelessWidget{
  const EscanearProductoPageTwo({super.key, required this.sku});

  final String sku;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (ctx) => ProductoViewModel(
          productoRepository: ctx.read<ProductoRepository>(),
        ),
        child: _DetallesView(sku: sku)
    );
  }
}

class _DetallesView extends StatefulWidget{
  const _DetallesView({ required this.sku });
  final String sku;

  @override
  State<StatefulWidget> createState() => _DetallesViewState();
}

class _DetallesViewState extends State<_DetallesView>{
  late final sku = widget.sku;

  late final Future<Producto?> _productoFuture;

  @override
  void initState() {
    super.initState();
    _productoFuture =
        context.read<ProductoRepository>().unoPorSku(sku);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarExterno(title: "Código escaneado"),
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

          final prod = snapshot.data;
          if (prod == null) {
            return StatusView(icon: LucideIcons.cartonOff, title: "Producto no encontrado", subtitle: "No se encontró ningún producto con ese código de barras", buttonText:"Volver a escanear", onPressButton: () => Navigator.pop(context));
          }

          if (snapshot.hasError) {
            return StatusView.error(message: snapshot.error.toString());
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
                    child: Column(
                      spacing: 0,
                      mainAxisSize: .min,
                      children: [
                        SizedBox(width: double.infinity, child: OutlinedButton(
                          onPressed: () {
                            //TODO Implementar función de agregar a una venta
                            Navigator.pop(context);
                          },
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
                          child: const Text("Agregar a una venta"),
                        )),
                        SizedBox(width: double.infinity, child: FilledButton(
                            onPressed: () => Navigator.pop(context),
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
                            child: const Text("Volver a escanear")
                        )),
                      ]
                    ),
                  )
                )
              ]
            )
          );
        }
      ),
    );
  }
}