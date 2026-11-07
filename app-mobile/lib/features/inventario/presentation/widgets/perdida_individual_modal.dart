import 'package:ecommerce_app/core/ui/campos_obligatorios_text.dart';
import 'package:ecommerce_app/core/ui/modal_cancel_button.dart';
import 'package:ecommerce_app/core/ui/modal_confirm_button.dart';
import 'package:flutter/material.dart';

import 'package:ecommerce_app/features/productos/domain/producto.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

//TODO Este modal es para registro de una pérdida, checar el figma
class PerdidaIndividualModal extends StatelessWidget {
  PerdidaIndividualModal({
    super.key,
    required this.producto,
  });

  final Producto producto;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [
          Expanded(
            child: Text('Registrar pérdida', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x), iconSize: 18, padding: .all(2), color: const Color(0xFF767778))
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          mainAxisAlignment: .start,
          children: [
            CamposObligatoriosText()
          ],
        ),
      ),
      actions: [
        ModalCancelButton(
            onPressed: () {}
        ),
        ModalConfirmButton(
            onPressed: () async {},
            isLoading: false,
            label: "Guardar"
        )
      ],
    );
  }
}