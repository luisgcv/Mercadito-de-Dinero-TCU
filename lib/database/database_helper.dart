import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Acceso de bajo nivel a la base de datos SQLite local (`mercadito.db`).
///
/// Es un *singleton*: se usa siempre [DatabaseHelper.instance] para compartir
/// una única conexión. Trabaja con `Map<String, dynamic>` (filas crudas); la
/// conversión a [Producto] la hace [ProductoService].
///
/// ### Esquema actual (versión [_databaseVersion] = 2)
///
/// ```sql
/// CREATE TABLE productos(
///   id INTEGER PRIMARY KEY AUTOINCREMENT,
///   nombre TEXT NOT NULL,
///   precio REAL NOT NULL,
///   codigo_qr TEXT UNIQUE NOT NULL,
///   image_path TEXT
/// )
/// ```
///
/// ### Cómo modificar el esquema
///
/// 1. Incrementar [_databaseVersion].
/// 2. Agregar la tabla/columna nueva en [_createDB] (instalaciones nuevas).
/// 3. Agregar la migración en [_onUpgrade] con `if (oldVersion < N)`
///    (instalaciones existentes).
///
/// Las funciones de respaldo ZIP ([obtenerDatosDeTodasLasTablas] y
/// [reemplazarDatosDesdeJsonCompleto]) recorren **todas** las tablas de
/// usuario, por lo que una tabla nueva queda incluida automáticamente en los
/// respaldos.
class DatabaseHelper {
  /// Instancia única (singleton) del helper.
  static final DatabaseHelper instance = DatabaseHelper._init();

  /// Versión del esquema. Se debe incrementar cada vez que se cambie la
  /// estructura de las tablas (ver [_onUpgrade]).
  static const int _databaseVersion = 2;

  /// Conexión abierta; se crea de forma perezosa en el primer acceso.
  static Database? _database;

  DatabaseHelper._init();

  /// Devuelve la conexión a la base de datos, abriéndola (y creándola si
  /// no existe) la primera vez que se solicita.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mercadito.db');
    return _database!;
  }

  /// Abre el archivo [filePath] dentro del directorio de bases de datos del
  /// sistema y configura los callbacks de creación y migración.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crea las tablas cuando la base de datos no existía (instalación nueva).
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL,
        codigo_qr TEXT UNIQUE NOT NULL,
        image_path TEXT
      )
    ''');
  }

  /// Migra el esquema cuando la app se actualiza y [_databaseVersion] es
  /// mayor que la versión guardada en el dispositivo.
  ///
  /// - v1 → v2: se agregó la columna `image_path` a `productos`.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE productos ADD COLUMN image_path TEXT');
    }
  }

  // ---------------- CRUD PRODUCTOS ----------------

  /// Inserta un producto (en formato `Map`) y devuelve el `id` generado.
  /// Falla si el `codigo_qr` ya existe (restricción `UNIQUE`).
  Future<int> insertProducto(Map<String, dynamic> producto) async {
    final db = await instance.database;
    return await db.insert('productos', producto);
  }

  /// Devuelve todas las filas de la tabla `productos`.
  Future<List<Map<String, dynamic>>> getProductos() async {
    final db = await instance.database;
    return await db.query('productos');
  }

  /// Busca el producto cuyo `codigo_qr` coincide exactamente con [qr].
  /// Devuelve `null` si no existe. Lo usa el escáner del carrito.
  Future<Map<String, dynamic>?> getProductoByQR(String qr) async {
    final db = await instance.database;

    final result = await db.query(
      'productos',
      where: 'codigo_qr = ?',
      whereArgs: [qr],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  /// Busca productos cuyo nombre **contenga** [nombre] (`LIKE %nombre%`).
  Future<List<Map<String, dynamic>>> buscarPorNombre(String nombre) async {
    final db = await instance.database;

    return await db.query(
      'productos',
      where: 'nombre LIKE ?',
      whereArgs: ['%$nombre%'],
    );
  }

  /// Actualiza la fila cuyo `id` coincide con `producto['id']`.
  /// Devuelve la cantidad de filas modificadas.
  Future<int> updateProducto(Map<String, dynamic> producto) async {
    final db = await instance.database;

    return await db.update(
      'productos',
      producto,
      where: 'id = ?',
      whereArgs: [producto['id']],
    );
  }

  /// Elimina el producto con el [id] indicado.
  Future<int> deleteProducto(int id) async {
    final db = await instance.database;

    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  /// Elimina todas las filas de `productos` (no borra las imágenes; eso lo
  /// hace [ProductoService.eliminarTodosLosProductos]).
  Future<int> deleteAllProductos() async {
    final db = await instance.database;

    return await db.delete('productos');
  }

  /// Lista los nombres de todas las tablas creadas por la app, excluyendo
  /// las tablas internas de SQLite (`sqlite_*`).
  Future<List<String>> obtenerNombresTablasUsuario() async {
    final db = await instance.database;

    final tablas = await db.rawQuery('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name NOT LIKE 'sqlite_%'
    ''');

    return tablas
        .map((fila) => fila['name'])
        .whereType<String>()
        .toList(growable: false);
  }

  /// Devuelve el contenido completo de la base de datos como
  /// `{nombreTabla: [filas...]}`. Es la fuente de datos del respaldo ZIP
  /// (ver [ImportExportService]).
  Future<Map<String, List<Map<String, dynamic>>>>
  obtenerDatosDeTodasLasTablas() async {
    final db = await instance.database;
    final nombresTablas = await obtenerNombresTablasUsuario();
    final datos = <String, List<Map<String, dynamic>>>{};

    for (final tabla in nombresTablas) {
      final registros = await db.query(tabla);
      datos[tabla] = registros;
    }

    return datos;
  }

  /// Reemplaza **todo** el contenido de la base de datos por [tablas]
  /// (mismo formato que [obtenerDatosDeTodasLasTablas]).
  ///
  /// Se ejecuta en una transacción: primero vacía cada tabla existente y
  /// luego inserta los registros recibidos. Las tablas del JSON que no
  /// existan en la base de datos actual se ignoran.
  Future<void> reemplazarDatosDesdeJsonCompleto(
    Map<String, List<Map<String, dynamic>>> tablas,
  ) async {
    final db = await instance.database;
    final nombresTablasActuales = await obtenerNombresTablasUsuario();

    await db.transaction((txn) async {
      for (final tabla in nombresTablasActuales) {
        await txn.delete(tabla);
      }

      for (final tabla in nombresTablasActuales) {
        final registros = tablas[tabla] ?? const <Map<String, dynamic>>[];

        for (final registro in registros) {
          await txn.insert(
            tabla,
            registro,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  // ---------------- RESPALDO JSON (LEGADO) ----------------
  //
  // NOTA: los métodos de esta sección son la primera versión del respaldo
  // (solo JSON / carpeta con QRs). Actualmente la interfaz NO los usa: el
  // respaldo vigente es el ZIP de [ImportExportService]. Se conservan como
  // referencia; si se decide no usarlos, pueden eliminarse.

  /// Carpeta donde se guardan los respaldos JSON legados: el directorio de
  /// documentos de la app.
  Future<Directory> _obtenerDirectorioRespaldo() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir;
  }

  /// **(Legado, sin uso en la UI)** Exporta los productos a JSON:
  ///
  /// 1. Lee todos los productos de SQLite.
  /// 2. Los convierte a JSON.
  /// 3. Guarda `productos_backup.json` en el directorio de documentos.
  /// 4. Retorna la ruta del archivo generado.
  Future<String> exportarProductosJSON() async {
    try {
      final productos = await getProductos();
      final contenidoJson = jsonEncode(productos);

      final directorio = await _obtenerDirectorioRespaldo();
      final rutaArchivo = join(directorio.path, 'productos_backup.json');
      final archivo = File(rutaArchivo);

      await archivo.writeAsString(contenidoJson, flush: true);
      return rutaArchivo;
    } catch (e) {
      throw Exception('Error al exportar productos a JSON: $e');
    }
  }

  /// **(Legado, sin uso en la UI)** Crea una carpeta
  /// `mercadito_export_<timestamp>` en documentos con:
  ///
  /// - `productos.json`: todos los productos.
  /// - Un PNG con el código QR de cada producto.
  /// - `manifest.json`: relación producto ↔ imagen QR.
  ///
  /// Retorna la ruta de la carpeta creada.
  Future<String> exportarRespaldoCompleto() async {
    try {
      final productos = await getProductos();
      final directorioBase = await _obtenerDirectorioRespaldo();
      final nombreCarpeta =
          'mercadito_export_${DateTime.now().millisecondsSinceEpoch}';
      final directorioExportacion = Directory(
        join(directorioBase.path, nombreCarpeta),
      );

      if (!await directorioExportacion.exists()) {
        await directorioExportacion.create(recursive: true);
      }

      final archivoJson = File(
        join(directorioExportacion.path, 'productos.json'),
      );
      await archivoJson.writeAsString(jsonEncode(productos), flush: true);

      final manifest = <Map<String, dynamic>>[];

      for (final producto in productos) {
        final codigoQr = producto['codigo_qr']?.toString() ?? '';
        final nombreProducto = producto['nombre']?.toString() ?? 'producto';
        final idProducto = producto['id']?.toString() ?? 'sin_id';
        final nombreArchivo =
            '${idProducto}_${_limpiarNombreArchivo(nombreProducto)}.png';

        final qrBytes = await _generarQrPng(codigoQr);
        final archivoQr = File(join(directorioExportacion.path, nombreArchivo));
        await archivoQr.writeAsBytes(qrBytes, flush: true);

        manifest.add({
          'id': producto['id'],
          'nombre': nombreProducto,
          'precio': producto['precio'],
          'codigo_qr': codigoQr,
          'qr_image': nombreArchivo,
        });
      }

      final archivoManifest = File(
        join(directorioExportacion.path, 'manifest.json'),
      );
      await archivoManifest.writeAsString(jsonEncode(manifest), flush: true);

      return directorioExportacion.path;
    } catch (e) {
      throw Exception('Error al exportar respaldo completo: $e');
    }
  }

  /// Genera un PNG de 1024×1024 con el código QR de [data].
  Future<Uint8List> _generarQrPng(String data) async {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
      color: Colors.black,
      emptyColor: Colors.white,
    );

    final byteData = await painter.toImageData(
      1024,
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception('No se pudo generar la imagen QR');
    }

    return byteData.buffer.asUint8List();
  }

  /// Convierte [input] en un nombre de archivo seguro: sin caracteres
  /// inválidos, espacios reemplazados por `_` y en minúsculas.
  String _limpiarNombreArchivo(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  /// **(Legado, sin uso en la UI)** Importa productos desde un JSON:
  ///
  /// 1. Lee el archivo JSON desde [rutaArchivo].
  /// 2. Valida que el contenido sea una lista de productos.
  /// 3. Inserta/actualiza en SQLite usando `ConflictAlgorithm.replace`
  ///    para evitar duplicados.
  Future<void> importarProductosJSON(String rutaArchivo) async {
    try {
      final archivo = File(rutaArchivo);
      if (!await archivo.exists()) {
        throw Exception('El archivo no existe: $rutaArchivo');
      }

      final contenido = await archivo.readAsString();
      final data = jsonDecode(contenido);

      if (data is! List) {
        throw Exception(
          'Formato JSON invalido: se esperaba una lista de productos',
        );
      }

      final db = await instance.database;

      await db.transaction((txn) async {
        for (final item in data) {
          if (item is! Map<String, dynamic>) {
            if (item is Map) {
              await txn.insert(
                'productos',
                Map<String, dynamic>.from(item),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            continue;
          }

          await txn.insert(
            'productos',
            item,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (e) {
      throw Exception('Error al importar productos desde JSON: $e');
    }
  }
}
