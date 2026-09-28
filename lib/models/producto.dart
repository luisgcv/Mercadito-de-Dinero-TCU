
/// Modelo de un producto del mercadito.
///
/// Cada producto se guarda como una fila de la tabla `productos` en SQLite
/// (ver [DatabaseHelper]) y se identifica en el carrito mediante su
/// [codigoQr], que es el valor que se imprime en el código QR y se lee con
/// el escáner.
///
/// Es inmutable: para modificarlo se usa [copyWith].
class Producto {
  /// Identificador autoincremental de SQLite. Es `null` mientras el producto
  /// no se haya insertado en la base de datos.
  final int? id;
  /// Nombre visible del producto (ej. "Manzana").
  final String nombre;
  /// Precio unitario en colones (₡).
  final double precio;
  /// Texto único codificado en el QR del producto. Se genera al crear el
  /// producto con el formato `PROD_<milisegundos>` (ver [ProductoFormScreen]).
  /// En la base de datos tiene restricción `UNIQUE`.
  final String codigoQr;
  /// Ruta **relativa** de la imagen del producto dentro del directorio de
  /// documentos de la app (ej. `images/manzana_1716..._ab12cd34.jpg`).
  /// `null` si el producto no tiene imagen. Para obtener la ruta absoluta se
  /// usa [ImageStorageService.resolveAbsolutePath].
  final String? imagePath;

  Producto({
    this.id,
    required this.nombre,
    required this.precio,
    required this.codigoQr,
    this.imagePath,
  });

  /// Convierte el producto a un `Map` con los nombres de columna de SQLite
  /// (`codigo_qr`, `image_path`, ...). Se usa para insertar y actualizar.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'codigo_qr': codigoQr,
      'image_path': imagePath,
    };
  }

  /// Crea un producto a partir de una fila de SQLite (o de un JSON de
  /// respaldo). Es tolerante a valores faltantes: usa `''` o `0` por defecto.
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as int?,
      nombre: map['nombre']?.toString() ?? '',
      precio: (map['precio'] as num?)?.toDouble() ?? 0,
      codigoQr: map['codigo_qr']?.toString() ?? '',
      imagePath: map['image_path']?.toString(),
    );
  }

  /// Devuelve una copia del producto reemplazando solo los campos indicados.
  ///
  /// Como `imagePath: null` no se distingue de "no cambiar", para **quitar**
  /// la imagen se debe pasar `clearImagePath: true`.
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

  /// Indica si el producto tiene una ruta de imagen registrada. No verifica
  /// que el archivo exista físicamente (para eso ver
  /// [ProductoController.obtenerRutaImagenSiExiste]).
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
}