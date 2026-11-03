import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/layout/layout_externo.dart';
import 'package:ecommerce_app/core/layout/status_view.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/core/ui/seccion_titulo.dart';
import 'package:ecommerce_app/core/utils/formatear_fechas.dart';
import 'package:ecommerce_app/features/productos/domain/producto_estado.dart';
import 'package:ecommerce_app/features/productos/domain/producto.dart';
import 'package:ecommerce_app/features/productos/presentation/viewmodel/producto_view_model.dart';
import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

class _DetallesViewState extends State<_DetallesView>{
  late final productoId = widget.productoId;

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
      appBar: AppBarExterno(title: "Detalles del producto"),
      body: FutureBuilder<Producto?>(
        future: context.read<ProductoRepository>().unoPorId(productoId),
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

          debugPrint("[PRODUCTO] ${prod.createdAt}");

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: .all(16),
                    child: SeccionTitulo(title: "Datos generales"),
                  ),
                  SizedBox(
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16,)
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}