import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Singleton (una sola instancia de la DB)
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // Obtener la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mercadito.db');
    return _database!;
  }

  // Inicializar DB
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Crear tablas
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL,
        codigo_qr TEXT UNIQUE NOT NULL
      )
    ''');
  }

  // ---------------- CRUD PRODUCTOS ----------------

  // INSERTAR producto
  Future<int> insertProducto(Map<String, dynamic> producto) async {
    final db = await instance.database;
    return await db.insert('productos', producto);
  }

  // OBTENER todos los productos
  Future<List<Map<String, dynamic>>> getProductos() async {
    final db = await instance.database;
    return await db.query('productos');
  }

  // BUSCAR por QR
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

  // BUSCAR por nombre
  Future<List<Map<String, dynamic>>> buscarPorNombre(String nombre) async {
    final db = await instance.database;

    return await db.query(
      'productos',
      where: 'nombre LIKE ?',
      whereArgs: ['%$nombre%'],
    );
  }

  // ACTUALIZAR producto
  Future<int> updateProducto(Map<String, dynamic> producto) async {
    final db = await instance.database;

    return await db.update(
      'productos',
      producto,
      where: 'id = ?',
      whereArgs: [producto['id']],
    );
  }

  // ELIMINAR producto
  Future<int> deleteProducto(int id) async {
    final db = await instance.database;

    return await db.delete(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------- RESPALDO JSON ----------------

  // Obtiene una carpeta local para guardar archivos JSON.
  // Intenta usar Descargas y, si no existe, usa Documentos de la app.
  Future<Directory> _obtenerDirectorioRespaldo() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir;
  }

  // EXPORTAR A JSON:
  // 1) Lee todos los productos de SQLite.
  // 2) Los convierte a JSON.
  // 3) Guarda el archivo en almacenamiento local.
  // 4) Retorna la ruta del archivo generado.
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

  // IMPORTAR DESDE JSON:
  // 1) Lee el archivo JSON desde la ruta indicada.
  // 2) Convierte el contenido a lista de productos.
  // 3) Inserta/actualiza en SQLite evitando duplicados con replace.
  Future<void> importarProductosJSON(String rutaArchivo) async {
    try {
      final archivo = File(rutaArchivo);
      if (!await archivo.exists()) {
        throw Exception('El archivo no existe: $rutaArchivo');
      }

      final contenido = await archivo.readAsString();
      final data = jsonDecode(contenido);

      if (data is! List) {
        throw Exception('Formato JSON invalido: se esperaba una lista de productos');
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