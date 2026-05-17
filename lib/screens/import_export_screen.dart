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
  Future<void> _exportarZip(BuildContext context) async {
    final controller = context.read<ImportExportController>();

    try {
      final ruta = await controller.exportarZipCompleto();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup ZIP creado en: $ruta')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar ZIP: $e')),
      );
    }
  }

  Future<void> _compartirZip(BuildContext context) async {
    final controller = context.read<ImportExportController>();

    try {
      final ruta = await controller.compartirZipCompleto();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se abrió el menú para compartir ZIP: $ruta')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al compartir ZIP: $e')),
      );
    }
  }

  Future<void> _importarZip(BuildContext context) async {
    final controller = context.read<ImportExportController>();

    try {
      final ruta = await controller.importarZipCompleto();
      if (!mounted) return;

      await context.read<ProductoController>().cargarProductos();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup ZIP importado desde: $ruta')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al importar ZIP: $e')),
      );
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
              'Gestiona respaldos completos de la base de datos en ZIP',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isLoading ? null : () => _importarZip(context),
              icon: const Icon(Icons.archive),
              label: const Text('Importar ZIP completo'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: isLoading ? null : () => _exportarZip(context),
              icon: const Icon(Icons.save_alt),
              label: const Text('Exportar ZIP completo'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: isLoading ? null : () => _compartirZip(context),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Compartir ZIP completo'),
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
