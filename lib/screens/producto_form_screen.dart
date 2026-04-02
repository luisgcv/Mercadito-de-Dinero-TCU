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

  void guardarProducto() {
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

    Provider.of<ProductoController>(context, listen: false)
        .agregarProducto(producto);

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
        child: Form(
          key: _formKey,
          child: Column(
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: guardarProducto,
                child: const Text("Guardar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}