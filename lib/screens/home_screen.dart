import 'package:flutter/material.dart';

import '../theme/app_brand.dart';
import '../widgets/brand_logo.dart';
import 'productos_screen.dart';
import 'carrito_screen.dart';
import 'import_export_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mercadito de Dinero"),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppBrand.fondoGradiente),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
            children: [
              const Center(child: BrandLogo(size: 96, showText: true)),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: const [
                  Chip(
                    avatar: Icon(Icons.calculate_rounded, size: 18),
                    label: Text('Matematicas'),
                  ),
                  Chip(
                    avatar: Icon(Icons.payments_rounded, size: 18),
                    label: Text('Dinero'),
                  ),
                  Chip(
                    avatar: Icon(Icons.school_rounded, size: 18),
                    label: Text('Aprender jugando'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _menuCard(
                context,
                color: AppBrand.celeste,
                icon: Icons.inventory_2_rounded,
                title: 'Productos',
                subtitle: 'Crea y administra el catalogo del mercadito',
                screen: const ProductosScreen(),
              ),
              const SizedBox(height: 14),
              _menuCard(
                context,
                color: AppBrand.naranja,
                icon: Icons.shopping_cart_checkout_rounded,
                title: 'Carrito',
                subtitle: 'Practica compras, suma y calculo de cambios',
                screen: const CarritoScreen(),
              ),
              const SizedBox(height: 14),
              _menuCard(
                context,
                color: AppBrand.verde,
                icon: Icons.sync_alt_rounded,
                title: 'Importar / Exportar',
                subtitle: 'Comparte respaldos y recursos del juego',
                screen: const ImportExportScreen(),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppBrand.amarilloNaranja.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          color: AppBrand.azulOscuro,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'TCU Laboratorio de Matematica - UCR Sede de Occidente',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppBrand.azulOscuro,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, size: 34, color: AppBrand.azulOscuro),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppBrand.azulOscuro,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppBrand.azulOscuro.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppBrand.azulOscuro,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
