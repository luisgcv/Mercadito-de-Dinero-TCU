import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Administra los archivos de imagen de los productos.
///
/// Las imágenes se copian al directorio `images/` dentro del directorio de
/// documentos de la app, y en la base de datos se guarda solo la **ruta
/// relativa** (ej. `images/manzana_PROD_1_1716..._ab12cd34.jpg`). Guardar
/// rutas relativas permite que los respaldos ZIP funcionen entre
/// dispositivos distintos, cuyo directorio de documentos es diferente.
///
/// Es un *singleton*: `ImageStorageService()` siempre devuelve la misma
/// instancia.
class ImageStorageService {
  /// Instancia única del servicio.
  static final ImageStorageService instance = ImageStorageService._internal();

  /// Devuelve siempre [instance].
  factory ImageStorageService() => instance;

  ImageStorageService._internal();

  /// Nombre de la carpeta de imágenes dentro de los documentos de la app.
  static const String _imagesFolderName = 'images';
  final Random _random = Random.secure();

  /// Devuelve la carpeta de imágenes, creándola si todavía no existe.
  Future<Directory> createImagesDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final imagesDirectory = Directory(
      p.join(documentsDirectory.path, _imagesFolderName),
    );

    if (!await imagesDirectory.exists()) {
      await imagesDirectory.create(recursive: true);
    }

    return imagesDirectory;
  }

  /// Genera un nombre de archivo único con el formato
  /// `<baseName>_<timestamp>_<aleatorio>.<ext>`.
  ///
  /// Si no se indica [extension] se usa `.jpg`.
  String generateUniqueFileName({
    String? baseName,
    String? extension,
  }) {
    final cleanBase = _sanitizeBaseName(baseName ?? 'image');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = _random.nextInt(1 << 32).toRadixString(16).padLeft(8, '0');
    final cleanExtension = _normalizeExtension(extension);

    return cleanBase + '_' + timestamp.toString() + '_' + randomPart + cleanExtension;
  }

  /// Copia la imagen ubicada en [sourcePath] a la carpeta de imágenes con un
  /// nombre único y devuelve su **ruta relativa** (lo que se guarda en BD).
  ///
  /// Lanza [FileSystemException] si el archivo de origen no existe.
  Future<String> saveImageFromPath(
    String sourcePath, {
    String? baseName,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException('La imagen de origen no existe', sourcePath);
    }

    final imagesDirectory = await createImagesDirectory();
    final uniqueFileName = generateUniqueFileName(
      baseName: baseName,
      extension: p.extension(sourceFile.path),
    );
    final destinationFile = File(p.join(imagesDirectory.path, uniqueFileName));

    await sourceFile.copy(destinationFile.path);

    return p.posix.join(_imagesFolderName, uniqueFileName);
  }

  /// Copia [sourcePath] exactamente a [relativePath] (normalizada a
  /// `images/<archivo>`), sobrescribiendo si [overwrite] es `true`.
  ///
  /// Se usa al importar un respaldo ZIP para restaurar cada imagen con el
  /// mismo nombre que tenía en el dispositivo de origen.
  Future<String> copyFileToRelativePath({
    required String sourcePath,
    required String relativePath,
    bool overwrite = true,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException('La imagen de origen no existe', sourcePath);
    }

    final normalizedRelativePath = normalizeRelativePath(relativePath);
    final absolutePath = await resolveAbsolutePath(normalizedRelativePath);
    final destinationFile = File(absolutePath);

    final parent = destinationFile.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }

    if (overwrite && await destinationFile.exists()) {
      await destinationFile.delete();
    }

    await sourceFile.copy(destinationFile.path);
    return normalizedRelativePath;
  }

  /// Guarda una imagen nueva y, si se indica [previousRelativePath], borra
  /// la anterior. Devuelve la ruta relativa de la imagen nueva.
  Future<String> replaceImageFromPath({
    required String sourcePath,
    String? previousRelativePath,
    String? baseName,
  }) async {
    final newRelativePath = await saveImageFromPath(
      sourcePath,
      baseName: baseName,
    );

    if (previousRelativePath != null && previousRelativePath.isNotEmpty) {
      await deleteImage(previousRelativePath);
    }

    return newRelativePath;
  }

  /// Borra la imagen en [relativePath]. Devuelve `false` si la ruta está
  /// vacía o el archivo no existe.
  Future<bool> deleteImage(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) {
      return false;
    }

    final absolutePath = await resolveAbsolutePath(relativePath);
    final file = File(absolutePath);

    if (!await file.exists()) {
      return false;
    }

    await file.delete();
    return true;
  }

  /// Indica si el archivo de imagen existe en el dispositivo.
  Future<bool> exists(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) {
      return false;
    }

    final absolutePath = await resolveAbsolutePath(relativePath);
    return File(absolutePath).exists();
  }

  /// Convierte una ruta relativa (`images/...`) en absoluta, usando el
  /// directorio de documentos de la app. Si ya es absoluta, solo la
  /// normaliza.
  Future<String> resolveAbsolutePath(String relativePath) async {
    if (p.isAbsolute(relativePath)) {
      return p.normalize(relativePath);
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    return p.normalize(p.join(documentsDirectory.path, relativePath));
  }

  /// Normaliza cualquier ruta al formato `images/<nombreArchivo>` con `/`
  /// como separador. Útil para rutas que vienen de otro sistema operativo o
  /// de versiones anteriores que guardaban rutas absolutas.
  String normalizeRelativePath(String path) {
    if (path.isEmpty) {
      return path;
    }

    final normalized = path.replaceAll('\\', '/');

    if (normalized.startsWith('$_imagesFolderName/')) {
      return normalized;
    }

    if (p.isAbsolute(normalized)) {
      return p.posix.join(_imagesFolderName, p.basename(normalized));
    }

    return p.posix.join(_imagesFolderName, p.basename(normalized));
  }

  /// Limpia [input] para usarlo en un nombre de archivo (sin caracteres
  /// inválidos ni espacios, en minúsculas).
  String _sanitizeBaseName(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  /// Asegura que la extensión empiece con `.` y esté en minúsculas
  /// (`.jpg` por defecto).
  String _normalizeExtension(String? extension) {
    if (extension == null || extension.trim().isEmpty) {
      return '.jpg';
    }

    final clean = extension.trim().toLowerCase();
    return clean.startsWith('.') ? clean : '.$clean';
  }
}