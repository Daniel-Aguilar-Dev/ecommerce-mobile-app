import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/core/utils/formatear_fechas.dart';
import 'package:ecommerce_app/core/ui/visor_imagen.dart';
import 'package:ecommerce_app/features/auth/domain/role_enum.dart';
import 'package:ecommerce_app/features/auth/presentation/auth_view_model.dart';
import 'package:ecommerce_app/features/productos/domain/producto_estado.dart';
import 'package:ecommerce_app/features/productos/domain/producto.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class DetallesSection extends StatelessWidget {
  const DetallesSection({super.key, required this.prod});

  final Producto prod;

  void mostrarImagenCompleta(String tag, BuildContext context) {
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
  
  String _getEstadoText(ProductoEstado estado){
    return switch(estado){
      ProductoEstado.PROD_ACTIVO => "Activo",
      ProductoEstado.PROD_DESCONTINUADO => "Descontinuado",
      ProductoEstado.PROD_ELIMINADO => "Eliminado",
    };
  }

  TableRow _fila(String tag, String valor){
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(tag,  style: const TextStyle(fontWeight: FontWeight.w400)),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final rol = context.read<AuthViewModel>().session?.usuario.rol;
    final esAdmin = rol == RoleEnum.ADMINISTRADOR.name;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          GestureDetector(
            onTap: () => mostrarImagenCompleta('foto-producto-detalle-${prod.id}', context),
            child: Hero(
              tag: 'foto-producto-detalle-${prod.id}',
              child: AspectRatio(
                aspectRatio: 1, // cuadrada; usa 4/3 si la quieres menos alta
                child: CachedNetworkImage(
                  imageUrl: prod.imagenUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Image.asset(
                    'assets/images/prod_placeholder.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: .all(16),
            child: Column(
              spacing: 4,
              mainAxisSize: .min,
              mainAxisAlignment: .start,
              crossAxisAlignment: .start,
              children: [
                if (prod.estado != ProductoEstado.PROD_DESCONTINUADO &&
                    prod.stockActual <= prod.stockMinimo) ...[
                  _AlertaStockBajo(
                    stockActual: prod.stockActual,
                    stockMinimo: prod.stockMinimo,
                  ),
                  const SizedBox(height: 8),
                ],
                Text(prod.marca, style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w300, color: AppColors.primario.c900)),
                Text(prod.nombre, style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: 24)),
                Text("\$ ${prod.precioVenta.toStringAsFixed(2)}", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600)),
                if(prod.sku != null) Text("SKU: ${prod.sku}", style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w200)),
                Text(prod.descripcion, style: Theme.of(context).textTheme.bodyLarge,),
                const SizedBox(height: 16),
                Card(
                  margin: .zero,
                  elevation: 0,
                  clipBehavior: .antiAlias,
                  color: const Color(0xFFE5E4E4), //AppColors.border,
                  child:Column(
                    crossAxisAlignment: .start,
                    children: [
                      Padding(
                        padding: .only(left: 12, top: 12, bottom: 4),
                        child: Row(
                          spacing: 4,
                          children: [
                            Icon(LucideIcons.clipboardList, color: AppColors.texto.c900),
                            Text("Información adicional", style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600))
                          ],
                        )
                      ),
                      Padding(padding: .symmetric(horizontal: 12), child: SizedBox(width: .infinity, child: DecoratedBox(decoration: BoxDecoration(border:  Border(bottom: BorderSide(color: AppColors.texto.c700, width: .5)))),),),
                      const SizedBox(height: 4),
                      Table(
                        columnWidths: {0: FractionColumnWidth(.4), 1: FractionColumnWidth(.6)},
                        children: [
                          _fila("Categoría", prod.categoria.nombre),
                          _fila("Distribuido en", prod.unidadMedia),
                          _fila("Stock físico", "${prod.stockActual} piezas"),
                          _fila("Disponible", "${ math.max(0, prod.stockActual - prod.stockReservado) } piezas"),
                          _fila("Reservado", "${prod.stockReservado} piezas"),
                          _fila("Stock mínimo", "${prod.stockMinimo} piezas"),
                          if (esAdmin) ...[
                            _fila("Precio de compra", "\$ ${prod.precioCompra.toStringAsFixed(2)}"),
                            _fila("Costo promedio", "\$ ${prod.costoPromedio.toStringAsFixed(2)}"),
                            _fila("Ganancia por unidad", "\$ ${(prod.precioVenta - prod.costoPromedio).toStringAsFixed(2)}"),
                          ],
                          _fila("Estado", _getEstadoText(prod.estado)),
                          _fila("Creado", fechaHora12(prod.createdAt!)),
                          _fila("Modificado", fechaHora12(prod.updatedAt!)),
                        ],
                      )
                    ],
                  )
                ),
              ],
            ),
          ),
          const SizedBox(height: 16,)
        ],
      ),
    );
  }
}

class _AlertaStockBajo extends StatelessWidget {
  const _AlertaStockBajo({required this.stockActual, required this.stockMinimo});

  final int stockActual;
  final int stockMinimo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sinStock = stockActual == 0;
    final fondo = sinStock ? AppColors.error.soft : AppColors.warning.soft;
    final color = sinStock ? AppColors.error.onSoft : AppColors.warning.onSoft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Icon(LucideIcons.triangleAlert, size: 20, color: color),
          Expanded(
            child: Text(
              sinStock
                  ? "¡Sin existencias! (mínimo: $stockMinimo)"
                  : "¡Quedan $stockActual piezas! (mínimo: $stockMinimo)",
              style: theme.textTheme.bodyMedium!.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}