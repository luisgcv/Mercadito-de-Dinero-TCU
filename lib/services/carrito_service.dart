import '../models/producto.dart';
import '../models/carrito_item.dart';

class CarritoService {
  final List<CarritoItem> _items = [];

  List<CarritoItem> get items => _items;

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

  double get total {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  void limpiar() {
    _items.clear();
  }
}