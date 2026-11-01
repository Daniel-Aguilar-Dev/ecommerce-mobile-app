import 'package:flutter/material.dart';
import 'package:ecommerce_app/core/layout/layout_externo.dart';

import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';
import 'package:ecommerce_app/features/productos/presentation/viewmodel/producto_view_model.dart';
import 'package:provider/provider.dart';

class EditarProductoView extends StatelessWidget {
  const EditarProductoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProductoViewModel(
        productoRepository: ctx.read<ProductoRepository>(),
      )..cargar(),
      child: const _EditarProductoPage(),
    );
  }
}

class _EditarProductoPage extends StatefulWidget {
  const _EditarProductoPage({super.key});

  @override
  State<_EditarProductoPage> createState() => _EditarProductoPageState();
}

class _EditarProductoPageState extends State<_EditarProductoPage>{

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductoViewModel>();
    return Scaffold(
      appBar: AppBarExterno(title: "Modificar producto"),
      body: SafeArea(child:
      Padding(
        padding: .all(16),
        child: Text("Editar producto"),
      )
      ),
    );
  }
}