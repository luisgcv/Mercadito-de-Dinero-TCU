import 'package:app/controllers/carrito_controller.dart';
import 'package:app/controllers/import_export_controller.dart';
import 'package:app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/producto_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductoController()),
        ChangeNotifierProvider(create: (_) => CarritoController()),
        ChangeNotifierProvider(create: (_) => ImportExportController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mercadito',
        home: const HomeScreen(),
      ),
    );
  }
}
