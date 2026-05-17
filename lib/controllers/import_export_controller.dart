import 'package:flutter/material.dart';

import '../services/import_export_service.dart';

class ImportExportController extends ChangeNotifier {
  final ImportExportService _service = ImportExportService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
