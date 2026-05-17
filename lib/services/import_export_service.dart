import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../database/database_helper.dart';
import 'image_storage_service.dart';

class ImportExportService {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final ImageStorageService _imageStorage = ImageStorageService();

  Future<String> exportarZipCompleto() async {
    final archivoZip = await _crearArchivoZipTemporal();
    final nombreArchivo =
        'mercadito_backup_${DateTime.now().millisecondsSinceEpoch}.zip';
    final bytes = await archivoZip.readAsBytes();

    if (Platform.isAndroid || Platform.isIOS) {
      final rutaMovil = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar backup ZIP como',
        fileName: nombreArchivo,
        type: FileType.custom,
        allowedExtensions: ['zip'],
        bytes: bytes,
      );

      if (rutaMovil == null || rutaMovil.isEmpty) {
        throw Exception('Exportacion cancelada por el usuario');
      }

      return rutaMovil;
    }

    final rutaArchivo = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar backup ZIP como',
      fileName: nombreArchivo,
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (rutaArchivo == null || rutaArchivo.isEmpty) {
      throw Exception('Exportacion cancelada por el usuario');
    }

    final archivo = await _guardarArchivoEnRuta(
      rutaArchivo,
      bytes,
      extension: '.zip',
    );
    return archivo.path;
  }

  Future<String> compartirZipCompleto() async {
    final archivoZip = await _crearArchivoZipTemporal();

    await Share.shareXFiles([
      XFile(
        archivoZip.path,
        mimeType: 'application/zip',
        name: p.basename(archivoZip.path),
      ),
    ], text: 'Backup ZIP de Mercadito');

    return archivoZip.path;
  }

  Future<String> importarZipCompleto() async {
    final resultado = await FilePicker.platform.pickFiles(
      dialogTitle: 'Selecciona backup ZIP',
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withData: false,
    );

    if (resultado == null || resultado.files.isEmpty) {
      throw Exception('Importacion cancelada por el usuario');
    }

    final archivoSeleccionado = resultado.files.single;
    final rutaZip = _obtenerRutaArchivoSeleccionado(archivoSeleccionado);

    if (rutaZip == null || rutaZip.isEmpty) {
      throw Exception('No se pudo obtener la ruta del archivo ZIP seleccionado');
    }

    final contenidoZip = await File(rutaZip).readAsBytes();
    final archive = ZipDecoder().decodeBytes(contenidoZip, verify: true);
    final directorioTemporal =
        await Directory.systemTemp.createTemp('mercadito_zip_import_');

    try {
      _extraerArchivoZip(archive, directorioTemporal);

      final backupJsonFile = File(p.join(directorioTemporal.path, 'backup.json'));
      if (!await backupJsonFile.exists()) {
        throw Exception('El ZIP no contiene backup.json');
      }

      final contenido = await backupJsonFile.readAsString();
      final dynamic data = jsonDecode(contenido);
      final tablas = _extraerTablasDesdeJson(data);
      final imagenesParaCopiar = _obtenerReferenciasImagenesDesdeTablas(tablas)
          .map(_imageStorage.normalizeRelativePath)
          .toSet()
          .toList();

      for (final relativa in imagenesParaCopiar) {
        final archivoTemporal = File(p.join(directorioTemporal.path, relativa));
        if (!await archivoTemporal.exists()) {
          throw Exception('Falta la imagen requerida en el ZIP: $relativa');
        }
      }

      final respaldoActual = await _db.obtenerDatosDeTodasLasTablas();
      final copiados = <String>[];

      try {
        for (final relativa in imagenesParaCopiar) {
          final archivoTemporal = File(p.join(directorioTemporal.path, relativa));

          await _imageStorage.copyFileToRelativePath(
            sourcePath: archivoTemporal.path,
            relativePath: relativa,
            overwrite: true,
          );

          copiados.add(relativa);
        }

        await _db.reemplazarDatosDesdeJsonCompleto(tablas);
      } catch (e) {
        await _db.reemplazarDatosDesdeJsonCompleto(respaldoActual);

        for (final relativa in copiados) {
          try {
            await _imageStorage.deleteImage(relativa);
          } catch (_) {}
        }

        rethrow;
      }

      return rutaZip;
    } finally {
      try {
        await directorioTemporal.delete(recursive: true);
      } catch (_) {}
    }
  }

  Future<String> _crearContenidoBackupZip() async {
    final tablas = await _db.obtenerDatosDeTodasLasTablas();

    final payload = {
      'app': 'mercadito',
      'version': 2,
      'exported_at': DateTime.now().toIso8601String(),
      'tables': tablas,
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<File> _crearArchivoZipTemporal() async {
    final directorio = await Directory.systemTemp.createTemp('mercadito_zip_');
    final contenidoJson = await _crearContenidoBackupZip();
    final archive = Archive();

    archive.addFile(ArchiveFile.string('backup.json', contenidoJson));

    final tablas = await _db.obtenerDatosDeTodasLasTablas();
    final referencias = _obtenerReferenciasImagenesDesdeTablas(tablas).toSet();

    for (final referencia in referencias) {
      final relativa = _imageStorage.normalizeRelativePath(referencia);
      final absolutePath = await _imageStorage.resolveAbsolutePath(relativa);
      final file = File(absolutePath);

      if (!await file.exists()) {
        continue;
      }

      final bytes = await file.readAsBytes();
      archive.addFile(ArchiveFile(relativa, bytes.length, bytes));
    }

    final encoded = ZipEncoder().encode(archive);
    if (encoded == null) {
      throw Exception('No se pudo generar el archivo ZIP');
    }

    final archivoZip = File(p.join(directorio.path, 'backup.zip'));
    await archivoZip.writeAsBytes(Uint8List.fromList(encoded), flush: true);
    return archivoZip;
  }

  Future<File> _guardarArchivoEnRuta(
    String rutaArchivo,
    Uint8List bytes, {
    String extension = '.zip',
  }) async {
    final rutaNormalizada = _normalizarRutaArchivo(rutaArchivo);
    final rutaFinal = rutaNormalizada.toLowerCase().endsWith(extension)
        ? rutaNormalizada
        : '$rutaNormalizada$extension';

    final rutaAbsoluta = p.normalize(rutaFinal);
    final archivo = File(rutaAbsoluta);

    final carpetaPadre = Directory(p.dirname(rutaAbsoluta));
    if (!await carpetaPadre.exists()) {
      await carpetaPadre.create(recursive: true);
    }

    await archivo.writeAsBytes(bytes, flush: true);

    if (!await archivo.exists() || await archivo.length() == 0) {
      throw FileSystemException(
        'El archivo no se guardo correctamente',
        rutaAbsoluta,
      );
    }

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
          ? 'import_backup_${DateTime.now().millisecondsSinceEpoch}.zip'
          : archivo.name;
      final temporal = File(p.join(tempDir.path, nombre));
      temporal.writeAsBytesSync(archivo.bytes!, flush: true);
      return temporal.path;
    }

    return null;
  }

  Iterable<String> _obtenerReferenciasImagenesDesdeTablas(
    Map<String, List<Map<String, dynamic>>> tablas,
  ) sync* {
    for (final registros in tablas.values) {
      for (final registro in registros) {
        final referencia = registro['image_path']?.toString();
        if (referencia != null && referencia.isNotEmpty) {
          yield referencia;
        }
      }
    }
  }

  void _extraerArchivoZip(Archive archive, Directory destino) {
    for (final entry in archive) {
      final nombre = p.normalize(entry.name);
      final salida = p.join(destino.path, nombre);

      if (entry.isFile) {
        final archivo = File(salida);
        archivo.parent.createSync(recursive: true);
        archivo.writeAsBytesSync(entry.content as List<int>, flush: true);
      } else {
        Directory(salida).createSync(recursive: true);
      }
    }
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
