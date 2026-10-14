import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/config.dart';
import 'data/api/api_client.dart';
import 'data/api/token_store.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/books_repository.dart';
import 'data/repositories/borrowings_repository.dart';
import 'data/repositories/categories_repository.dart';
import 'data/repositories/notifications_repository.dart';
import 'data/repositories/reports_repository.dart';
import 'data/repositories/saved_books_repository.dart';
import 'data/repositories/users_repository.dart';
import 'router/app_router.dart';
import 'state/auth_state.dart';
import 'state/notifications_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokens = TokenStore();
  await tokens.load();

  late final AuthState authState;
  late final NotificationsState notifState;

  final apiClient = ApiClient(
    tokens: tokens,
    onForceLogout: () => authState.onForceLogout(),
  );

  final authRepo = AuthRepository(apiClient, tokens);

  authState = AuthState(repo: authRepo, tokens: tokens);

  final notificationsRepo = NotificationsRepository(apiClient);
  notifState = NotificationsState(repo: notificationsRepo);

  authState.addListener(() {
    if (authState.isAuthenticated) {
      notifState.startStream();
      notifState.refresh();
    } else {
      notifState.stopStream();
    }
  });

  final appRouter      = AppRouter(authState);
  final categoriesRepo = CategoriesRepository(apiClient);
  final booksRepo      = BooksRepository(apiClient);
  final borrowingsRepo = BorrowingsRepository(apiClient);
  final usersRepo      = UsersRepository(apiClient);
  final reportsRepo    = ReportsRepository(apiClient);
  final savedBooksRepo = SavedBooksRepository(apiClient);

  authState.bootstrap();

  debugPrint('🌐 API base: ${ApiConfig.baseUrl}');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthState>.value(value: authState),
        ChangeNotifierProvider<NotificationsState>.value(value: notifState),
        Provider<AppRouter>.value(value: appRouter),
        Provider<ApiClient>.value(value: apiClient),
        Provider<TokenStore>.value(value: tokens),
        Provider<AuthRepository>.value(value: authRepo),
        Provider<CategoriesRepository>.value(value: categoriesRepo),
        Provider<BooksRepository>.value(value: booksRepo),
        Provider<BorrowingsRepository>.value(value: borrowingsRepo),
        Provider<NotificationsRepository>.value(value: notificationsRepo),
        Provider<UsersRepository>.value(value: usersRepo),
        Provider<ReportsRepository>.value(value: reportsRepo),
        Provider<SavedBooksRepository>.value(value: savedBooksRepo),
      ],
      child: const DiiApp(),
    ),
  );
}
