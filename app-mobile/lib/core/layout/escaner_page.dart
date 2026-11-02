import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_600.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EscanerPage extends StatefulWidget {
  const EscanerPage({
    super.key,
    this.formatos = const [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA],
    this.continuo = false,
    this.isNested = false,
    this.onCodigo, // solo para modo continuo
  });

  final List<BarcodeFormat> formatos;
  final bool continuo;
  final bool isNested;
  final void Function(String codigo)? onCodigo;

  @override
  State<EscanerPage> createState() => _EscanerPageState();
}

class _EscanerPageState extends State<EscanerPage> {
  late final MobileScannerController _controller = MobileScannerController(
    formats: widget.formatos,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  String? _ultimo;
  DateTime _ultimaLectura = DateTime.fromMillisecondsSinceEpoch(0);

  void _onDetect(BarcodeCapture capture) {
    final codigo = capture.barcodes.firstOrNull?.rawValue;
    if (codigo == null) return;

    if (!widget.continuo) {
      Navigator.of(context).pop(codigo); // un solo escaneo
      return;
    }

    // continuo: debounce de 1.5 s para el mismo código
    final ahora = DateTime.now();
    if (codigo == _ultimo &&
        ahora.difference(_ultimaLectura) < const Duration(milliseconds: 1500)) {
      return;
    }
    _ultimo = codigo;
    _ultimaLectura = ahora;
    widget.onCodigo?.call(codigo);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: widget.isNested ? null : IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons600.arrowLeft)),
        title: Text(widget.continuo ? 'Escaneando…' : 'Escanear código'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.flashlight),
            onPressed: _controller.toggleTorch,
          ),
        ],
      ),
      body: MobileScanner(controller: _controller, onDetect: _onDetect),
    );
  }
}