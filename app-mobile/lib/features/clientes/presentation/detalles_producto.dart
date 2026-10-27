import 'package:ecommerce_app/core/layout/layout_externo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_view_model.dart';

class DetallesProducto extends StatefulWidget {
  const DetallesProducto({super.key});

  @override
  State<DetallesProducto> createState() => _DetallesProductoState();
}

class _DetallesProductoState extends State<DetallesProducto>{

  @override
  Widget build(BuildContext context) {
    late final status = context.select<AuthViewModel, AuthStatus>((a) => a.status);
    return Scaffold(
      appBar: AppBarExterno(title: "Detalles del producto"),
      body: Text("Producto $status"),
    );
  }
}