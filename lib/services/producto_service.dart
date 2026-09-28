import '../database/database_helper.dart';
import '../models/producto.dart';
import 'image_storage_service.dart';

/// Lógica de negocio de los productos.
///
/// Une la base de datos ([DatabaseHelper]) con el almacenamiento de imágenes
/// ([ImageStorageService]): por ejemplo, al eliminar un producto también
/// borra su imagen, y al guardarlo copia la imagen seleccionada a la app.
/// Convierte las filas de SQLite en objetos [Producto].
class ProductoService {
  /// Acceso a SQLite.
  final db = DatabaseHelper.instance;
  final ImageStorageService _imageStorage = ImageStorageService();

  /// Devuelve todos los productos de la base de datos.
  Future<List<Producto>> obtenerProductos() async {
    final data = await db.getProductos();
    return data.map((e) => Producto.fromMap(e)).toList();
  }

  /// Inserta [producto]. Si se indica [imagenTemporalPath], primero copia la
  /// imagen a la carpeta de la app y guarda su ruta relativa.
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

  /// Actualiza [producto]. Si se indica [imagenTemporalPath], guarda la
  /// imagen nueva y borra la anterior.
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

  /// Elimina el producto [id] y, si tenía, su archivo de imagen.
  Future<void> eliminarProducto(
    int id, {
    String? imagePath,
  }) async {
    await db.deleteProducto(id);

    if (imagePath != null && imagePath.isNotEmpty) {
      await _imageStorage.deleteImage(imagePath);
    }
  }

  /// Elimina todos los productos y luego intenta borrar cada imagen
  /// (los errores al borrar imágenes se ignoran).
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

  /// Busca un producto por su código QR; `null` si no existe.
  Future<Producto?> buscarPorQR(String qr) async {
    final data = await db.getProductoByQR(qr);
    if (data == null) return null;
    return Producto.fromMap(data);
  }

  /// Busca productos cuyo nombre contenga [nombre].
  Future<List<Producto>> buscarPorNombre(String nombre) async {
    final data = await db.buscarPorNombre(nombre);
    return data.map((e) => Producto.fromMap(e)).toList();
  }

  /// Convierte la ruta relativa de la imagen en absoluta (sin verificar que
  /// exista). Actualmente sin uso.
  Future<String?> obtenerRutaImagenAbsoluta(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    return _imageStorage.resolveAbsolutePath(imagePath);
  }

  /// Indica si el archivo de imagen existe. Actualmente sin uso.
  Future<bool> imagenExiste(String? imagePath) {
    return _imageStorage.exists(imagePath);
  }

  /// Devuelve la ruta absoluta de la imagen solo si el archivo existe;
  /// en otro caso `null`.
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