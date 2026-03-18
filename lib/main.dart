import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prueba JSON SQLite',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> productos = [];
  String? ultimaRutaExportada;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final data = await DatabaseHelper.instance.getProductos();
    setState(() {
      productos = data;
    });
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _agregarProducto() async {
    try {
      await DatabaseHelper.instance.insertProducto({
        'nombre': 'Producto ${DateTime.now().millisecond}',
        'precio': (100 + DateTime.now().second).toDouble(),
        'codigo_qr': 'QR_${DateTime.now().millisecondsSinceEpoch}',
      });
      await _cargarProductos();
      _mostrarMensaje('Producto agregado');
    } catch (e) {
      _mostrarMensaje('Error al agregar: $e', esError: true);
    }
  }

  Future<void> _exportar() async {
    try {
      final ruta = await DatabaseHelper.instance.exportarProductosJSON();
      setState(() {
        ultimaRutaExportada = ruta;
      });
      _mostrarMensaje('Exportado en: $ruta');
    } catch (e) {
      _mostrarMensaje('Error al exportar: $e', esError: true);
    }
  }




 
  Future<void> _importar() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (resultado == null || resultado.files.isEmpty) {
        _mostrarMensaje('Importación cancelada');
        return;
      }

      final ruta = resultado.files.single.path;
      if (ruta == null || ruta.isEmpty) {
        _mostrarMensaje('No se pudo leer la ruta del archivo', esError: true);
        return;
      }

      final existe = await File(ruta).exists();

      if (!existe) {
        _mostrarMensaje('El archivo seleccionado no existe', esError: true);
        return;
      }

      await DatabaseHelper.instance.importarProductosJSON(ruta);
      await _cargarProductos();
      setState(() {
        ultimaRutaExportada = ruta;
      });

      _mostrarMensaje('Importación completada');
    } catch (e) {
      _mostrarMensaje('Error al importar: $e', esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba Rapida SQLite/JSON'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _agregarProducto,
                        child: const Text('Agregar producto'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _exportar,
                        child: const Text('Exportar JSON'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _importar,
                    child: const Text('Importar JSON'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ruta backup: ${ultimaRutaExportada ?? 'sin exportar'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: productos.isEmpty
                ? const Center(child: Text('Sin productos'))
                : ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final pItem = productos[index];
                      return ListTile(
                        title: Text('${pItem['nombre']}'),
                        subtitle: Text('QR: ${pItem['codigo_qr']}'),
                        trailing: Text('₡${pItem['precio']}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}