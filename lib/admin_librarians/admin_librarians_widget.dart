import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_librarians_model.dart';
import '/components/responsive_shell.dart';
import '/components/app_sidebar.dart';
import '/custom/role_utils.dart';
export 'admin_librarians_model.dart';

class AdminLibrariansWidget extends StatefulWidget {
  const AdminLibrariansWidget({super.key});

  static String routeName = 'AdminLibrarians';
  static String routePath = '/adminLibrarians';

  @override
  State<AdminLibrariansWidget> createState() => _AdminLibrariansWidgetState();
}

class _AdminLibrariansWidgetState extends State<AdminLibrariansWidget> {
  bool _roleChecked = false;

  late AdminLibrariansModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue = Color(0xFF0A1E5C);
  static const Color kRed = Color(0xFFDC0F0F);
  static const Color kPurple = Color(0xFF7B1FA2);

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await loadCurrentUserRole();
      if (mounted) setState(() => _roleChecked = true);
    });
    _model = createModel(context, () => AdminLibrariansModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _openDialog({DocumentSnapshot? existing}) {
    final data = existing?.data() as Map<String, dynamic>?;

    final nameCtl = TextEditingController(text: (data?['name'] ?? '').toString());
    final emailCtl = TextEditingController(text: (data?['email'] ?? '').toString());
    final numCtl = TextEditingController(text: (data?['studentNumber'] ?? '').toString());
    final limitCtl = TextEditingController(
        text: ((data?['borrowLimit'] as num?)?.toInt() ?? 5).toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Librarian' : 'Edit Librarian'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtl,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtl,
                enabled: existing == null,
                decoration: const InputDecoration(
                  labelText: 'DII Email * (e.g. staff@dii.tj)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: numCtl,
                decoration: const InputDecoration(
                  labelText: 'Staff Number (e.g. DII-STAFF-001)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: limitCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Borrow Limit',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtl.text.trim();
              final email = emailCtl.text.trim().toLowerCase();
              final num = numCtl.text.trim();
              final limit = int.tryParse(limitCtl.text) ?? 5;

              if (name.isEmpty || email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and email required')),
                );
                return;
              }

              try {
                if (existing == null) {
                  final docId = email;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(docId)
                      .set({
                    'name': name,
                    'email': email,
                    'studentNumber': num,
                    'role': 'librarian',
                    'status': 'active',
                    'active': true,
                    'borrowLimit': limit,
                    'createdAt': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));
                } else {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(existing.id)
                      .update({
                    'name': name,
                    'studentNumber': num,
                    'borrowLimit': limit,
                  });
                }
                if (ctx.mounted) Navigator.pop(ctx);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(existing == null ? 'Librarian added' : 'Saved'),
                    backgroundColor: kBlue,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed: $e'), backgroundColor: kRed),
                );
              }
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(String uid, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete librarian?'),
        content: Text('"$name" will be removed from the students collection.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: kRed, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted'), backgroundColor: kBlue),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_roleChecked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!isAdminUser()) return _accessDenied(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).alternate),
        title: Text('Librarians',
            style: GoogleFonts.interTight(
              color: FlutterFlowTheme.of(context).alternate,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            )),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(),
        backgroundColor: kPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Librarian'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'librarian')
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Text('No librarians yet',
                  style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final m = doc.data() as Map<String, dynamic>;
              final name = (m['name'] ?? 'Unknown').toString();
              final email = (m['email'] ?? '').toString();
              final num = (m['studentNumber'] ?? '').toString();

              return Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).alternate.withOpacity(0.2),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: kPurple.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: kPurple,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.interTight(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              )),
                          Text(email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              )),
                          if (num.isNotEmpty)
                            Text('#$num',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                )),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _openDialog(existing: doc),
                      icon: const Icon(Icons.edit_rounded, size: 20),
                    ),
                    IconButton(
                      onPressed: () => _delete(doc.id, name),
                      icon: const Icon(Icons.delete_outline_rounded, color: kRed, size: 20),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ─── Access denied screen ───
  Widget _accessDenied(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: GoogleFonts.interTight(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to view this page.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.safePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
