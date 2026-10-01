import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import 'librarian_issue_model.dart';
export 'librarian_issue_model.dart';

/// Stub page for Issue Book.
/// Purpose: Issue a book to a student
class LibrarianIssueWidget extends StatefulWidget {
  const LibrarianIssueWidget({super.key});

  static String routeName = 'LibrarianIssue';
  static String routePath = '/librarianIssue';

  @override
  State<LibrarianIssueWidget> createState() => _LibrarianIssueWidgetState();
}

class _LibrarianIssueWidgetState extends State<LibrarianIssueWidget> {
  late LibrarianIssueModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LibrarianIssueModel());
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
        title: Text('Issue Book'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_scanner_rounded, size: 56, color: const Color(0xFF0A1E5C)),
                const SizedBox(height: 16),
                Text(
                  'Issue Book',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Issue a book to a student',
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
