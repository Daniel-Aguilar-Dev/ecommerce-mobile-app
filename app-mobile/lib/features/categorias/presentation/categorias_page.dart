import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:ecommerce_app/core/ui/custom_form_field.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/categorias/presentation/widgets/categoria_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lucide_icons_flutter/lucide_icons_600.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:ecommerce_app/core/theme/colors.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage>{
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _newCategoriaModal() {}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: .all(16),
        child: Column(
          spacing: 16,
          children: [
            CustomField(
              controller: _searchController,
              hint: 'Buscar una categoría',
              icon: LucideIcons.search,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            Expanded(
              child: ListView(
                children: [
                  CategoriaCard(categoria: Categoria(createdAt: DateTime(2026), updatedAt: DateTime(2026), createdBy: 1, updatedBy: 1, id: 1, nombre: "Vinos y licores", descripcion: "Bebidas con alcohol saborizadas", tieneProductos: false)),
                  CategoriaCard(categoria: Categoria(createdAt: DateTime(2026), updatedAt: DateTime(2026), createdBy: 1, updatedBy: 1, id: 2, nombre: "Vinos y licores", descripcion: "Bebidas con alcohol saborizadas", tieneProductos: false)),
                  CategoriaCard(categoria: Categoria(createdAt: DateTime(2026), updatedAt: DateTime(2026), createdBy: 1, updatedBy: 1, id: 3, nombre: "Vinos y licores", descripcion: "Bebidas con alcohol saborizadas", tieneProductos: false)),
                  CategoriaCard(categoria: Categoria(createdAt: DateTime(2026), updatedAt: DateTime(2026), createdBy: 1, updatedBy: 1, id: 4, nombre: "Vinos y licores", descripcion: "Bebidas con alcohol saborizadas", tieneProductos: false)),
                  CategoriaCard(categoria: Categoria(createdAt: DateTime(2026), updatedAt: DateTime(2026), createdBy: 1, updatedBy: 1, id: 5, nombre: "Vinos y licores", descripcion: "Bebidas con alcohol saborizadas", tieneProductos: false)),
                  CategoriaCard(categoria: Categoria(createdAt: DateTime(2026), updatedAt: DateTime(2026), createdBy: 1, updatedBy: 1, id: 6, nombre: "Vinos y licores", descripcion: "Bebidas con alcohol saborizadas", tieneProductos: false)),
                  CategoriaCard(categoria: Categoria(createdAt: DateTime(2026), updatedAt: DateTime(2026), createdBy: 1, updatedBy: 1, id: 7, nombre: "Vinos y licores", descripcion: "Bebidas con alcohol saborizadas", tieneProductos: false)),
                  CategoriaCard(categoria: Categoria(createdAt: DateTime(2026), updatedAt: DateTime(2026), createdBy: 1, updatedBy: 1, id: 8, nombre: "Vinos y licores", descripcion: "Bebidas con alcohol saborizadas", tieneProductos: false)),
                  CategoriaCard(categoria: Categoria(createdAt: DateTime(2026), updatedAt: DateTime(2026), createdBy: 1, updatedBy: 1, id: 9, nombre: "Vinos y licores", descripcion: "Bebidas con alcohol saborizadas", tieneProductos: false)),
                ],
              )
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primario.c400,
        onPressed: _newCategoriaModal,
        elevation: 1,
        child: Icon(LucideIcons600.plus, color: Colors.white),
      ),
    );
  }
}