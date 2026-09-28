import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../controllers/carrito_controller.dart';
import '../controllers/producto_controller.dart';
import '../services/audio_service.dart';

/// Escáner de códigos QR con la cámara (paquete `mobile_scanner`).
///
/// Al detectar un código busca el producto con ese `codigoQr`:
/// - Si existe: lo agrega al carrito, reproduce el sonido de éxito y vuelve
///   a [CarritoScreen].
/// - Si no existe: muestra "Producto no encontrado" y sigue escaneando.
///
/// Requiere permiso de cámara (declarado en `AndroidManifest.xml` e
/// `Info.plist`).
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  /// Controlador de la cámara. `noDuplicates` evita leer el mismo código
  /// varias veces seguidas.
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  /// Evita procesar varias lecturas mientras se busca un producto.
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
            await AudioService.playSuccess();

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