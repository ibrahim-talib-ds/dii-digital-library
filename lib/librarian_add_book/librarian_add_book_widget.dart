import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import 'librarian_add_book_model.dart';
export 'librarian_add_book_model.dart';

/// Stub page for Add Book.
/// Purpose: Add a new book to the catalog
class LibrarianAddBookWidget extends StatefulWidget {
  const LibrarianAddBookWidget({super.key});

  static String routeName = 'LibrarianAddBook';
  static String routePath = '/librarianAddBook';

  @override
  State<LibrarianAddBookWidget> createState() => _LibrarianAddBookWidgetState();
}

class _LibrarianAddBookWidgetState extends State<LibrarianAddBookWidget> {
  late LibrarianAddBookModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LibrarianAddBookModel());
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
        title: Text('Add Book'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.library_add_outlined, size: 56, color: const Color(0xFF0A1E5C)),
                const SizedBox(height: 16),
                Text(
                  'Add Book',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add a new book to the catalog',
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
