import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria_public.dart';
import 'package:ecommerce_app/features/productos/domain/producto_estado.dart';
import 'package:ecommerce_app/features/productos/domain/producto_public.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProductoCardPublic extends StatelessWidget{
  const ProductoCardPublic({
    super.key,
    required this.producto,
    required this.onCardTouch,
    required this.onPressButton,
    this.loading = false,
    this.showButton = true,
  });

  final ProductoPublic producto;
  final VoidCallback onCardTouch;
  final VoidCallback onPressButton;
  final bool loading;
  final bool showButton;

  String get _precio {
    final p = producto.precio;
    return '\$${p.toStringAsFixed(2)}';
  }

  ({Color fondo, Color color}) get _disponibilidad {
    final estado = producto.estadoStock;
    if (estado == "Agotado") {
      return (fondo: AppColors.error.soft, color: AppColors.error.onSoft);
    }
    if (estado == "Pocas unidades") {
      return (fondo: AppColors.warning.soft, color: AppColors.warning.onSoft);
    }
    return (fondo: AppColors.success.soft, color: AppColors.success.onSoft);
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
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: producto.imagen,
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
                        producto.estadoStock,
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
                        ?showButton ? IconButton(
                          onPressed: onPressButton,
                          icon: const Icon(LucideIcons.shoppingCartPlus, size: 20,),
                          color: Colors.white,
                          style: IconButton.styleFrom(
                            backgroundColor: producto.stock <= 0 ? AppColors.border :  loading ? AppColors.texto.c500 : AppColors.primario.c400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ) : null
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

  ProductoCardPublic.placeholder({Key? key}) : this(
      producto: ProductoPublic(id: 0, nombre: "Nombre", descripcion: "Descripcion", marca: "Marca", stock: 0, precio: 0, unidadMedia: "unidadMedia", estado: ProductoEstado.PROD_ACTIVO, categoria: CategoriaPublic(id: 0, nombre: "nombre", descripcion: "descripcion"), imagen: "imagenUrl", estadoStock: ""),
      onCardTouch: (){},
      onPressButton: (){}
  );
}