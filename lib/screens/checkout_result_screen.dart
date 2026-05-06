import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/carrito_controller.dart';
import '../models/carrito_item.dart';

class CheckoutResultScreen extends StatefulWidget {
  final List<CarritoItem> items;
  final double total;

  const CheckoutResultScreen({
    super.key,
    required this.items,
    required this.total,
  });

  @override
  State<CheckoutResultScreen> createState() => _CheckoutResultScreenState();
}

class _CheckoutResultScreenState extends State<CheckoutResultScreen> {
  final TextEditingController _dineroController = TextEditingController();
  double? _dineroRecibido;

  @override
  void dispose() {
    _dineroController.dispose();
    super.dispose();
  }

  void _actualizarDinero(String value) {
    final texto = value.trim();
    setState(() {
      _dineroRecibido = double.tryParse(texto);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dineroRecibido = _dineroRecibido;
    final tieneMontoValido = dineroRecibido != null && dineroRecibido >= 0;
    final alcanza = tieneMontoValido ? dineroRecibido >= widget.total : null;
    final diferencia = tieneMontoValido ? (dineroRecibido - widget.total).abs() : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Resultado de compra"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Productos:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.producto.nombre,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                "x${item.cantidad} @ ₡${item.producto.precio}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "₡${item.subtotal.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _dineroController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _actualizarDinero,
              decoration: const InputDecoration(
                labelText: "Ingrese el dinero del estudiante",
                hintText: "Ej: 5000.00",
                prefixText: "₡ ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total de compra:"),
                      Text(
                        "₡${widget.total.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Dinero recibido:"),
                      Text(
                        tieneMontoValido ? "₡${dineroRecibido.toStringAsFixed(2)}" : "--",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tieneMontoValido
                            ? (alcanza == true ? "Cambio:" : "Faltante:")
                            : "Resultado:",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        tieneMontoValido ? "₡${diferencia!.toStringAsFixed(2)}" : "Ingrese un monto",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: tieneMontoValido
                              ? (alcanza == true ? Colors.green[700] : Colors.red[700])
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: tieneMontoValido
                    ? (alcanza == true ? Colors.green[50] : Colors.red[50])
                    : Colors.grey[50],
                border: Border.all(
                  color: tieneMontoValido
                      ? (alcanza == true ? Colors.green[300]! : Colors.red[300]!)
                      : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    tieneMontoValido
                        ? (alcanza == true ? Icons.check_circle : Icons.cancel)
                        : Icons.receipt_long,
                    color: tieneMontoValido
                        ? (alcanza == true ? Colors.green[700] : Colors.red[700])
                        : Colors.grey[700],
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tieneMontoValido
                        ? (alcanza == true ? "✅ Sí le alcanza" : "❌ No le alcanza")
                        : "Ingresa el dinero para calcular",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: tieneMontoValido
                          ? (alcanza == true ? Colors.green[700] : Colors.red[700])
                          : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.grey[600],
                    ),
                    child: const Text(
                      "Volver al carrito",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Future.microtask(() {
                        if (context.mounted) {
                          Provider.of<CarritoController>(context, listen: false).limpiar();
                          Navigator.pop(context);
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      "Nuevo cliente",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}