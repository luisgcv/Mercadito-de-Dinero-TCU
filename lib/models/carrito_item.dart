import 'producto.dart';

/// Línea del carrito de compras: un [Producto] y la cantidad agregada.
///
/// Solo existe en memoria (no se guarda en la base de datos); la maneja
/// [CarritoService].
class CarritoItem {
  /// Producto agregado al carrito.
  final Producto producto;
  /// Unidades de [producto] en el carrito. Es mutable para poder sumar o
  /// restar unidades sin recrear el objeto.
  int cantidad;

  CarritoItem({
    required this.producto,
    this.cantidad = 1,
  });

  /// Precio unitario multiplicado por la cantidad.
  double get subtotal => producto.precio * cantidad;
}