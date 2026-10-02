import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'auth/firebase_auth/firebase_user_provider.dart';
import 'backend/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/nav/nav.dart';
import 'index.dart';

String? _startupError;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    // ignore: avoid_print
    print('FLUTTER_ERROR: ${details.exception}');
  };

  try {
    await initFirebase();
    // ignore: avoid_print
    print('✅ Firebase OK');
  } catch (e) {
    _startupError = 'Firebase init failed:\n$e';
    // ignore: avoid_print
    print('❌ $_startupError');
  }

  try {
    await FlutterFlowTheme.initialize();
  } catch (e) {
    // ignore: avoid_print
    print('❌ Theme: $e');
  }

  final appState = FFAppState();
  try {
    await appState.initializePersistedState();
  } catch (e) {
    // ignore: avoid_print
    print('❌ AppState: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => appState,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class _MyAppState extends State<MyApp> {
  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  late Stream<BaseAuthUser> userStream;

  // ═══════════════════════════════════════════════════════════════
  // Required by flutter_flow_util.dart
  // ═══════════════════════════════════════════════════════════════

  ThemeMode _themeMode = ThemeMode.light;

  /// Returns the current route path (ex: '/homePage')
  String getRoute([RouteMatch? routeMatch]) {
    try {
      final RouteMatch lastMatch =
          routeMatch ?? _router.routerDelegate.currentConfiguration.last;
      final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
          ? lastMatch.matches
          : _router.routerDelegate.currentConfiguration;
      return matchList.uri.path;
    } catch (_) {
      return '';
    }
  }

  /// Returns the full route stack as a list of paths
  List<String> getRouteStack() {
    try {
      return _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Called by FlutterFlow when the app theme changes.
  /// We force light mode.
  void setThemeMode(ThemeMode mode) {
    safeSetState(() {
      _themeMode = ThemeMode.light;
    });
  }

  // ═══════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);

    try {
      userStream = diiLibraryFirebaseUserStream()
        ..listen((user) {
          _appStateNotifier.update(user);
        });
    } catch (e) {
      // ignore: avoid_print
      print('❌ user stream: $e');
    }

    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_startupError != null) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red.shade50,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚠️ Startup Error',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.red)),
                  const SizedBox(height: 16),
                  SelectableText(
                    _startupError!,
                    style: const TextStyle(
                        fontSize: 13, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Dii Library',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(brightness: Brightness.light, useMaterial3: false),
      darkTheme: ThemeData(brightness: Brightness.light, useMaterial3: false),
      themeMode: ThemeMode.light,
      routerConfig: _router,
    );
  }
}
