import '../models/producto.dart';
import '../models/carrito_item.dart';

/// Lógica del carrito de compras (sin dependencias de Flutter).
///
/// Guarda las líneas en una lista en memoria. Un producto se identifica por
/// su `id` **y** su `codigoQr`; si se agrega dos veces el mismo producto se
/// incrementa la cantidad en lugar de crear otra línea.
///
/// No notifica cambios: eso lo hace [CarritoController].
class CarritoService {
  final List<CarritoItem> _items = [];

  /// Líneas actuales del carrito (la lista interna, no una copia).
  List<CarritoItem> get items => _items;

  /// Agrega [producto] con cantidad 1, o suma 1 si ya estaba en el carrito.
  void agregarProducto(Producto producto) {
    final index = _items.indexWhere(
      (item) => item.producto.id == producto.id && item.producto.codigoQr == producto.codigoQr,
    );

    if (index == -1) {
      _items.add(CarritoItem(producto: producto));
    } else {
      _items[index].cantidad += 1;
    }
  }

  /// Quita **una unidad** de [producto]; si solo quedaba una, elimina la
  /// línea. (Hoy se comporta igual que [decrementarCantidad].)
  void eliminarProducto(Producto producto) {
    final index = _items.indexWhere(
      (item) => item.producto.id == producto.id && item.producto.codigoQr == producto.codigoQr,
    );

    if (index == -1) return;

    if (_items[index].cantidad > 1) {
      _items[index].cantidad -= 1;
    } else {
      _items.removeAt(index);
    }
  }

  /// Suma 1 a la cantidad de [producto] si ya está en el carrito.
  void incrementarCantidad(Producto producto) {
    final index = _items.indexWhere(
      (item) => item.producto.id == producto.id && item.producto.codigoQr == producto.codigoQr,
    );

    if (index != -1) {
      _items[index].cantidad += 1;
    }
  }

  /// Resta 1 a la cantidad de [producto]; si llega a 0, elimina la línea.
  void decrementarCantidad(Producto producto) {
    final index = _items.indexWhere(
      (item) => item.producto.id == producto.id && item.producto.codigoQr == producto.codigoQr,
    );

    if (index == -1) return;

    if (_items[index].cantidad > 1) {
      _items[index].cantidad -= 1;
    } else {
      _items.removeAt(index);
    }
  }

  /// Total a pagar: suma de los subtotales de todas las líneas.
  double get total {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  /// Elimina todas las líneas del carrito.
  void limpiar() {
    _items.clear();
  }
}