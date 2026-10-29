import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CategoriaCard extends StatefulWidget {
  const CategoriaCard({
    super.key,
    required this.categoria
  });

  final Categoria categoria;

  @override
  State<CategoriaCard> createState() => _CategoriaCardState();
}

class _CategoriaCardState extends State<CategoriaCard>{
  void _onEdit(){}
  void _onDelete(){}
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      child: ListTile(
        title: Text(widget.categoria.nombre, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.texto.c900)),
        subtitle: Text(widget.categoria.descripcion, style: TextStyle(color: const Color(0xFFA9A9A9))),
        trailing: Row(
          mainAxisSize: .min,
          children: [
            IconButton(
              onPressed: _onEdit,
              icon: Icon(LucideIcons.edit, color: AppColors.info.onSoft),
              padding: .all(4),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: AppColors.info.soft
              ),
            ),
            if(!widget.categoria.tieneProductos) IconButton(
              onPressed: _onDelete,
              icon: Icon(LucideIcons.trash, color: AppColors.error.onSoft),
              padding: .all(4),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: AppColors.error.soft
              ),
            ),
          ],
        ),
      ),
    );
  }
}
