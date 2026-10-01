import 'package:flutter/material.dart';

/// DII Library logo — use everywhere for consistent branding.
///
///   const DiiLogo(size: 40)
class DiiLogo extends StatelessWidget {
  const DiiLogo({
    super.key,
    this.size = 40,
    this.rounded = true,
    this.backgroundColor,
  });

  final double size;
  final bool rounded;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final radius = rounded ? BorderRadius.circular(size * 0.22) : null;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
      ),
      clipBehavior: rounded ? Clip.antiAlias : Clip.none,
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
            size: size * 0.55,
          ),
        ),
      ),
    );
  }
}

/// Brand row — logo + "DII Library" wordmark
class DiiBrand extends StatelessWidget {
  const DiiBrand({
    super.key,
    this.logoSize = 36,
    this.fontSize = 18,
    this.light = true,
  });

  final double logoSize;
  final double fontSize;
  final bool light; // white text on dark bg; navy text on light bg

  @override
  Widget build(BuildContext context) {
    final primary = light ? Colors.white : const Color(0xFF0A1E5C);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DiiLogo(size: logoSize),
        const SizedBox(width: 10),
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
