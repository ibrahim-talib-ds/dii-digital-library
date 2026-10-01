import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import 'librarian_students_model.dart';
export 'librarian_students_model.dart';

/// Stub page for Students.
/// Purpose: View DII Library students
class LibrarianStudentsWidget extends StatefulWidget {
  const LibrarianStudentsWidget({super.key});

  static String routeName = 'LibrarianStudents';
  static String routePath = '/librarianStudents';

  @override
  State<LibrarianStudentsWidget> createState() => _LibrarianStudentsWidgetState();
}

class _LibrarianStudentsWidgetState extends State<LibrarianStudentsWidget> {
  late LibrarianStudentsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LibrarianStudentsModel());
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
        title: Text('Students'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline, size: 56, color: const Color(0xFF0A1E5C)),
                const SizedBox(height: 16),
                Text(
                  'Students',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'View DII Library students',
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
