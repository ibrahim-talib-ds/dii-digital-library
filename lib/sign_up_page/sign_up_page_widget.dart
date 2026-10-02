import '/custom/role_utils.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'sign_up_page_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/custom/dii_logo.dart';
export 'sign_up_page_model.dart';

class SignUpPageWidget extends StatefulWidget {
  const SignUpPageWidget({super.key});

  static String routeName = 'SignUpPage';
  static String routePath = '/signUpPage';

  @override
  State<SignUpPageWidget> createState() => _SignUpPageWidgetState();
}

class _SignUpPageWidgetState extends State<SignUpPageWidget> {
  late SignUpPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kDeep   = Color(0xFF081444);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kRed    = Color(0xFFDC0F0F);

  final _nameCtl     = TextEditingController();
  final _numberCtl   = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SignUpPageModel());
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _numberCtl.dispose();
    _passwordCtl.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    FocusScope.of(context).unfocus();

    final name = _nameCtl.text.trim();
    final number = _numberCtl.text.trim().toLowerCase();
    final password = _passwordCtl.text;

    if (name.isEmpty) {
      _snack('Please enter your full name', kRed);
      return;
    }
    if (number.isEmpty) {
      _snack('Please enter your student number', kRed);
      return;
    }
    if (password.length < 6) {
      _snack('Password must be at least 6 characters', kRed);
      return;
    }

    final email = number.contains('@') ? number : '$number@dii.tj';
    if (!email.endsWith('@dii.tj')) {
      _snack('Only DII emails are allowed', kRed);
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await cred.user?.updateDisplayName(name);

      final uid = cred.user!.uid;
      final studentNumber = email.split('@').first;
      final isOwner = email == '240023018@dii.tj';

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'studentNumber': studentNumber,
        'department': '',
        'year': 0,
        'role': isOwner ? 'admin' : 'student',
        'status': 'active',
        'active': true,
        'borrowLimit': isOwner ? 10 : 3,
        'photoUrl': '',
        'phone': '',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await loadCurrentUserRole();

      if (!mounted) return;
      context.goNamedAuth(HomePageWidget.routeName, context.mounted);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'email-already-in-use'
          ? 'This student number is already registered'
          : e.code == 'weak-password'
              ? 'Password is too weak'
              : e.code == 'invalid-email'
                  ? 'Invalid student number'
                  : (e.message ?? 'Sign up failed');
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
            // ─── LEFT BRAND PANEL ───
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
                            Text('Join DII Library',
                                style: GoogleFonts.interTight(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                )),
                            const SizedBox(height: 12),
                            Text(
                              'Create your account in seconds.\n'
                              'All you need is your DII student number.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ─── RIGHT FORM ───
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
                            isPhone ? 'Create Account' : 'Create your account',
                            style: GoogleFonts.interTight(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: kBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use your DII student number to register',
                            style: TextStyle(fontSize: 14,
                              color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 28),

                          _label('Full Name'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameCtl,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDeco(
                              hint: 'e.g. Ibrahim Talib',
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 18),

                          _label('Student Number'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _numberCtl,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDeco(
                              hint: 'e.g. 240023018',
                              icon: Icons.badge_outlined,
                            ),
                          ),
                          const SizedBox(height: 18),

                          _label('Password'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordCtl,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _create(),
                            decoration: _inputDeco(
                              hint: 'At least 6 characters',
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

                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _create,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white),
                                    )
                                  : Text('Create Account',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      )),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('Already registered?',
                                    style: TextStyle(fontSize: 12,
                                      color: Colors.grey.shade600)),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () => context
                                  .pushNamed(LoginPageWidget.routeName),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kBlue,
                                side: const BorderSide(color: kBlue, width: 2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Sign In',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  )),
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

  Widget _label(String text) => Text(text,
    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: kBlue));

  InputDecoration _inputDeco({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: Icon(icon, color: kBlue, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
}
