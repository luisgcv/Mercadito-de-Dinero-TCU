import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../models/carrito_item.dart';
import '../services/carrito_service.dart';

class CarritoController extends ChangeNotifier {
  final CarritoService _service = CarritoService();

  List<CarritoItem> get items => _service.items;

  double get total => _service.total;

  void agregarProducto(Producto producto) {
    _service.agregarProducto(producto);
    notifyListeners();
  }

  void eliminarProducto(Producto producto) {
    _service.eliminarProducto(producto);
    notifyListeners();
  }

  void limpiar() {
    _service.limpiar();
    notifyListeners();
  }
}