import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

class ProductoController extends ChangeNotifier {
  final ProductoService _service = ProductoService();

  List<Producto> productos = [];
  String? _imagenSeleccionadaTemporalPath;
  bool isLoading = false;
  String? errorMessage;

  String? get imagenSeleccionadaTemporalPath =>
      _imagenSeleccionadaTemporalPath;

  bool get tieneImagenSeleccionada =>
      _imagenSeleccionadaTemporalPath != null &&
      _imagenSeleccionadaTemporalPath!.isNotEmpty;

  Future<void> cargarProductos() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      productos = await _service.obtenerProductos();
    } catch (e) {
      errorMessage = 'No se pudieron cargar los productos: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> seleccionarImagen() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: false,
      );

      final path = resultado?.files.single.path;
      if (path == null || path.isEmpty) {
        return false;
      }

      _imagenSeleccionadaTemporalPath = path;
      errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'No se pudo seleccionar la imagen: $e';
      notifyListeners();
      return false;
    }
  }

  void limpiarImagenSeleccionada() {
    _imagenSeleccionadaTemporalPath = null;
    notifyListeners();
  }

  Future<bool> agregarProducto(Producto producto) async {
    try {
      await _service.agregarProducto(
        producto,
        imagenTemporalPath: _imagenSeleccionadaTemporalPath,
      );
      limpiarImagenSeleccionada();
      await cargarProductos();
      return true;
    } catch (e) {
      errorMessage = 'No se pudo guardar el producto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarProducto(Producto producto) async {
    try {
      await _service.actualizarProducto(
        producto,
        imagenTemporalPath: _imagenSeleccionadaTemporalPath,
      );
      limpiarImagenSeleccionada();
      await cargarProductos();
      return true;
    } catch (e) {
      errorMessage = 'No se pudo actualizar el producto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarProducto(Producto producto) async {
    try {
      await _service.eliminarProducto(
        producto.id!,
        imagePath: producto.imagePath,
      );
      await cargarProductos();
      return true;
    } catch (e) {
      errorMessage = 'No se pudo eliminar el producto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarTodosLosProductos() async {
    try {
      await _service.eliminarTodosLosProductos();
      await cargarProductos();
      return true;
    } catch (e) {
      errorMessage = 'No se pudieron eliminar los productos: $e';
      notifyListeners();
      return false;
    }
  }

  Future<Producto?> buscarPorQR(String qr) async {
    return _service.buscarPorQR(qr);
  }

  Future<List<Producto>> buscarPorNombre(String nombre) async {
    return _service.buscarPorNombre(nombre);
  }

  Future<String?> obtenerRutaImagenSiExiste(String? imagePath) {
    return _service.obtenerRutaImagenSiExiste(imagePath);
  }
}

