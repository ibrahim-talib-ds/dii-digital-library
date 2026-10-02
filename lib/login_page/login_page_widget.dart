import '/custom/role_utils.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_page_model.dart';
import '/custom/dii_logo.dart';
export 'login_page_model.dart';

class LoginPageWidget extends StatefulWidget {
  const LoginPageWidget({super.key});

  static String routeName = 'LoginPage';
  static String routePath = '/loginPage';

  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  late LoginPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kDeep   = Color(0xFF081444);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kRed    = Color(0xFFDC0F0F);

  final _studentCtl  = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginPageModel());
  }

  @override
  void dispose() {
    _studentCtl.dispose();
    _passwordCtl.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();

    final input = _studentCtl.text.trim().toLowerCase();
    final password = _passwordCtl.text;

    if (input.isEmpty || password.isEmpty) {
      _snack('Please enter your student number and password', kRed);
      return;
    }

    final email = input.contains('@') ? input : '$input@dii.tj';

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: password);
      await loadCurrentUserRole();
      if (!mounted) return;
      _routeByRole();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'user-not-found' || e.code == 'wrong-password'
          ? 'Wrong student number or password'
          : e.code == 'invalid-email'
              ? 'Invalid format — use your student number'
              : (e.message ?? 'Sign in failed');
      _snack(msg, kRed);
    } catch (e) {
      if (!mounted) return;
      _snack('Error: $e', kRed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: c));
  }

  void _routeByRole() {
    final role = currentRole();
    if (role == 'admin') {
      context.goNamedAuth(AdminDashboardWidget.routeName, context.mounted);
    } else if (role == 'librarian') {
      context.goNamedAuth(LibrarianDashboardWidget.routeName, context.mounted);
    } else {
      context.goNamedAuth(HomePageWidget.routeName, context.mounted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isPhone = w < 800;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: Row(
          children: [
            // ─── LEFT BRAND PANEL (desktop only) ───
            if (!isPhone)
              Expanded(
                flex: 5,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kBlue, kDeep],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -80, top: -80, bottom: -80, width: 400,
                        child: Opacity(
                          opacity: 0.25,
                          child: Image.asset('assets/images/library.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const DiiBrand(),
                            const SizedBox(height: 40),
                            Text('Welcome back.',
                                style: GoogleFonts.interTight(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                )),
                            const SizedBox(height: 12),
                            Text(
                              'Sign in with your DII student number to browse\n'
                              'thousands of books and manage your loans.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 40),
                            _feature(Icons.library_books_rounded,
                                'Search & request books'),
                            _feature(Icons.assignment_turned_in_rounded,
                                'Track your borrowing history'),
                            _feature(Icons.picture_as_pdf_rounded,
                                'Read PDF previews'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ─── RIGHT FORM PANEL ───
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.white,
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isPhone ? 24 : 48),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Mobile brand
                          if (isPhone) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: kBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.menu_book_rounded,
                                      color: kYellow, size: 24),
                                ),
                                const SizedBox(width: 12),
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: 'DII ',
                                      style: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w900,
                                        color: kBlue,
                                        fontSize: 24,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Library',
                                      style: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w900,
                                        color: kYellow,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],

                          Text(
                            isPhone ? 'Sign In' : 'Sign in to your account',
                            style: GoogleFonts.interTight(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: kBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use your DII student number to continue',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Student number
                          _label('Student Number'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _studentCtl,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDeco(
                              hint: 'e.g. 240023018',
                              icon: Icons.badge_outlined,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Password
                          _label('Password'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordCtl,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _signIn(),
                            decoration: _inputDeco(
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Sign in button
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white),
                                    )
                                  : Text('Sign In',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      )),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                  child: Divider(color: Colors.grey.shade300)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('New student?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    )),
                              ),
                              Expanded(
                                  child: Divider(color: Colors.grey.shade300)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Sign up button
                          SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () => context
                                  .pushNamed(SignUpPageWidget.routeName),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kBlue,
                                side: const BorderSide(color: kBlue, width: 2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Create an Account',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  )),
                            ),
                          ),

                          const SizedBox(height: 32),
                          Text(
                            '© 2026 DII Library · Dushanbe',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: kBlue,
        ));
  }

  InputDecoration _inputDeco({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: Icon(icon, color: kBlue, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBlue, width: 2),
      ),
    );
  }

  Widget _feature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: kYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kYellow, size: 18),
          ),
          const SizedBox(width: 12),
          Text(text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
