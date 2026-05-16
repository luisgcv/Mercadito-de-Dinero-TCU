import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_brand.dart';
import '../widgets/brand_logo.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _logoScale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1, curve: Curves.easeOut),
    );

    unawaited(_goToHome());
  }

  Future<void> _goToHome() async {
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) =>
            FadeTransition(opacity: animation, child: const HomeScreen()),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppBrand.fondoGradiente),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -28,
              child: _bubble(120, AppBrand.celeste.withValues(alpha: 0.17)),
            ),
            Positioned(
              bottom: -20,
              left: -10,
              child: _bubble(
                140,
                AppBrand.amarilloNaranja.withValues(alpha: 0.18),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: const BrandLogo(size: 128, showText: true),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 40,
              child: Column(
                children: [
                  const Text(
                    'TCU Laboratorio de Matematica\nUCR Sede de Occidente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppBrand.azulOscuro,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    color: AppBrand.naranja,
                    backgroundColor: AppBrand.celeste.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(100),
                    minHeight: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
