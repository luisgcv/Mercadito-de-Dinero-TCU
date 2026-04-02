
class Producto {
  final int? id;
  final String nombre;
  final double precio;
  final String codigoQr;

  Producto({
    this.id,
    required this.nombre,
    required this.precio,
    required this.codigoQr,
  });

  // Convertir a Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'codigo_qr': codigoQr,
    };
  }

  // Crear desde Map (desde SQLite)
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      nombre: map['nombre'],
      precio: map['precio'],
      codigoQr: map['codigo_qr'],
    );
  }
}