import 'package:flutter/material.dart';

import '../services/import_export_service.dart';

/// Controlador de la pantalla de respaldos ([ImportExportScreen]).
///
/// Delega el trabajo a [ImportExportService] y expone [isLoading] para que la
/// interfaz deshabilite los botones y muestre un indicador de progreso
/// mientras se realiza una operación.
///
/// Los métodos lanzan excepción si el usuario cancela o si ocurre un error;
/// la pantalla se encarga de capturarla y mostrar el mensaje.
class ImportExportController extends ChangeNotifier {
  final ImportExportService _service = ImportExportService();

  /// `true` mientras hay una exportación, importación o compartido en curso.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Genera el respaldo ZIP y pide al usuario dónde guardarlo.
  /// Devuelve la ruta del archivo guardado.
  Future<String> exportarZipCompleto() async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _service.exportarZipCompleto();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Genera el respaldo ZIP y abre el menú nativo de "Compartir"
  /// (WhatsApp, correo, Drive, etc.). Devuelve la ruta del ZIP temporal.
  Future<String> compartirZipCompleto() async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _service.compartirZipCompleto();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pide al usuario un archivo ZIP y **reemplaza** la base de datos y las
  /// imágenes con su contenido. Devuelve la ruta del ZIP importado.
  ///
  /// Después de llamar a este método se debe recargar
  /// [ProductoController.cargarProductos] para refrescar la lista.
  Future<String> importarZipCompleto() async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _service.importarZipCompleto();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
