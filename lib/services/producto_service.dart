import '../database/database_helper.dart';
import '../models/producto.dart';
import 'image_storage_service.dart';

class ProductoService {
  final db = DatabaseHelper.instance;
  final ImageStorageService _imageStorage = ImageStorageService();

  Future<List<Producto>> obtenerProductos() async {
    final data = await db.getProductos();
    return data.map((e) => Producto.fromMap(e)).toList();
  }

  Future<void> agregarProducto(
    Producto producto, {
    String? imagenTemporalPath,
  }) async {
    String? imagePath = producto.imagePath;

    if (imagenTemporalPath != null && imagenTemporalPath.isNotEmpty) {
      imagePath = await _imageStorage.saveImageFromPath(
        imagenTemporalPath,
        baseName: '${producto.nombre}_${producto.codigoQr}',
      );
    }

    await db.insertProducto(producto.copyWith(imagePath: imagePath).toMap());
  }

  Future<void> actualizarProducto(
    Producto producto, {
    String? imagenTemporalPath,
  }) async {
    String? imagePath = producto.imagePath;

    if (imagenTemporalPath != null && imagenTemporalPath.isNotEmpty) {
      imagePath = await _imageStorage.replaceImageFromPath(
        sourcePath: imagenTemporalPath,
        previousRelativePath: producto.imagePath,
        baseName: '${producto.nombre}_${producto.codigoQr}',
      );
    }

    await db.updateProducto(producto.copyWith(imagePath: imagePath).toMap());
  }

  Future<void> eliminarProducto(
    int id, {
    String? imagePath,
  }) async {
    await db.deleteProducto(id);

    if (imagePath != null && imagePath.isNotEmpty) {
      await _imageStorage.deleteImage(imagePath);
    }
  }

  Future<void> eliminarTodosLosProductos() async {
    final productos = await obtenerProductos();

    await db.deleteAllProductos();

    for (final producto in productos) {
      if (producto.imagePath != null && producto.imagePath!.isNotEmpty) {
        try {
          await _imageStorage.deleteImage(producto.imagePath);
        } catch (_) {}
      }
    }
  }

  Future<Producto?> buscarPorQR(String qr) async {
    final data = await db.getProductoByQR(qr);
    if (data == null) return null;
    return Producto.fromMap(data);
  }

  Future<List<Producto>> buscarPorNombre(String nombre) async {
    final data = await db.buscarPorNombre(nombre);
    return data.map((e) => Producto.fromMap(e)).toList();
  }

  Future<String?> obtenerRutaImagenAbsoluta(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    return _imageStorage.resolveAbsolutePath(imagePath);
  }

  Future<bool> imagenExiste(String? imagePath) {
    return _imageStorage.exists(imagePath);
  }

  Future<String?> obtenerRutaImagenSiExiste(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    final existe = await _imageStorage.exists(imagePath);
    if (!existe) {
      return null;
    }

    return _imageStorage.resolveAbsolutePath(imagePath);
  }
}