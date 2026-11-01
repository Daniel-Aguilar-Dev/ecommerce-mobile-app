import 'package:flutter/material.dart';
import 'package:ecommerce_app/core/layout/layout_externo.dart';

import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';
import 'package:ecommerce_app/features/productos/presentation/viewmodel/producto_view_model.dart';
import 'package:provider/provider.dart';

class NuevoProductoView extends StatelessWidget {
  const NuevoProductoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProductoViewModel(
        productoRepository: ctx.read<ProductoRepository>(),
      )..cargar(),
      child: const _NuevoProductoPage(),
    );
  }
}

class _NuevoProductoPage extends StatefulWidget {
  const _NuevoProductoPage({super.key});

  @override
  State<_NuevoProductoPage> createState() => _NuevoProductoPageState();
}

class _NuevoProductoPageState extends State<_NuevoProductoPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarExterno(title: "Nuevo producto"),
      body: SafeArea(child:
      Padding(
        padding: .all(16),
        child: Text("Nuevo producto"),
      )
      ),
    );
  }
}