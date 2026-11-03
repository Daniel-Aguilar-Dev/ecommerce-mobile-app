import 'package:ecommerce_app/features/productos/presentation/escanear_producto_page_two.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class EscanearProductoPageOne extends StatefulWidget {
  const EscanearProductoPageOne({super.key});

  @override
  State<EscanearProductoPageOne> createState() =>
      _EscanearProductoPageOneState();
}

class _EscanearProductoPageOneState
    extends State<EscanearProductoPageOne> {
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = MobileScannerController(
      formats: const [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
      ],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) async{
          final codigo = capture.barcodes.firstOrNull?.rawValue;

          if (codigo == null) return;

          await _controller.stop();

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EscanearProductoPageTwo(sku: codigo),
            ),
          );
        },
      ),
    );
  }
}