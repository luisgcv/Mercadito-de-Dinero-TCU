import 'package:app/models/carrito_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/carrito_controller.dart';
import '../controllers/producto_controller.dart';
import 'scanner_screen.dart';
import '../services/audio_service.dart';
import 'checkout_result_screen.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  // Variable para controlar si estamos navegando
  bool _isNavigating = false;

  Future<void> _mostrarDialogoFinalizarCompra(BuildContext context) async {
    if (_isNavigating) return;

    // Obtener el controller ANTES de navegar
    final carritoController = Provider.of<CarritoController>(context, listen: false);
    
    // Crear una copia de los datos necesarios
    final itemsData = carritoController.items
        .map(
          (item) => CarritoItem(
            producto: item.producto,
            cantidad: item.cantidad,
          ),
        )
        .toList();
    final totalData = carritoController.total;

    // Verificar que el contexto siga montado
    if (!mounted) return;
    
    // Marcar que estamos navegando
    setState(() {
      _isNavigating = true;
    });

    // Usar una clave única para la ruta
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/checkout_result'),
        builder: (_) => CheckoutResultScreen(
          items: itemsData,
          total: totalData,
        ),
      ),
    );
    
    // Resetear estado de navegación después de regresar
    if (mounted) {
      setState(() {
        _isNavigating = false;
      });
    }
  }

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
      await AudioService.playSuccess();

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
                onTap: () async {
                  carritoController.agregarProducto(producto);
                  await AudioService.playSuccess();

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
      body: Consumer<CarritoController>(
        builder: (context, carrito, child) {
          if (carrito.items.isEmpty) {
            return const Center(
              child: Text("El carrito está vacío"),
            );
          }
          
          return ListView.builder(
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
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Consumer<CarritoController>(
          builder: (context, carrito, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Total: ₡${carrito.total.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: (carrito.items.isEmpty || _isNavigating)
                      ? null
                      : () => _mostrarDialogoFinalizarCompra(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Finalizar compra",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    carrito.limpiar();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Vaciar carrito",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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