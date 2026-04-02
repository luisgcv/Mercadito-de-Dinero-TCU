import 'package:flutter/material.dart';
import 'productos_screen.dart';
import 'carrito_screen.dart';
import 'import_export_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mercadito 🛒"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _botonMenu(
              context,
              "Productos",
              Icons.inventory,
              const ProductosScreen(),
            ),
            const SizedBox(height: 20),
            _botonMenu(
              context,
              "Carrito",
              Icons.shopping_cart,
              const CarritoScreen(),
            ),
          
            const SizedBox(height: 20),
            _botonMenu(
              context,
              "Importar / Exportar",
              Icons.sync,
              const ImportExportScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonMenu(
    BuildContext context,
    String texto,
    IconData icono,
    Widget pantalla,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        icon: Icon(icono, size: 30),
        label: Text(
          texto,
          style: const TextStyle(fontSize: 18),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => pantalla),
          );
        },
      ),
    );
  }
}