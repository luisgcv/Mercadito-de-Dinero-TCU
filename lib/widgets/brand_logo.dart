import 'package:flutter/material.dart';

import '../theme/app_brand.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 104,
    this.showText = true,
    this.textAlign = TextAlign.center,
  });

  final double size;
  final bool showText;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppBrand.celeste, AppBrand.azulOscuro],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33005DA4),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: size * 0.18,
                left: size * 0.20,
                child: Icon(
                  Icons.shopping_cart_rounded,
                  size: size * 0.56,
                  color: AppBrand.blanco,
                ),
              ),
              Positioned(
                bottom: -size * 0.08,
                right: size * 0.05,
                child: _Coin(size: size * 0.28),
              ),
              Positioned(
                top: -size * 0.08,
                right: size * 0.12,
                child: Transform.rotate(
                  angle: 0.7,
                  child: Container(
                    width: size * 0.16,
                    height: size * 0.16,
                    decoration: const BoxDecoration(
                      color: AppBrand.amarilloNaranja,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 18),
          Text(
            'Mercadito de Dinero',
            textAlign: textAlign,
            style: const TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w900,
              height: 1,
              color: AppBrand.azulOscuro,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Aprende matematicas comprando',
            textAlign: textAlign,
            style: TextStyle(
              fontSize: 14,
              color: AppBrand.azulOscuro.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _Coin extends StatelessWidget {
  const _Coin({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppBrand.amarilloNaranja,
        border: Border.all(color: AppBrand.naranja, width: 2),
      ),
      child: const Center(
        child: Text(
          'C',
          style: TextStyle(color: AppBrand.blanco, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
