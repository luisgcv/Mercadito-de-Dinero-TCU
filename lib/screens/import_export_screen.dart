import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({super.key});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  bool _isLoading = false;

  Future<void> _exportarJson() async {
    setState(() => _isLoading = true);

    try {
      final ruta = await DatabaseHelper.instance.exportarProductosJSON();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup JSON creado en: $ruta')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar JSON: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _exportarCompleto() async {
    setState(() => _isLoading = true);

    try {
      final ruta = await DatabaseHelper.instance.exportarRespaldoCompleto();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Respaldo completo creado en: $ruta')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar respaldo completo: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar / Exportar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Exporta los productos como JSON o genera un respaldo completo con el archivo y las imágenes QR en PNG.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _exportarJson,
              icon: const Icon(Icons.description),
              label: const Text('Exportar solo JSON'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _exportarCompleto,
              icon: const Icon(Icons.qr_code),
              label: const Text('Exportar todo con QR'),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
