import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/carrito_controller.dart';
import '../controllers/producto_controller.dart';
import 'scanner_screen.dart'; // 👈 IMPORTANTE

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  Future<void> _buscarPorNombre(BuildContext context) async {
    final busquedaController = TextEditingController();

    final String? nombre = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Buscar producto"),
          content: TextField(
            controller: busquedaController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Escribe el nombre",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, busquedaController.text.trim());
              },
              child: const Text("Buscar"),
            ),
          ],
        );
      },
    );

    if (nombre == null || nombre.isEmpty) return;

    final productosController =
        Provider.of<ProductoController>(context, listen: false);
    final carritoController =
        Provider.of<CarritoController>(context, listen: false);

    final resultados = await productosController.buscarPorNombre(nombre);

    if (!context.mounted) return;

    if (resultados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se encontraron productos")),
      );
      return;
    }

    if (resultados.length == 1) {
      final producto = resultados.first;
      carritoController.agregarProducto(producto);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${producto.nombre} agregado")),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.builder(
            itemCount: resultados.length,
            itemBuilder: (itemContext, index) {
              final producto = resultados[index];
              return ListTile(
                title: Text(producto.nombre),
                subtitle: Text("₡${producto.precio}"),
                onTap: () {
                  carritoController.agregarProducto(producto);
                  Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${producto.nombre} agregado")),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrito"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: "Buscar por nombre",
            onPressed: () => _buscarPorNombre(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: carrito.items.length,
              itemBuilder: (context, index) {
                final item = carrito.items[index];
                final producto = item.producto;

                return ListTile(
                  title: Text(producto.nombre),
                  subtitle: Text(
                    "Cantidad: ${item.cantidad}  |  ₡${producto.precio} c/u\nSubtotal: ₡${item.subtotal}",
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      carrito.eliminarProducto(producto);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Total: ₡${carrito.total}",
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                carrito.limpiar();
              },
              child: const Text("Vaciar carrito"),
            ),
          ],
        ),
      ),

      // 🔥 AQUÍ VA (dentro del Scaffold)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ScannerScreen(),
            ),
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}