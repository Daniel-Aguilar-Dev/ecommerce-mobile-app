import 'package:ecommerce_app/core/theme/colors.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:flutter/material.dart';

class CategoriaTabs extends StatelessWidget {
  const CategoriaTabs({
    super.key,
    required this.categorias,
    required this.seleccionada,
    required this.onSelect,
  });

  final List<Categoria> categorias;   // tu modelo
  final int seleccionada;             // 0 = Todo
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = [
      (id: 0, nombre: 'Todo'),
      ...categorias.map((c) => (id: c.id, nombre: c.nombre)),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, i) {
          final item = items[i];
          final activo = item.id == seleccionada;

          return InkWell(
            onTap: () => onSelect(item.id),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: activo ? AppColors.primario.c400 : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                item.nombre,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: activo
                      ? AppColors.primario.c400
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}