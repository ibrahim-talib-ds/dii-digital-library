import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';
import '../core/first_launch.dart';
import '../state/auth_state.dart';
import '../ui/pages/splash_page.dart';
import '../ui/pages/login_page.dart';
import '../ui/pages/signup_page.dart';
import '../ui/pages/home_page.dart';
import '../ui/pages/placeholder_page.dart';
import '../ui/pages/browse_page.dart';
import '../ui/pages/book_details_page.dart';
import '../ui/pages/my_books_page.dart';
import '../ui/pages/history_page.dart';
import '../ui/pages/profile_page.dart';
import '../ui/pages/saved_books_page.dart';
import '../ui/pages/ai_chat_page.dart';
import '../ui/pages/chat_thread_page.dart';
import '../ui/pages/messages_page.dart';
import '../ui/pages/librarian/borrow_requests_page.dart';
import '../ui/pages/librarian/issue_book_page.dart';
import '../ui/pages/librarian/receive_return_page.dart';
import '../ui/pages/librarian/manage_books_page.dart';
import '../ui/pages/librarian/students_page.dart';
import '../ui/pages/admin/manage_users_page.dart';
import '../ui/pages/admin/manage_librarians_page.dart';
import '../ui/pages/admin/reports_page.dart';

class AppRouter {
  AppRouter(this._auth);

  final AuthState _auth;

  late final GoRouter router = GoRouter(
    initialLocation: DiiRoutes.splash,
    refreshListenable: _auth,
    redirect: _guard,
    // Special dev route — /reset forces logout + shows welcome again
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: DiiRoutes.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: '/reset',
        builder: (_, __) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await FirstLaunch.reset();
          });
          return const SplashPage();
        },
      ),

      // Direct alias so splash can still be reached manually if needed
      GoRoute(
        path: '/welcome',
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: DiiRoutes.login,
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return LoginPage(role: role);
        },
      ),
      GoRoute(
        path: DiiRoutes.signup,
        builder: (_, __) => const SignupPage(),
      ),
      GoRoute(
        path: DiiRoutes.home,
        builder: (_, __) => const HomePage(),
      ),
      // Placeholder routes for pages we haven't built yet.
      // Each will be replaced with a real page as we go.
      GoRoute(
        path: DiiRoutes.browse,
        builder: (context, state) {
          final q = state.uri.queryParameters;
          return BrowsePage(
            initialCategory: q['category'],
            initialSearch: q['search'],
          );
        },
      ),
      GoRoute(
        path: '${DiiRoutes.bookDetails}/:id',
        builder: (context, state) => BookDetailsPage(
          bookId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/messages',
        builder: (_, __) => const MessagesPage(),
      ),
      GoRoute(
        path: '/chat/:partnerId',
        builder: (context, state) => ChatThreadPage(
          partnerId: state.pathParameters['partnerId']!,
        ),
      ),
      GoRoute(
        path: '/ai',
        builder: (_, __) => const AiChatPage(),
      ),
      GoRoute(
        path: '/saved',
        builder: (_, __) => const SavedBooksPage(),
      ),
      GoRoute(
        path: DiiRoutes.myBooks,
        builder: (_, __) => const MyBooksPage(),
      ),
      GoRoute(
        path: DiiRoutes.history,
        builder: (_, __) => const HistoryPage(),
      ),
      GoRoute(
        path: DiiRoutes.profile,
        builder: (_, __) => const ProfilePage(),
      ),
      GoRoute(
        path: DiiRoutes.notifications,
        builder: (_, __) => const PlaceholderPage(title: 'Notifications'),
      ),
      GoRoute(
        path: '/issue-book',
        builder: (_, __) => const IssueBookPage(),
      ),
      GoRoute(
        path: DiiRoutes.borrowRequests,
        builder: (_, __) => const BorrowRequestsPage(),
      ),
      GoRoute(
        path: DiiRoutes.receiveReturn,
        builder: (_, __) => const ReceiveReturnPage(),
      ),
      GoRoute(
        path: DiiRoutes.manageBooks,
        builder: (_, __) => const ManageBooksPage(),
      ),
      GoRoute(
        path: DiiRoutes.students,
        builder: (_, __) => const StudentsPage(),
      ),
      GoRoute(
        path: DiiRoutes.manageUsers,
        builder: (_, __) => const ManageUsersPage(),
      ),
      GoRoute(
        path: DiiRoutes.manageLibrarians,
        builder: (_, __) => const ManageLibrariansPage(),
      ),
      GoRoute(
        path: DiiRoutes.reports,
        builder: (_, __) => const ReportsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(child: Text('No route for ${state.uri}')),
    ),
  );

  /// Central navigation guard.
  ///
  /// Rules:
  ///   - While we don't yet know the auth state → stay on splash
  ///   - Welcome (/splash) only shown ONCE per device → then /login
  ///   - Not signed in → /login (except /login + /signup + first-time /splash)
  ///   - Signed in → never on /login, /signup, or /splash → /home
  Future<String?> _guard(BuildContext context, GoRouterState state) async {
    final loc = state.matchedLocation;
    final isReady = _auth.isReady;
    final isAuthed = _auth.isAuthenticated;

    if (!isReady) {
      return loc == DiiRoutes.splash ? null : DiiRoutes.splash;
    }

    // allow the dev reset page through regardless of auth state
    if (loc == '/clear') return null;

    final isAuthRoute = loc == DiiRoutes.login || loc == DiiRoutes.signup;
    final isSplash = loc == DiiRoutes.splash;

    if (!isAuthed) {
      // welcome screen shown only on first visit
      if (isSplash) {
        final seen = await FirstLaunch.hasSeenWelcome();
        return seen ? DiiRoutes.login : null;
      }
      return isAuthRoute ? null : DiiRoutes.login;
    }

    if (isAuthRoute || isSplash) {
      return DiiRoutes.home;
    }

    return null;
  }
}
