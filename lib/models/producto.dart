
class Producto {
  final int? id;
  final String nombre;
  final double precio;
  final String codigoQr;
  final String? imagePath;

  Producto({
    this.id,
    required this.nombre,
    required this.precio,
    required this.codigoQr,
    this.imagePath,
  });

  // Convertir a Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'codigo_qr': codigoQr,
      'image_path': imagePath,
    };
  }

  // Crear desde Map (desde SQLite)
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as int?,
      nombre: map['nombre']?.toString() ?? '',
      precio: (map['precio'] as num?)?.toDouble() ?? 0,
      codigoQr: map['codigo_qr']?.toString() ?? '',
      imagePath: map['image_path']?.toString(),
    );
  }

  Producto copyWith({
    int? id,
    String? nombre,
    double? precio,
    String? codigoQr,
    String? imagePath,
    bool clearImagePath = false,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      codigoQr: codigoQr ?? this.codigoQr,
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
    );
  }

  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
}