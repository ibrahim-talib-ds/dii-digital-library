import '/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Legacy landing page — now redirects to Login.
class ModernAndSimplePageWidget extends StatefulWidget {
  const ModernAndSimplePageWidget({super.key});

  static String routeName = 'ModernAndSimplePage';
  static String routePath = '/modernAndSimplePage';

  @override
  State<ModernAndSimplePageWidget> createState() =>
      _ModernAndSimplePageWidgetState();
}

class _ModernAndSimplePageWidgetState extends State<ModernAndSimplePageWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.goNamed(LoginPageWidget.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
