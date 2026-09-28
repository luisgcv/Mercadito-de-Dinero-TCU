import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

/// Controlador (estado observable) del catálogo de productos.
///
/// Mantiene la lista [productos] cargada desde la base de datos y el estado
/// de la imagen que el usuario está seleccionando en el formulario. Delega
/// la persistencia a [ProductoService].
///
/// Convención de los métodos que modifican datos: devuelven `true` si la
/// operación fue exitosa y `false` si falló; en ese caso el detalle queda en
/// [errorMessage] para mostrarlo en pantalla.
class ProductoController extends ChangeNotifier {
  final ProductoService _service = ProductoService();

  /// Productos cargados actualmente (se refresca con [cargarProductos]).
  List<Producto> productos = [];
  /// Ruta (fuera de la app) de la imagen elegida en el formulario y todavía
  /// no guardada. Se copia al almacenamiento de la app al guardar el producto.
  String? _imagenSeleccionadaTemporalPath;
  /// `true` mientras se cargan los productos.
  bool isLoading = false;
  /// Último mensaje de error, o `null` si la última operación fue exitosa.
  String? errorMessage;

  /// Ruta de la imagen seleccionada en el formulario (para previsualizarla).
  String? get imagenSeleccionadaTemporalPath =>
      _imagenSeleccionadaTemporalPath;

  /// Indica si el usuario ya eligió una imagen en el formulario.
  bool get tieneImagenSeleccionada =>
      _imagenSeleccionadaTemporalPath != null &&
      _imagenSeleccionadaTemporalPath!.isNotEmpty;

  /// Recarga [productos] desde la base de datos y notifica a la interfaz.
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

  /// Abre el selector de archivos del sistema para elegir una imagen.
  ///
  /// Solo guarda la ruta temporal; la imagen se copia a la app cuando se
  /// llama a [agregarProducto] o [actualizarProducto]. Devuelve `false` si
  /// el usuario cancela o si hay un error.
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

  /// Descarta la imagen seleccionada en el formulario.
  void limpiarImagenSeleccionada() {
    _imagenSeleccionadaTemporalPath = null;
    notifyListeners();
  }

  /// Guarda un producto nuevo (con la imagen seleccionada, si hay) y recarga
  /// la lista.
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

  /// Actualiza un producto existente. Si hay una imagen seleccionada,
  /// reemplaza la anterior (borrando el archivo viejo).
  ///
  /// Nota: actualmente ninguna pantalla lo usa; queda listo para cuando se
  /// agregue la edición de productos.
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

  /// Elimina el producto y su imagen asociada. Requiere que `producto.id`
  /// no sea `null`.
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

  /// Elimina todos los productos y sus imágenes.
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

  /// Busca un producto por el texto leído de su código QR.
  Future<Producto?> buscarPorQR(String qr) async {
    return _service.buscarPorQR(qr);
  }

  /// Busca productos cuyo nombre contenga [nombre].
  Future<List<Producto>> buscarPorNombre(String nombre) async {
    return _service.buscarPorNombre(nombre);
  }

  /// Devuelve la ruta absoluta de la imagen si el archivo existe, o `null`.
  /// Útil para mostrar la imagen con `Image.file`/`FileImage`.
  Future<String?> obtenerRutaImagenSiExiste(String? imagePath) {
    return _service.obtenerRutaImagenSiExiste(imagePath);
  }
}

