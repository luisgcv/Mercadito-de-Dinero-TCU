import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../controllers/carrito_controller.dart';
import '../controllers/producto_controller.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoController>(context, listen: false);
    final productos = Provider.of<ProductoController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Escanear producto")),
      body: MobileScanner(
        controller: _scannerController,
        onDetect: (capture) async {
          if (_isProcessing) return;

          final Barcode? barcode = capture.barcodes.isNotEmpty
              ? capture.barcodes.first
              : null;
          final String? code = barcode?.rawValue;

          if (code == null) return;

          _isProcessing = true;

          // buscar producto por QR
          final producto = await productos.buscarPorQR(code);

          if (producto != null) {
            carrito.agregarProducto(producto);

            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${producto.nombre} agregado")),
            );

            Navigator.pop(context); // volver al carrito
          } else {
            _isProcessing = false;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Producto no encontrado")),
            );
          }
        },
      ),
    );
  }
}