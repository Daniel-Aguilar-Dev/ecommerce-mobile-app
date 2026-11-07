import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/layout/layout_externo.dart';
import 'package:ecommerce_app/core/layout/status_view.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/core/ui/seccion_titulo.dart';
import 'package:ecommerce_app/core/utils/formatear_fechas.dart';
import 'package:ecommerce_app/core/ui/visor_imagen.dart';
import 'package:ecommerce_app/features/productos/domain/producto_estado.dart';
import 'package:ecommerce_app/features/productos/domain/producto.dart';
import 'package:ecommerce_app/features/productos/presentation/viewmodel/producto_view_model.dart';
import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';
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

  String _getEstado(int stockActual, int stockMinimo, ProductoEstado estado){
    if(estado.name == ProductoEstado.PROD_DESCONTINUADO.name) return "Descontinuado";
    if(stockActual == 0) return "Agotado";
    if(stockActual <= stockMinimo) return "Pocas unidades";
    return "Disponible";
  }

  Color _getTexto(int stockActual, int stockMinimo, ProductoEstado estado){
    if(estado.name == ProductoEstado.PROD_DESCONTINUADO.name) return AppColors.info.onSoft;
    if(stockActual == 0) return AppColors.error.onSoft;
    if(stockActual <= stockMinimo) return AppColors.warning.onSoft;
    return AppColors.success.onSoft;
  }

  Color _getBackground(int stockActual, int stockMinimo, ProductoEstado estado){
    if(estado.name == ProductoEstado.PROD_DESCONTINUADO.name) return AppColors.info.soft;
    if(stockActual == 0) return AppColors.error.soft;
    if(stockActual <= stockMinimo) return AppColors.warning.soft;
    return AppColors.success.soft;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBarExterno(title: "Código escaneado"),
      body: FutureBuilder<Producto?>(
        future: context.read<ProductoRepository>().unoPorSku(sku),
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

          void mostrarImagenCompleta(String tag) {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                barrierColor: Colors.black87,
                transitionDuration: const Duration(milliseconds: 250),
                reverseTransitionDuration: const Duration(milliseconds: 200),
                pageBuilder: (_, _, _) =>
                    VisorImagen(url: prod.imagenUrl, tag: tag),
                transitionsBuilder: (_, animation, _, child) =>
                    FadeTransition(opacity: animation, child: child),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: .all(16),
                    child: SeccionTitulo(title: "Datos generales"),
                  ),
                  GestureDetector(
                    onTap: () => mostrarImagenCompleta('foto-producto-detalle'),
                    child: Hero(
                      tag: 'foto-producto-detalle',
                      child: SizedBox(
                        height: 250,
                        child: AspectRatio(aspectRatio: 1, child: CachedNetworkImage(
                          imageUrl: prod.imagenUrl,
                          fit: BoxFit.fill,
                          placeholder: (_, __) => const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Image.asset(
                            'assets/images/prod_placeholder.png',
                            fit: BoxFit.fill,
                          ),
                        ),),
                      ),
                    ),
                  ),
                  Padding(
                    padding: .all(16),
                    child: Column(
                      spacing: 16,
                      mainAxisSize: .min,
                      mainAxisAlignment: .start,
                      crossAxisAlignment: .start,
                      children: [
                        Text("Marca: ${prod.marca}", style: theme.textTheme.bodyMedium),
                        Text(prod.nombre, style: theme.textTheme.titleLarge),
                        Text("\$ ${prod.precioVenta.toStringAsFixed(2)}", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700)),
                        if(prod.sku != null) Text("Código: ${prod.sku}", style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400)),
                        Row(
                          spacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getBackground(prod.stockActual, prod.stockMinimo, prod.estado),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _getEstado(prod.stockActual, prod.stockMinimo, prod.estado),
                                style: theme.textTheme.labelSmall!.copyWith(
                                  color: _getTexto(prod.stockActual, prod.stockMinimo, prod.estado),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text("Stock: ${prod.stockActual} piezas", style: theme.textTheme.labelSmall),
                          ],
                        ),
                        Text(prod.descripcion, style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        SeccionTitulo(title: "Datos de inventario"),
                        Text.rich(
                          TextSpan(
                            text: "Categoría: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: prod.categoria.nombre,
                                style: const TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            text: "Stock mínimo: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: prod.stockMinimo.toString(),
                                style: const TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            text: "Precio de compra: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: "\$ ${double.tryParse(prod.precioCompra.toString())?.toStringAsFixed(2)}",
                                style: const TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            text: "Distribuido en: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: prod.unidadMedia,
                                style: const TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            text: "Creado: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: fechaHora12(prod.createdAt!),
                                style: const TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            text: "Modificado: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: fechaHora12(prod.updatedAt!),
                                style: const TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
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
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}