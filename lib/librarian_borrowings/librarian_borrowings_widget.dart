import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import 'librarian_borrowings_model.dart';
export 'librarian_borrowings_model.dart';

/// Stub page for Borrowings.
/// Purpose: Full borrowings list
class LibrarianBorrowingsWidget extends StatefulWidget {
  const LibrarianBorrowingsWidget({super.key});

  static String routeName = 'LibrarianBorrowings';
  static String routePath = '/librarianBorrowings';

  @override
  State<LibrarianBorrowingsWidget> createState() => _LibrarianBorrowingsWidgetState();
}

class _LibrarianBorrowingsWidgetState extends State<LibrarianBorrowingsWidget> {
  late LibrarianBorrowingsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LibrarianBorrowingsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Borrowings'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.list_alt_rounded, size: 56, color: const Color(0xFF0A1E5C)),
                const SizedBox(height: 16),
                Text(
                  'Borrowings',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Full borrowings list',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Coming soon — wire up the real content here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
