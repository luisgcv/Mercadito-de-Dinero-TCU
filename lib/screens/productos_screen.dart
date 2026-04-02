import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app/screens/producto_form_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../controllers/producto_controller.dart';
import '../models/producto.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  Future<void> _confirmarEliminarProducto(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar producto'),
          content: Text('¿Seguro que deseas eliminar "${producto.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    await Provider.of<ProductoController>(context, listen: false)
        .eliminarProducto(producto.id!);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${producto.nombre} eliminado')),
    );
  }

  Future<void> _exportarQrProducto(Producto producto) async {
    try {
      final String nombreArchivo =
          'qr_${_limpiarNombreArchivo(producto.nombre)}_${producto.id ?? 'sin_id'}.png';

      final painter = QrPainter(
        data: producto.codigoQr,
        version: QrVersions.auto,
        gapless: true,
        color: Colors.black,
        emptyColor: Colors.white,
      );

      final byteData = await painter.toImageData(
        1024,
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('No se pudo generar la imagen QR.');
      }

      final Uint8List bytes = byteData.buffer.asUint8List();

      if (Platform.isAndroid || Platform.isIOS) {
        final rutaMovil = await FilePicker.platform.saveFile(
          dialogTitle: 'Guardar QR como',
          fileName: nombreArchivo,
          type: FileType.custom,
          allowedExtensions: ['png'],
          bytes: bytes,
        );

        if (rutaMovil == null || rutaMovil.isEmpty) return;

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR guardado en: $rutaMovil')),
        );
        return;
      }

      final rutaArchivo = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar QR como',
        fileName: nombreArchivo,
        type: FileType.custom,
        allowedExtensions: ['png'],
      );

      if (rutaArchivo == null || rutaArchivo.isEmpty) return;
      final archivo = await _guardarQrEnRuta(rutaArchivo, bytes);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR guardado en: ${archivo.path}')),
      );
    } on FileSystemException catch (e) {
      if (!mounted) return;

      final rutaIntentada = e.path ?? 'ruta no disponible';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar en la carpeta elegida. Ruta: $rutaIntentada',
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final msg = e.toString();
      final esErrorInitPlugin =
          msg.contains('LateInitializationError') && msg.contains('_instance');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            esErrorInitPlugin
                ? 'El plugin no se inicializo. Cierra y abre la app completa.'
                : 'Error al exportar QR: $msg',
          ),
        ),
      );
    }
  }

  Future<File> _guardarQrEnRuta(
    String rutaArchivo,
    Uint8List bytes,
  ) async {
    final rutaNormalizada = _normalizarRutaArchivo(rutaArchivo);
    final rutaFinal = rutaNormalizada.toLowerCase().endsWith('.png')
        ? rutaNormalizada
        : '$rutaNormalizada.png';

    final rutaAbsoluta = p.normalize(rutaFinal);
    final archivo = File(rutaAbsoluta);

    final carpetaPadre = Directory(p.dirname(rutaAbsoluta));
    if (!await carpetaPadre.exists()) {
      await carpetaPadre.create(recursive: true);
    }

    await archivo.writeAsBytes(bytes, flush: true);

    final existe = await archivo.exists();
    final tamano = existe ? await archivo.length() : 0;

    if (!existe || tamano == 0) {
      throw FileSystemException(
        'El archivo no se guardo correctamente',
        rutaAbsoluta,
      );
    }

    return archivo;
  }

  String _normalizarRutaArchivo(String rutaArchivo) {
    if (rutaArchivo.startsWith('file://')) {
      return Uri.parse(rutaArchivo).toFilePath();
    }
    return rutaArchivo;
  }

  String _limpiarNombreArchivo(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  void _mostrarQrProducto(BuildContext context, Producto producto) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(producto.nombre),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: producto.codigoQr,
                version: QrVersions.auto,
                size: 220,
              ),
              const SizedBox(height: 16),
              Text(
                'QR: ${producto.codigoQr}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('Precio: ₡${producto.precio}'),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _exportarQrProducto(producto),
              icon: const Icon(Icons.download),
              label: const Text('Exportar QR'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Cargar productos al iniciar
    Future.microtask(() {
      Provider.of<ProductoController>(context, listen: false)
          .cargarProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ProductoController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Productos"),
      ),

      body: controller.productos.isEmpty
          ? const Center(child: Text("No hay productos"))
          : ListView.builder(
              itemCount: controller.productos.length,
              itemBuilder: (context, index) {
                final p = controller.productos[index];

                return ListTile(
                  title: Text(p.nombre),
                  subtitle: Text("₡${p.precio}\nQR: ${p.codigoQr}"),
                  onTap: () => _mostrarQrProducto(context, p),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _confirmarEliminarProducto(p);
                    },
                  ),
                );
              },
            ),

            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductoFormScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}