import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/import_export_controller.dart';
import '../controllers/producto_controller.dart';

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({super.key});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  Future<void> _exportarJson(BuildContext context) async {
    final controller = context.read<ImportExportController>();

    try {
      final ruta = await controller.exportarJsonCompleto();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Backup JSON creado en: $ruta')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al exportar JSON: $e')));
    }
  }

  Future<void> _compartirJson(BuildContext context) async {
    final controller = context.read<ImportExportController>();

    try {
      final ruta = await controller.compartirJsonCompleto();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se abrió el menú para compartir: $ruta')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al compartir JSON: $e')));
    }
  }

  Future<void> _importarJson(BuildContext context) async {
    final controller = context.read<ImportExportController>();

    try {
      final ruta = await controller.importarJsonCompleto();
      if (!mounted) return;

      await context.read<ProductoController>().cargarProductos();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup JSON importado desde: $ruta')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al importar JSON: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ImportExportController>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Importar / Exportar')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gestiona respaldos de la base de datos en JSON',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isLoading ? null : () => _importarJson(context),
              icon: const Icon(Icons.upload_file),
              label: const Text('Importar JSON'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: isLoading ? null : () => _exportarJson(context),
              icon: const Icon(Icons.download_for_offline),
              label: const Text('Exportar JSON'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: isLoading ? null : () => _compartirJson(context),
              icon: const Icon(Icons.share),
              label: const Text('Compartir JSON'),
            ),
            if (isLoading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
