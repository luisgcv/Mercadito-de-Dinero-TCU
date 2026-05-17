import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  static final ImageStorageService instance = ImageStorageService._internal();

  factory ImageStorageService() => instance;

  ImageStorageService._internal();

  static const String _imagesFolderName = 'images';
  final Random _random = Random.secure();

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

  Future<bool> exists(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) {
      return false;
    }

    final absolutePath = await resolveAbsolutePath(relativePath);
    return File(absolutePath).exists();
  }

  Future<String> resolveAbsolutePath(String relativePath) async {
    if (p.isAbsolute(relativePath)) {
      return p.normalize(relativePath);
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    return p.normalize(p.join(documentsDirectory.path, relativePath));
  }

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

  String _sanitizeBaseName(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  String _normalizeExtension(String? extension) {
    if (extension == null || extension.trim().isEmpty) {
      return '.jpg';
    }

    final clean = extension.trim().toLowerCase();
    return clean.startsWith('.') ? clean : '.$clean';
  }
}