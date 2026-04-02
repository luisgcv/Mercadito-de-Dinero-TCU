import '../database/database_helper.dart';
import '../models/producto.dart';

class ProductoService {
  final db = DatabaseHelper.instance;

  Future<List<Producto>> obtenerProductos() async {
    final data = await db.getProductos();
    return data.map((e) => Producto.fromMap(e)).toList();
  }

  Future<void> agregarProducto(Producto producto) async {
    await db.insertProducto(producto.toMap());
  }

  Future<void> eliminarProducto(int id) async {
    await db.deleteProducto(id);
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
}