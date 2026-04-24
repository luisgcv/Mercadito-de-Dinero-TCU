import 'package:flutter/material.dart';

import '../services/import_export_service.dart';

class ImportExportController extends ChangeNotifier {
  final ImportExportService _service = ImportExportService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String> importarJsonCompleto() async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _service.importarJsonCompleto();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> exportarJsonCompleto() async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _service.exportarJsonCompleto();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> compartirJsonCompleto() async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _service.compartirJsonCompleto();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
