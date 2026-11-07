import 'package:flutter/material.dart';

import 'package:ecommerce_app/core/layout/layout_externo.dart';

//TODO Este modal es para registro de una entrada, checar el figma
class HistorialEntradasProducto extends StatelessWidget {
  const HistorialEntradasProducto({ super.key, required this.productoId });

  final int productoId;

  @override
  Widget build(BuildContext context) {
    //TODO esta página es para consultar el historial individual de entradas para un producto
    return Scaffold(
      appBar: AppBarExterno(title: "Historial de entradas"),
      body: SafeArea(child:
      Padding(
        padding: .all(16),
        child: Text("Historial de entradas para $productoId"),
      )
      ),
    );
  }


}