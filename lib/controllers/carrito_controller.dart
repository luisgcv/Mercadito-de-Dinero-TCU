import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../models/carrito_item.dart';
import '../services/carrito_service.dart';

/// Controlador (estado observable) del carrito de compras.
///
/// Envuelve a [CarritoService] y llama a `notifyListeners()` después de cada
/// cambio para que las pantallas que lo escuchan (por ejemplo con
/// `Consumer<CarritoController>` en [CarritoScreen]) se redibujen.
///
/// El carrito vive solo en memoria: se pierde al cerrar la app.
class CarritoController extends ChangeNotifier {
  final CarritoService _service = CarritoService();

  /// Líneas actuales del carrito.
  List<CarritoItem> get items => _service.items;

  /// Suma de los subtotales de todas las líneas.
  double get total => _service.total;

  /// Agrega una unidad de [producto]; si ya estaba en el carrito, suma 1 a
  /// su cantidad.
  void agregarProducto(Producto producto) {
    _service.agregarProducto(producto);
    notifyListeners();
  }

  /// Quita una unidad de [producto] (si queda en 0, elimina la línea).
  /// Lo usa el botón de basurero del carrito.
  void eliminarProducto(Producto producto) {
    _service.eliminarProducto(producto);
    notifyListeners();
  }

  /// Suma una unidad a un producto que ya está en el carrito (botón `+`).
  void incrementarCantidad(Producto producto) {
    _service.incrementarCantidad(producto);
    notifyListeners();
  }

  /// Resta una unidad a un producto del carrito (botón `-`). Si la cantidad
  /// llega a 0, la línea se elimina.
  void decrementarCantidad(Producto producto) {
    _service.decrementarCantidad(producto);
    notifyListeners();
  }

  /// Vacía el carrito por completo ("Vaciar carrito" / "Nuevo cliente").
  void limpiar() {
    _service.limpiar();
    notifyListeners();
  }
}