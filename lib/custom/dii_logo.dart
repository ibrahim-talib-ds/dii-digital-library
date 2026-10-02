import 'package:flutter/material.dart';

/// DII Library logo — sized for a clean fit.
class DiiLogo extends StatelessWidget {
  const DiiLogo({
    super.key,
    this.size = 32,
    this.rounded = true,
    this.circular = false,
    this.backgroundColor,
  });

  final double size;
  final bool rounded;
  final bool circular;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular
            ? null
            : (rounded ? BorderRadius.circular(size * 0.24) : null),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/logos/dii_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFF0A1E5C),
          alignment: Alignment.center,
          child: Icon(
            Icons.menu_book_rounded,
            color: const Color(0xFFFFC107),
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}

/// Brand row — logo + "DII Library" wordmark.
class DiiBrand extends StatelessWidget {
  const DiiBrand({
    super.key,
    this.logoSize = 30,
    this.fontSize = 16,
    this.light = true,
    this.circular = false,
  });

  final double logoSize;
  final double fontSize;
  final bool light;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final primary = light ? Colors.white : const Color(0xFF0A1E5C);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DiiLogo(
          size: logoSize,
          circular: circular,
          backgroundColor: circular ? const Color(0xFF0A1E5C) : null,
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: 'DII ',
              style: TextStyle(
                color: primary,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
            TextSpan(
              text: 'Library',
              style: TextStyle(
                color: const Color(0xFFFFC107),
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
