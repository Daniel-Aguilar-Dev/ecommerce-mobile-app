import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ecommerce_app/core/layout/escaner_page.dart';

/// Un solo escaneo. Devuelve null si el usuario cancela.
Future<String?> escanearCodigo(
    BuildContext context, {
      List<BarcodeFormat> formatos = const [
        BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA,
      ],
    }) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute(builder: (_) => EscanerPage(formatos: formatos)),
  );
}

/// QR de pedidos (HU-6.9 y 6.10).
Future<String?> escanearQr(BuildContext context) =>
    escanearCodigo(context, formatos: const [BarcodeFormat.qrCode]);

/// Escaneo continuo (HU-7.1). La pantalla se cierra con el botón atrás.
Future<void> escanearContinuo(
    BuildContext context,
    void Function(String codigo) onCodigo,
    ) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => EscanerPage(continuo: true, onCodigo: onCodigo),
    ),
  );
}