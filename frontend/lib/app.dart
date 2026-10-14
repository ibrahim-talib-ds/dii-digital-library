import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'router/app_router.dart';
import 'state/auth_state.dart';

class DiiApp extends StatelessWidget {
  const DiiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final router = context.read<AppRouter>().router;

    // Whenever auth state changes, the router refreshes automatically
    // because AppRouter was constructed with refreshListenable = auth.
    // ignore: unused_local_variable
    final _ = auth;

    return MaterialApp.router(
      title: 'DII Digital Library',
      debugShowCheckedModeBanner: false,
      theme: DiiTheme.light(),
      routerConfig: router,
    );
  }
}
