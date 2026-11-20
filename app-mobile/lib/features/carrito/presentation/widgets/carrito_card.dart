import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/features/carrito/domain/carrito.dart';
import 'package:ecommerce_app/core/ui/cantidad_input.dart';
import 'package:ecommerce_app/features/productos/data/models/stock_linea_response_dto.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CarritoCard extends StatefulWidget {
  const CarritoCard({ super.key, required this.item, required this.onUpdate, required this.deleteFunction, this.stockResponse });

  final CarritoItem item;
  final void Function() deleteFunction;
  final void Function(int) onUpdate;
  final StockLineaResponseDto? stockResponse;

  @override
  State<StatefulWidget> createState() => _CarritoCardState();
}

class _CarritoCardState extends State<CarritoCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    final subtotal = item.producto.precio * item.cantidad;
    final stockLinea = widget.stockResponse;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox.square(
                    dimension: 80,
                    child: CachedNetworkImage(
                      imageUrl: item.producto.imagen,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Image.asset(
                        'assets/images/prod_placeholder.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.producto.nombre,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          InkWell(
                            onTap: widget.deleteFunction,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(LucideIcons.trash,
                                  size: 18,
                                  color: AppColors.primario.c400),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${item.producto.precio.toStringAsFixed(2)} c/u',
                        style: theme.textTheme.bodySmall!
                            .copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CantidadInput(
                            defaultValue: item.cantidad,
                            max: item.producto.stock,
                            min: 1,
                            onChange: widget.onUpdate,
                            size: .small,
                          ),
                          Text(
                            '\$${subtotal.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (stockLinea != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stockLinea.motivo,
                  style: theme.textTheme.bodySmall!
                      .copyWith(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}