# DII Digital Library v2 — Frontend Plan

**Source:** ~/Projects/DII_Library_v2/frontend
**Backend:** http://localhost:8002
**Framework:** Flutter 3.47.4 stable
**Targets:** Web (Chrome) + Android (APK) — SAME codebase
**Dev port:** 5050

---

## DESIGN PHILOSOPHY

Portfolio-grade capstone, not "make it work":

1. Clean architecture — data / state / ui separated
2. Typed everything — no `dynamic` in UI
3. Centralized HTTP — one client, auto-refresh, typed errors
4. State via ChangeNotifier + Provider
5. Every screen has loading / empty / error / success
6. One theme, one place for colors
7. Mobile + Web responsive from day one

---

## MOBILE + WEB — SAME CODE

Breakpoints:
- Phone < 600  → 2-col grids, bottom nav, compact app bar
- Tablet 600-1024 → 3-col, sidebar collapsed
- Desktop ≥ 1024 → 6-col category grid, left sidebar, no bottom nav

Rules:
- No hardcoded widths (use LayoutBuilder / MediaQuery)
- No hover-only interactions (mobile has no mouse)
- No right-click-only menus (long-press on mobile)
- Touch targets ≥ 44px on phone
- SafeArea on all pages
- Cached images work offline

---

## ARCHITECTURE

lib/
  main.dart
  app.dart
  core/
    config.dart
    theme.dart
    constants.dart
    result.dart
  data/
    api/
      api_client.dart
      api_exception.dart
      token_store.dart
    models/
      user.dart
      book.dart
      category.dart
      borrowing.dart
      notification.dart
      report_summary.dart
      paginated.dart
    repositories/
      auth_repository.dart
      users_repository.dart
      books_repository.dart
      categories_repository.dart
      borrowings_repository.dart
      notifications_repository.dart
      reports_repository.dart
  state/
    auth_state.dart
    books_state.dart
    borrowings_state.dart
    notifications_state.dart
  ui/
    layout/
      responsive_shell.dart
      app_sidebar.dart
      app_bottom_nav.dart
    components/
      book_card.dart
      stat_card.dart
      user_avatar.dart
      notification_bell.dart
      loading_view.dart
      empty_view.dart
      error_view.dart
    pages/
      splash_page.dart
      login_page.dart
      signup_page.dart
      home_page.dart
      browse_page.dart
      book_details_page.dart
      my_books_page.dart
      history_page.dart
      profile_page.dart
      notifications_page.dart
      librarian/
        librarian_dashboard_page.dart
        borrow_requests_page.dart
        receive_return_page.dart
        manage_books_page.dart
        students_page.dart
      admin/
        admin_dashboard_page.dart
        manage_users_page.dart
        manage_librarians_page.dart
        reports_page.dart
  router/
    app_router.dart

---

## PACKAGES

dependencies:
  http
  go_router
  provider
  google_fonts
  shared_preferences
  flutter_animate
  cached_network_image
  intl

dev_dependencies:
  flutter_test
  flutter_lints

NO Firebase. NO Firestore. NO FirebaseAuth.

---

## BUILD ORDER

F1  Scaffold + packages
F2  Theme + constants
F3  API client + tokens + exceptions
F4  Models (6)
F5  Auth repo + state
F6  Router + guards
F7  Login + Signup
F8  Responsive shell
F9  Home page
F10 Browse + Details
F11 My Books + History
F12 Notifications (bell + SSE)
F13 Profile
F14 Librarian pages
F15 Admin pages
F16 Tests + polish
F17 Deploy

---

## DESIGN SYSTEM

Colors:
  kBlue   #0A1E5C
  kDeep   #081444
  kYellow #FFC107
  kGreen  #10B981
  kRed    #DC0F0F
  kPurple #7B1FA2
  BG      #F5F7F8
  Text    #0A1E5C / #5A6478

Typography: Inter / InterTight
Light theme only.

---

## AUTH STRATEGY

1. On boot: read refresh_token from shared_preferences
2. If present → POST /auth/refresh → if ok, logged in
3. If missing/fails → /login
4. ApiClient adds Bearer <access> to every request
5. On 401 → try /auth/refresh once → retry → else logout

---

## NOTIFICATIONS STRATEGY

- NotificationsState holds unreadCount
- Listens to GET /notifications/stream (SSE)
- Bell widget rebuilds on change
- Dropdown fetches /notifications on open
- Click → POST /notifications/{id}/read + navigate

---

## ERROR HANDLING

Result<T> = Ok<T> | Err(ApiException)

UI:
  LoadingView while awaiting
  ErrorView on Err (with retry)
  EmptyView on empty success
  Content on Ok

No scattered try/catch.

---

END OF FRONTEND PLAN
