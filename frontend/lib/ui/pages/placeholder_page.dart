import 'package:flutter/material.dart';

import '../../core/colors.dart';

/// Temporary page for routes we haven't implemented yet.
/// Each one gets replaced with a real page as we build.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_rounded,
                  size: 64, color: DiiColors.textDisabled),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: DiiColors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Coming soon',
                style: TextStyle(color: DiiColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
