import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_students_model.dart';
import '/components/responsive_shell.dart';
import '/components/app_sidebar.dart';
export 'admin_students_model.dart';

class AdminStudentsWidget extends StatefulWidget {
  const AdminStudentsWidget({super.key});

  static String routeName = 'AdminStudents';
  static String routePath = '/adminStudents';

  @override
  State<AdminStudentsWidget> createState() => _AdminStudentsWidgetState();
}

class _AdminStudentsWidgetState extends State<AdminStudentsWidget> {
  late AdminStudentsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue = Color(0xFF0A1E5C);
  static const Color kRed = Color(0xFFDC0F0F);
  static const Color kAccent = Color(0xFF3B82F6);
  static const Color kPurple = Color(0xFF7B1FA2);

  String _search = '';
  String _roleFilter = 'all';
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminStudentsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin': return kBlue;
      case 'librarian': return kPurple;
      default: return kBlue;
    }
  }

  Future<void> _toggleBlock(String uid, String currentStatus) async {
    if (_busy.contains(uid)) return;
    setState(() => _busy.add(uid));
    try {
      final newStatus = currentStatus == 'blocked' ? 'active' : 'blocked';
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'status': newStatus,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status → $newStatus'), backgroundColor: kBlue),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: kRed),
      );
    } finally {
      if (mounted) setState(() => _busy.remove(uid));
    }
  }

  Future<void> _delete(String uid, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete student?'),
        content: Text(
            '"$name" Firestore record will be deleted.\n\nNote: their login (Firebase Auth) is NOT removed by this action.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: kRed, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student record deleted'), backgroundColor: kBlue),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e'), backgroundColor: kRed),
      );
    }
  }

  void _openDialog({DocumentSnapshot? existing}) {
    final data = existing?.data() as Map<String, dynamic>?;

    final nameCtl = TextEditingController(text: (data?['name'] ?? '').toString());
    final emailCtl = TextEditingController(text: (data?['email'] ?? '').toString());
    final numCtl = TextEditingController(text: (data?['studentNumber'] ?? '').toString());
    final deptCtl = TextEditingController(text: (data?['department'] ?? '').toString());
    final limitCtl = TextEditingController(
        text: ((data?['borrowLimit'] as num?)?.toInt() ?? 3).toString());
    String role = (data?['role'] ?? 'student').toString();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(existing == null ? 'Add Student' : 'Edit Student'),
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
                    labelText: 'DII Email * (e.g. 240023018@dii.tj)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: numCtl,
                  decoration: const InputDecoration(
                    labelText: 'Student Number',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: deptCtl,
                  decoration: const InputDecoration(
                    labelText: 'Department',
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
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Student')),
                    DropdownMenuItem(value: 'librarian', child: Text('Librarian')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (v) => setLocal(() => role = v ?? 'student'),
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
                final dept = deptCtl.text.trim();
                final limit = int.tryParse(limitCtl.text) ?? 3;

                if (name.isEmpty || email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name and email required')),
                  );
                  return;
                }
                if (!email.endsWith('@dii.tj')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email must end with @dii.tj')),
                  );
                  return;
                }

                try {
                  if (existing == null) {
                    // Use email as document ID so signup flow can link later
                    final docId = email;
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(docId)
                        .set({
                      'name': name,
                      'email': email,
                      'studentNumber': num,
                      'department': dept,
                      'role': role,
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
                      'department': dept,
                      'role': role,
                      'borrowLimit': limit,
                    });
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(existing == null ? 'Student added' : 'Saved'),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).alternate),
        title: Text('Manage Students',
            style: GoogleFonts.interTight(
              color: FlutterFlowTheme.of(context).alternate,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            )),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(),
        backgroundColor: kBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Student'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by name, email, or student number',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final r in ['all', 'student', 'librarian', 'admin'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(r.toUpperCase()),
                        selected: _roleFilter == r,
                        onSelected: (_) => setState(() => _roleFilter = r),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snap.data!.docs;
                if (_roleFilter != 'all') {
                  docs = docs
                      .where((d) =>
                          ((d.data() as Map)['role'] ?? 'student') == _roleFilter)
                      .toList();
                }
                if (_search.isNotEmpty) {
                  docs = docs.where((d) {
                    final m = d.data() as Map<String, dynamic>;
                    final hay = [
                      m['name'] ?? '',
                      m['email'] ?? '',
                      m['studentNumber'] ?? '',
                    ].join(' ').toLowerCase();
                    return hay.contains(_search);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Text('No students',
                        style: TextStyle(
                          color: FlutterFlowTheme.of(context).secondaryText,
                        )),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final m = doc.data() as Map<String, dynamic>;
                    final name = (m['name'] ?? 'Unknown').toString();
                    final email = (m['email'] ?? '').toString();
                    final num = (m['studentNumber'] ?? '').toString();
                    final dept = (m['department'] ?? '').toString();
                    final role = (m['role'] ?? 'student').toString();
                    final status = (m['status'] ?? 'active').toString();
                    final blocked = status == 'blocked';
                    final busy = _busy.contains(doc.id);

                    return Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: blocked
                              ? kRed.withOpacity(0.4)
                              : FlutterFlowTheme.of(context).alternate.withOpacity(0.2),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: _roleColor(role).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  color: _roleColor(role),
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
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.interTight(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          )),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: _roleColor(role).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(role.toUpperCase(),
                                          style: TextStyle(
                                            color: _roleColor(role),
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.4,
                                          )),
                                    ),
                                    if (blocked) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: kRed.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('BLOCKED',
                                            style: TextStyle(
                                              color: kRed,
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.4,
                                            )),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    )),
                                if (num.isNotEmpty || dept.isNotEmpty)
                                  Text(
                                    [if (num.isNotEmpty) '#$num', if (dept.isNotEmpty) dept].join(' · '),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    )),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () => _openDialog(existing: doc),
                            icon: const Icon(Icons.edit_rounded, size: 20),
                          ),
                          if (role != 'admin')
                            IconButton(
                              tooltip: blocked ? 'Unblock' : 'Block',
                              onPressed: busy ? null : () => _toggleBlock(doc.id, status),
                              icon: Icon(
                                blocked ? Icons.lock_open_rounded : Icons.block_rounded,
                                color: blocked ? kBlue : kRed,
                                size: 20,
                              ),
                            ),
                          IconButton(
                            tooltip: 'Delete',
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
          ),
        ],
      ),
    );
  }
}
