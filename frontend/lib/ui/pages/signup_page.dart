import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../state/auth_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _studentNumber = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _department = TextEditingController();
  int? _year;

  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _studentNumber.dispose();
    _name.dispose();
    _password.dispose();
    _confirm.dispose();
    _department.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthState>();
    auth.clearError();

    final num = _studentNumber.text.trim();
    final name = _name.text.trim();
    final pw = _password.text;
    final confirm = _confirm.text;

    if (num.isEmpty || !RegExp(r'^\d{6,12}$').hasMatch(num)) {
      _snack('Student number must be 6-12 digits', DiiColors.red);
      return;
    }
    if (name.length < 2) {
      _snack('Enter your full name', DiiColors.red);
      return;
    }
    if (pw.length < 8) {
      _snack('Password must be at least 8 characters', DiiColors.red);
      return;
    }
    if (pw != confirm) {
      _snack('Passwords do not match', DiiColors.red);
      return;
    }

    setState(() => _busy = true);
    final ok = await auth.signup(
      studentNumber: num,
      name: name,
      password: pw,
      department: _department.text.trim().isEmpty
          ? null
          : _department.text.trim(),
      year: _year,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (ok) {
      context.go(DiiRoutes.home);
    } else {
      _snack(auth.error ?? 'Signup failed', DiiColors.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiiColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(DiiRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Join DII Library',
                    style: GoogleFonts.interTight(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: DiiColors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Use your student number — email is created automatically',
                    style: TextStyle(color: DiiColors.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _studentNumber,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Student number',
                      hintText: '240023001',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _department,
                    decoration: const InputDecoration(
                      labelText: 'Department (optional)',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _year,
                    decoration: const InputDecoration(
                      labelText: 'Year (optional)',
                      prefixIcon: Icon(Icons.timeline_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Year 1')),
                      DropdownMenuItem(value: 2, child: Text('Year 2')),
                      DropdownMenuItem(value: 3, child: Text('Year 3')),
                      DropdownMenuItem(value: 4, child: Text('Year 4')),
                    ],
                    onChanged: (v) => setState(() => _year = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password (min 8 chars)',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirm,
                    obscureText: _obscure,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white))
                          : const Text('Create Account'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => context.go(DiiRoutes.login),
                    child: const Text('I already have an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
