import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/result.dart';
import '../../data/repositories/auth_repository.dart';
import '../../state/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.role});

  final String? role; // 'student' | 'librarian'

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs =
      TabController(length: 2, vsync: this);

  bool get _isLibrarian => widget.role == 'librarian';

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final wide = w >= 950;

    if (!wide) {
      return Scaffold(
        backgroundColor: DiiColors.blue,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _topBanner(),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
                  child: _formArea(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(flex: 5, child: _leftImage()),
          Expanded(
            flex: 5,
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 56, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: _formArea(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── left image panel ───
  Widget _leftImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/university.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/library.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: DiiColors.blue),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DiiColors.blue.withValues(alpha: 0.86),
                DiiColors.deep.withValues(alpha: 0.94),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ─── brand (clickable to go back) ───
              InkWell(
                onTap: () => context.go(DiiRoutes.splash),
                child: Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: DiiColors.yellow,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.menu_book_rounded,
                          color: DiiColors.blue, size: 26),
                    ),
                    const SizedBox(width: 12),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'DII ',
                          style: GoogleFonts.interTight(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                        TextSpan(
                          text: 'Library',
                          style: GoogleFonts.interTight(
                            fontWeight: FontWeight.w900,
                            color: DiiColors.yellow,
                            fontSize: 22,
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              // ─── tagline ───
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: DiiColors.yellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: DiiColors.yellow.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      _isLibrarian
                          ? 'LIBRARIAN ACCESS'
                          : 'STUDENT ACCESS',
                      style: GoogleFonts.inter(
                        color: DiiColors.yellow,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isLibrarian
                        ? 'Manage the library\\nfrom one place.'
                        : 'Your entire library,\\nin one place.',
                    style: GoogleFonts.interTight(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLibrarian
                        ? 'Approve requests, manage books, receive returns, and track students.'
                        : 'Browse books for your courses, request physical copies, and keep track of your loans.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
              Text(
                '© Dushanbe Innovation Institute',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── phone banner ───
  Widget _topBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 56),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DiiColors.blue, DiiColors.deep],
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => context.go(DiiRoutes.splash),
            child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: DiiColors.yellow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.menu_book_rounded,
                  color: DiiColors.blue, size: 34),
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(children: [
              TextSpan(
                text: 'DII ',
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 26,
                ),
              ),
              TextSpan(
                text: 'Library',
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w900,
                  color: DiiColors.yellow,
                  fontSize: 26,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 6),
          Text(
            _isLibrarian ? 'Librarian sign in' : 'Student sign in',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─── form area ───
  Widget _formArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // back button
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => context.go(DiiRoutes.splash),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: Text(
              _isLibrarian ? 'Librarian' : 'Student',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            style: TextButton.styleFrom(
              foregroundColor: DiiColors.blue,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Text(
          _isLibrarian ? 'Librarian Sign In' : 'Student Sign In',
          style: GoogleFonts.interTight(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: DiiColors.textPrimary,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isLibrarian
              ? 'Use your staff ID and password'
              : 'Enter your student number and password, or create an account',
          style: const TextStyle(
            color: DiiColors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // tabs
        Container(
          decoration: BoxDecoration(
            color: DiiColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DiiColors.border),
          ),
          padding: const EdgeInsets.all(4),
          child: TabBar(
            controller: _tabs,
            indicator: BoxDecoration(
              color: DiiColors.blue,
              borderRadius: BorderRadius.circular(9),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: DiiColors.textSecondary,
            labelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
            tabs: const [
              Tab(text: 'Login', height: 44),
              Tab(text: 'Sign up', height: 44),
            ],
          ),
        ),
        const SizedBox(height: 22),

        SizedBox(
          height: 440,
          child: TabBarView(
            controller: _tabs,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _LoginForm(isLibrarian: _isLibrarian),
              _SignupFlow(isLibrarian: _isLibrarian),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// LOGIN form
// ═══════════════════════════════════════════════════════════════════
class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.isLibrarian});
  final bool isLibrarian;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _num = TextEditingController();
  final _pw = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _num.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthState>();
    auth.clearError();

    final n = _num.text.trim();
    final p = _pw.text;
    if (n.isEmpty || p.isEmpty) {
      _snack('Enter student number and password');
      return;
    }
    setState(() => _busy = true);
    final ok = await auth.login(studentNumber: n, password: p);
    if (!mounted) return;
    setState(() => _busy = false);

    if (ok) {
      final user = context.read<AuthState>().user;
      // warn if role mismatch (soft — allows)
      if (widget.isLibrarian && user != null && user.isStudent) {
        _snack('This is a student account. Redirecting to student home.');
      }
      context.go(DiiRoutes.home);
    } else {
      _snack(auth.error ?? 'Login failed');
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), backgroundColor: DiiColors.danger),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _num,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText:
                widget.isLibrarian ? 'Staff ID' : 'Student number',
            hintText: '240023001',
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _pw,
          obscureText: _obscure,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(_obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _busy ? null : _submit,
            icon: _busy
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.login_rounded, size: 18),
            label: const Text('Sign In'),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: DiiColors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: DiiColors.blue.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: DiiColors.blue.withValues(alpha: 0.7)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Forgot password? Contact the librarian.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: DiiColors.blue.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SIGNUP — 3-step for students, direct for librarians
// ═══════════════════════════════════════════════════════════════════
enum _Step { number, confirm, password }

class _SignupFlow extends StatefulWidget {
  const _SignupFlow({required this.isLibrarian});
  final bool isLibrarian;

  @override
  State<_SignupFlow> createState() => _SignupFlowState();
}

class _SignupFlowState extends State<_SignupFlow> {
  final _num = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  _Step _step = _Step.number;
  Map<String, dynamic>? _roster;

  @override
  void dispose() {
    _num.dispose();
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final n = _num.text.trim();
    if (!RegExp(r'^\d{6,12}$').hasMatch(n)) {
      _snack('Student number must be 6-12 digits');
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = context.read<AuthRepository>();
      final res =
          await repo.lookupRoster(n).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      setState(() => _busy = false);
      switch (res) {
        case Ok(:final data):
          if (data['has_account'] == true) {
            _snack('This number already has an account. Use Login tab.');
            return;
          }
          setState(() {
            _roster = data;
            _step = _Step.confirm;
          });
        case Err(:final error):
          _snack(error.toString());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack('Error: $e');
    }
  }

  Future<void> _create() async {
    final p = _pw.text;
    final p2 = _pw2.text;
    if (p.length < 8) {
      _snack('Password must be at least 8 characters');
      return;
    }
    if (p != p2) {
      _snack('Passwords do not match');
      return;
    }

    setState(() => _busy = true);
    final auth = context.read<AuthState>();
    final ok = await auth.signup(
      studentNumber: _num.text.trim(),
      name: _roster!['name'] as String,
      password: p,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      context.go(DiiRoutes.home);
    } else {
      _snack(auth.error ?? 'Signup failed');
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), backgroundColor: DiiColors.danger),
      );

  @override
  Widget build(BuildContext context) {
    if (widget.isLibrarian) return _librarianMessage();
    switch (_step) {
      case _Step.number:
        return _stepNumber();
      case _Step.confirm:
        return _stepConfirm();
      case _Step.password:
        return _stepPassword();
    }
  }

  Widget _librarianMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Create Librarian Account',
            style: GoogleFonts.interTight(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: DiiColors.textPrimary,
            )),
        const SizedBox(height: 4),
        const Text(
          'Register yourself as a librarian to manage the library.',
          style: TextStyle(
            fontSize: 12.5,
            color: DiiColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        _librarianForm(),
      ],
    );
  }

  Widget _librarianForm() {
    final staffNum = TextEditingController();
    final name = TextEditingController();
    final dept = TextEditingController();
    final p1 = TextEditingController();
    final p2 = TextEditingController();
    bool obscure = true;
    bool busy = false;

    return StatefulBuilder(
      builder: (context, setInner) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: staffNum,
            decoration: const InputDecoration(
              labelText: 'Staff ID',
              hintText: 'LIB001',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: name,
            decoration: const InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: dept,
            decoration: const InputDecoration(
              labelText: 'Department (optional)',
              prefixIcon: Icon(Icons.school_outlined),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: p1,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: 'Password (min 8)',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () => setInner(() => obscure = !obscure),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: p2,
            obscureText: obscure,
            decoration: const InputDecoration(
              labelText: 'Confirm password',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      final sn = staffNum.text.trim();
                      final nm = name.text.trim();
                      final pw = p1.text;
                      final pw2 = p2.text;
                      if (sn.length < 4) {
                        _snack('Staff ID must be at least 4 characters');
                        return;
                      }
                      if (nm.length < 2) {
                        _snack('Enter your full name');
                        return;
                      }
                      if (pw.length < 8) {
                        _snack('Password must be at least 8 characters');
                        return;
                      }
                      if (pw != pw2) {
                        _snack('Passwords do not match');
                        return;
                      }

                      setInner(() => busy = true);
                      final auth = context.read<AuthState>();
                      final repo = context.read<AuthRepository>();
                      final res = await repo.librarianSignup(
                        staffNumber: sn,
                        name: nm,
                        password: pw,
                        department: dept.text.trim().isEmpty
                            ? null
                            : dept.text.trim(),
                      );
                      if (!mounted) return;
                      setInner(() => busy = false);

                      switch (res) {
                        case Ok(:final data):
                          auth.updateUser(data);
                          // ignore: use_build_context_synchronously
                          context.go(DiiRoutes.home);
                        case Err(:final error):
                          _snack(error.toString());
                      }
                    },
              icon: busy
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Create Librarian Account'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepNumber() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Look up your account',
            style: GoogleFonts.interTight(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: DiiColors.textPrimary,
            )),
        const SizedBox(height: 4),
        const Text(
          'Enter your student number — we will find your details.',
          style: TextStyle(
            fontSize: 12.5,
            color: DiiColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _num,
          keyboardType: TextInputType.number,
          onSubmitted: (_) => _lookup(),
          decoration: const InputDecoration(
            labelText: 'Student number',
            hintText: '240023001',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _busy ? null : _lookup,
            icon: _busy
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.search_rounded, size: 18),
            label: const Text('Look Up My Account'),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: DiiColors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: DiiColors.blue.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: DiiColors.blue.withValues(alpha: 0.7)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'If your number is not found, ask the librarian to register you.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: DiiColors.blue.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepConfirm() {
    final r = _roster!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Confirm your details',
            style: GoogleFonts.interTight(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: DiiColors.textPrimary,
            )),
        const SizedBox(height: 4),
        const Text(
          'We found your record. Please confirm below.',
          style: TextStyle(
            fontSize: 12.5,
            color: DiiColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DiiColors.blue.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DiiColors.blue.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: const BoxDecoration(
                      color: DiiColors.blue,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(r['name'] as String),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r['name'] as String,
                            style: GoogleFonts.interTight(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: DiiColors.textPrimary,
                            )),
                        Text(r['student_number'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: DiiColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(
                  height: 1,
                  color: DiiColors.border.withValues(alpha: 0.6)),
              const SizedBox(height: 12),
              _row(Icons.email_outlined, 'Email', r['email'] as String),
              const SizedBox(height: 8),
              _row(Icons.school_outlined, 'Department',
                  (r['department'] ?? '—') as String),
              const SizedBox(height: 8),
              _row(Icons.timeline_rounded, 'Year',
                  r['year'] == null ? '—' : 'Year ${r['year']}'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _step = _Step.password),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Yes, this is me'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: () => setState(() {
              _step = _Step.number;
              _roster = null;
            }),
            child: const Text('Not me — try again'),
          ),
        ),
      ],
    );
  }

  Widget _stepPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Set your password',
            style: GoogleFonts.interTight(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: DiiColors.textPrimary,
            )),
        const SizedBox(height: 4),
        Text(
          'For ${_roster!['email']}',
          style: const TextStyle(
            fontSize: 12.5,
            color: DiiColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _pw,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: 'Password (min 8)',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(_obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pw2,
          obscureText: _obscure,
          onSubmitted: (_) => _create(),
          decoration: const InputDecoration(
            labelText: 'Confirm password',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _busy ? null : _create,
            icon: _busy
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.person_add_rounded, size: 18),
            label: const Text('Create Account'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: TextButton.icon(
            onPressed: () => setState(() => _step = _Step.confirm),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Back'),
          ),
        ),
      ],
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: DiiColors.blue),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: DiiColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: DiiColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.isEmpty || p.first.isEmpty) return '?';
    if (p.length == 1) return p.first[0].toUpperCase();
    return (p.first[0] + p.last[0]).toUpperCase();
  }
}
