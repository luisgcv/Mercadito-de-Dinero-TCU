import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/producto_controller.dart';
import '../models/producto.dart';

class ProductoFormScreen extends StatefulWidget {
  const ProductoFormScreen({super.key});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController precioController = TextEditingController();

  @override
  void dispose() {
    nombreController.dispose();
    precioController.dispose();
    super.dispose();
  }

  Future<void> guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = nombreController.text;
    final precio = double.parse(precioController.text);

    //  generar QR único
    final codigoQR = "PROD_${DateTime.now().millisecondsSinceEpoch}";

    final producto = Producto(
      nombre: nombre,
      precio: precio,
      codigoQr: codigoQR,
    );

    final controller = Provider.of<ProductoController>(context, listen: false);
    final guardado = await controller.agregarProducto(producto);

    if (!mounted) return;

    if (!guardado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'No se pudo guardar')),
      );
      return;
    }

    Navigator.pop(context); // volver a la lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo Producto"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<ProductoController>(
          builder: (context, controller, _) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: "Nombre"),
                      validator: (value) =>
                          value!.isEmpty ? "Ingrese un nombre" : null,
                    ),
                    TextFormField(
                      controller: precioController,
                      decoration: const InputDecoration(labelText: "Precio"),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? "Ingrese un precio" : null,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => controller.seleccionarImagen(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: controller.tieneImagenSeleccionada
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(controller.imagenSeleccionadaTemporalPath!),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 180,
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.photo_library_outlined, size: 48),
                                    SizedBox(height: 8),
                                    Text('Tocar para elegir imagen'),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (controller.tieneImagenSeleccionada)
                      TextButton(
                        onPressed: controller.limpiarImagenSeleccionada,
                        child: const Text('Quitar imagen'),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: guardarProducto,
                      child: const Text("Guardar"),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}