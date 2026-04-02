import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

class ProductoController extends ChangeNotifier {
  final ProductoService _service = ProductoService();

  List<Producto> productos = [];

  Future<void> cargarProductos() async {
    productos = await _service.obtenerProductos();
    notifyListeners();
  }

  Future<void> agregarProducto(Producto producto) async {
    await _service.agregarProducto(producto);
    await cargarProductos();
  }

  Future<void> eliminarProducto(int id) async {
    await _service.eliminarProducto(id);
    await cargarProductos();
  }

  Future<Producto?> buscarPorQR(String qr) async {
    return _service.buscarPorQR(qr);
  }

  Future<List<Producto>> buscarPorNombre(String nombre) async {
    return _service.buscarPorNombre(nombre);
  }
}

