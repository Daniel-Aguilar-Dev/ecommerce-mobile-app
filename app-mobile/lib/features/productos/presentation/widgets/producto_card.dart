import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/productos/domain/producto_estado.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/features/productos/domain/producto.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProductoCard extends StatelessWidget{
  const ProductoCard({
    super.key, 
    required this.producto,
    required this.onCardTouch,
    required this.onPressButton
  });

  final Producto producto;
  final VoidCallback onCardTouch;
  final VoidCallback onPressButton;

  String get _precio {
    final p = producto.precioVenta;
    return '\$${p.toStringAsFixed(2)}';
  }

  ({String texto, Color fondo, Color color}) get _disponibilidad {
    final disponible = producto.stockActual - producto.stockReservado;
    final estado = producto.estado;
    if(estado == ProductoEstado.PROD_DESCONTINUADO){
      return (texto: 'Descontinuado', fondo: AppColors.info.soft, color: AppColors.info.onSoft);
    }
    if (disponible <= 0) {
      return (texto: 'Agotado', fondo: AppColors.error.soft, color: AppColors.error.onSoft);
    }
    if (disponible <= producto.stockMinimo) {
      return (texto: 'Pocas unidades', fondo: AppColors.warning.soft, color: AppColors.warning.onSoft);
    }
    return (texto: 'Disponible', fondo: AppColors.success.soft, color: AppColors.success.onSoft);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disp = _disponibilidad;
    return GestureDetector(
      onTap: onCardTouch,
      child: SizedBox(
        child: Card(
          color: Colors.white,
          elevation: .5,
          child: Column(
            mainAxisSize: .min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: producto.imagenUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Image.asset(
                    'assets/images/prod_placeholder.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: .all(8),
                child: Column(
                  mainAxisSize: .min,
                  mainAxisAlignment: .start,
                  crossAxisAlignment: .start,
                  children: [
                    SizedBox(
                      height: theme.textTheme.bodyMedium!.fontSize! * 1.4 * 2,
                      child: Text(
                        producto.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: disp.fondo,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        disp.texto,
                        style: theme.textTheme.labelMedium!.copyWith(
                          color: disp.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: .center,
                      mainAxisAlignment: .center,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 30,
                            child: Text(
                              _precio,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onPressButton,
                          icon: const Icon(LucideIcons.ellipsisVertical),
                          style: IconButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  ProductoCard.placeholder({Key? key}) : this(
    producto: Producto(id: 0, nombre: "Nombre", descripcion: "Descripcion", marca: "Marca", stockActual: 0, stockMinimo: 0, stockReservado: 0, precioVenta: 0, precioCompra: 0, unidadMedia: "unidadMedia", estado: ProductoEstado.PROD_ACTIVO, costoPromedio: 0, categoria: Categoria(id: 0, nombre: "nombre", descripcion: "descripcion", tieneProductos: false), imagenPublicId: "imagenPublicId", imagenVersion: 0, imagenUrl: "imagenUrl"),
    onCardTouch: (){},
    onPressButton: (){}
  );
}