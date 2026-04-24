import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database_helper.dart';

class ImportExportService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<String> compartirJsonCompleto() async {
    final contenido = await _crearContenidoJsonCompleto();
    final bytes = Uint8List.fromList(utf8.encode(contenido));
    final nombreArchivo =
        'mercadito_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final archivo = await _crearArchivoTemporal(nombreArchivo, bytes);

    await Share.shareXFiles([
      XFile(archivo.path, mimeType: 'application/json', name: nombreArchivo),
    ], text: 'Backup JSON de Mercadito');

    return archivo.path;
  }

  Future<String> importarJsonCompleto() async {
    final resultado = await FilePicker.platform.pickFiles(
      dialogTitle: 'Selecciona backup JSON',
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: false,
    );

    if (resultado == null || resultado.files.isEmpty) {
      throw Exception('Importacion cancelada por el usuario');
    }

    final archivo = resultado.files.single;
    final ruta = _obtenerRutaArchivoSeleccionado(archivo);

    if (ruta == null || ruta.isEmpty) {
      throw Exception('No se pudo obtener la ruta del archivo seleccionado');
    }

    final contenido = await File(ruta).readAsString();
    final dynamic data = jsonDecode(contenido);
    final tablas = _extraerTablasDesdeJson(data);

    await _db.reemplazarDatosDesdeJsonCompleto(tablas);

    return ruta;
  }

  Future<String> exportarJsonCompleto() async {
    final contenido = await _crearContenidoJsonCompleto();
    final bytes = Uint8List.fromList(utf8.encode(contenido));
    final nombreArchivo =
        'mercadito_backup_${DateTime.now().millisecondsSinceEpoch}.json';

    if (Platform.isAndroid || Platform.isIOS) {
      final rutaMovil = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar backup JSON como',
        fileName: nombreArchivo,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (rutaMovil == null || rutaMovil.isEmpty) {
        throw Exception('Exportacion cancelada por el usuario');
      }

      return rutaMovil;
    }

    final rutaArchivo = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar backup JSON como',
      fileName: nombreArchivo,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (rutaArchivo == null || rutaArchivo.isEmpty) {
      throw Exception('Exportacion cancelada por el usuario');
    }

    final archivo = await _guardarEnRuta(rutaArchivo, bytes);
    return archivo.path;
  }

  Future<String> _crearContenidoJsonCompleto() async {
    final tablas = await _db.obtenerDatosDeTodasLasTablas();
    final productos = tablas['productos'] ?? <Map<String, dynamic>>[];

    final payload = {
      'app': 'mercadito',
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'tables': {
        ...tablas,
        'productos': await _agregarQrBase64AProductos(productos),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<List<Map<String, dynamic>>> _agregarQrBase64AProductos(
    List<Map<String, dynamic>> productos,
  ) async {
    final salida = <Map<String, dynamic>>[];

    for (final producto in productos) {
      final copia = Map<String, dynamic>.from(producto);
      final codigoQr = copia['codigo_qr']?.toString() ?? '';

      if (codigoQr.isEmpty) {
        copia['qr_image_base64'] = null;
        salida.add(copia);
        continue;
      }

      final qrBytes = await _generarQrPng(codigoQr);
      copia['qr_image_base64'] = base64Encode(qrBytes);
      salida.add(copia);
    }

    return salida;
  }

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

  Future<File> _guardarEnRuta(String rutaArchivo, Uint8List bytes) async {
    final rutaNormalizada = _normalizarRutaArchivo(rutaArchivo);
    final rutaFinal = rutaNormalizada.toLowerCase().endsWith('.json')
        ? rutaNormalizada
        : '$rutaNormalizada.json';

    final rutaAbsoluta = p.normalize(rutaFinal);
    final archivo = File(rutaAbsoluta);

    final carpetaPadre = Directory(p.dirname(rutaAbsoluta));
    if (!await carpetaPadre.exists()) {
      await carpetaPadre.create(recursive: true);
    }

    await archivo.writeAsBytes(bytes, flush: true);

    final existe = await archivo.exists();
    final tamano = existe ? await archivo.length() : 0;

    if (!existe || tamano == 0) {
      throw FileSystemException(
        'El archivo no se guardo correctamente',
        rutaAbsoluta,
      );
    }

    return archivo;
  }

  Future<File> _crearArchivoTemporal(
    String nombreArchivo,
    Uint8List bytes,
  ) async {
    final directorio = await Directory.systemTemp.createTemp('mercadito_');
    final archivo = File(p.join(directorio.path, nombreArchivo));
    await archivo.writeAsBytes(bytes, flush: true);
    return archivo;
  }

  String _normalizarRutaArchivo(String rutaArchivo) {
    if (rutaArchivo.startsWith('file://')) {
      return Uri.parse(rutaArchivo).toFilePath();
    }
    return rutaArchivo;
  }

  String? _obtenerRutaArchivoSeleccionado(PlatformFile archivo) {
    if (archivo.path != null && archivo.path!.isNotEmpty) {
      return archivo.path;
    }

    if (archivo.bytes != null && archivo.bytes!.isNotEmpty) {
      final tempDir = Directory.systemTemp;
      final nombre = archivo.name.isEmpty
          ? 'import_backup_${DateTime.now().millisecondsSinceEpoch}.json'
          : archivo.name;
      final temporal = File(p.join(tempDir.path, nombre));
      temporal.writeAsBytesSync(archivo.bytes!, flush: true);
      return temporal.path;
    }

    return null;
  }

  Map<String, List<Map<String, dynamic>>> _extraerTablasDesdeJson(
    dynamic data,
  ) {
    if (data is Map<String, dynamic>) {
      final tables = data['tables'];

      if (tables is Map) {
        final salida = <String, List<Map<String, dynamic>>>{};

        tables.forEach((clave, valor) {
          if (clave is! String || valor is! List) return;

          final registros = <Map<String, dynamic>>[];
          for (final item in valor) {
            if (item is Map) {
              final fila = Map<String, dynamic>.from(item);
              fila.remove('qr_image_base64');
              registros.add(fila);
            }
          }

          salida[clave] = registros;
        });

        return salida;
      }
    }

    if (data is List) {
      final productos = <Map<String, dynamic>>[];

      for (final item in data) {
        if (item is Map) {
          final fila = Map<String, dynamic>.from(item);
          fila.remove('qr_image_base64');
          productos.add(fila);
        }
      }

      return {'productos': productos};
    }

    throw Exception('Formato JSON invalido para importacion');
  }
}
