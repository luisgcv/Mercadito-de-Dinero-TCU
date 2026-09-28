import 'package:app/controllers/carrito_controller.dart';
import 'package:app/controllers/import_export_controller.dart';
import 'package:app/screens/splash_screen.dart';
import 'package:app/theme/app_brand.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/producto_controller.dart';

/// Punto de entrada de la aplicación "Mercadito de Dinero".
///
/// Inicializa los bindings de Flutter (necesario porque varios plugins
/// —sqflite, path_provider, audioplayers— usan canales nativos) y arranca
/// [MyApp].
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Widget raíz de la aplicación.
///
/// Registra con `provider` los tres controladores globales, de modo que
/// cualquier pantalla puede leerlos con `context.read<T>()`,
/// `context.watch<T>()` o `Provider.of<T>(context)`:
///
/// - [ProductoController]: catálogo de productos (CRUD, imágenes, búsquedas).
/// - [CarritoController]: carrito de compras en memoria.
/// - [ImportExportController]: respaldo e importación de la base de datos en ZIP.
///
/// También aplica el tema visual global ([AppBrand.theme]) y muestra
/// [SplashScreen] como primera pantalla.
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
        title: 'Mercadito de Dinero',
        theme: AppBrand.theme,
        home: const SplashScreen(),
      ),
    );
  }
}
