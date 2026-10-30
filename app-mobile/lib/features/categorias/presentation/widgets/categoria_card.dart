import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CategoriaCard extends StatelessWidget {
  const CategoriaCard({
    super.key,
    required this.categoria,
    required this.onEdit,
    required this.onDelete,
  });

  final Categoria categoria;
  final void Function(Categoria) onEdit;
  final void Function(Categoria) onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      child: ListTile(
        title: Text(categoria.nombre,
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.texto.c900)),
        subtitle: Text(categoria.descripcion,
            style: const TextStyle(color: Color(0xFFA9A9A9))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed:() => onEdit(categoria),
              icon: Icon(LucideIcons.edit, color: AppColors.info.onSoft),
              padding: const EdgeInsets.all(4),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: AppColors.info.soft,
              ),
            ),
            if (!categoria.tieneProductos)
              IconButton(
                onPressed: () => onDelete(categoria),
                icon: Icon(LucideIcons.trash, color: AppColors.error.onSoft),
                padding: const EdgeInsets.all(4),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: AppColors.error.soft,
                ),
              ),
          ],
        ),
      ),
    );
  }
}