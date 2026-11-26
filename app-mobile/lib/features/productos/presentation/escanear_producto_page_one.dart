import 'package:ecommerce_app/features/productos/presentation/escanear_producto_page_two.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class EscanearProductoPageOne extends StatefulWidget {
  const EscanearProductoPageOne({super.key});

  @override
  State<EscanearProductoPageOne> createState() =>
      _EscanearProductoPageOneState();
}

class _EscanearProductoPageOneState extends State<EscanearProductoPageOne> {
  late final MobileScannerController _controller;
  bool _procesando = false;

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
    _controller.dispose(); // dispose ya detiene la cámara
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_procesando) return;

    final codigo = capture.barcodes.firstOrNull?.rawValue;
    if (codigo == null) return;

    _procesando = true;
    await _controller.stop(); // pausa la cámara mientras estás en la otra pantalla

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EscanearProductoPageTwo(sku: codigo),
      ),
    );

    // Al regresar: reanudar
    if (!mounted) return;
    _procesando = false;
    await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
      ),
    );
  }
}