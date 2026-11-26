import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CategoriaCard extends StatelessWidget {
  const CategoriaCard({
    super.key,
    required this.categoria,
    required this.onPressButton
  });

  final Categoria categoria;
  final void Function(Categoria) onPressButton;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 4),
        title: Text(categoria.nombre,
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.texto.c900)),
        subtitle: Text(categoria.descripcion,
            style: const TextStyle(color: Color(0xFFA9A9A9))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: .start,
          mainAxisAlignment: .end,
          children: [
            IconButton(
              onPressed:() => onPressButton(categoria),
              icon: Icon(LucideIcons.ellipsisVertical),
              padding: const EdgeInsets.all(4),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  CategoriaCard.placeholder({Key? key}) : this(key: key,categoria: Categoria(id: 0, nombre: "placeholder", descripcion: "placeholder de producto", tieneProductos: false), onPressButton: (Categoria c) {});
}