import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_books_model.dart';
import '/components/responsive_shell.dart';
import '/components/app_sidebar.dart';
export 'admin_books_model.dart';

class AdminBooksWidget extends StatefulWidget {
  const AdminBooksWidget({super.key});

  static String routeName = 'AdminBooks';
  static String routePath = '/adminBooks';

  @override
  State<AdminBooksWidget> createState() => _AdminBooksWidgetState();
}

class _AdminBooksWidgetState extends State<AdminBooksWidget> {
  late AdminBooksModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue = Color(0xFF0A1E5C);
  static const Color kRed = Color(0xFFDC0F0F);

  String _search = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminBooksModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _delete(String docId, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete book?'),
        content: Text('"$title" will be permanently removed.'),
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
      await FirebaseFirestore.instance.collection('books').doc(docId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted'), backgroundColor: kBlue),
      );
    }
  }

  void _showAddEditDialog({DocumentSnapshot? existing}) {
    final data = existing?.data() as Map<String, dynamic>?;
    final titleCtl = TextEditingController(text: (data?['title'] ?? '').toString());
    final authorCtl = TextEditingController(text: (data?['author'] ?? '').toString());
    final catCtl = TextEditingController(text: (data?['category'] ?? '').toString());
    final codeCtl = TextEditingController(text: (data?['bookCode'] ?? '').toString());
    final coverCtl = TextEditingController(text: (data?['Cover_url'] ?? '').toString());
    final pdfCtl = TextEditingController(text: (data?['pdfUrl'] ?? '').toString());
    final descCtl = TextEditingController(text: (data?['description'] ?? '').toString());
    final totalCtl = TextEditingController(
        text: ((data?['totalCopies'] as num?)?.toInt() ?? 1).toString());
    final availCtl = TextEditingController(
        text: ((data?['availableCopies'] as num?)?.toInt() ?? 1).toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Book' : 'Edit Book'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tf(titleCtl, 'Title'),
              _tf(authorCtl, 'Author'),
              _tf(catCtl, 'Category'),
              _tf(codeCtl, 'Book Code (e.g. CS-024)'),
              _tf(coverCtl, 'Cover Image URL'),
              _tf(pdfCtl, 'PDF URL'),
              _tf(descCtl, 'Description', lines: 3),
              _tf(totalCtl, 'Total Copies', number: true),
              _tf(availCtl, 'Available Copies', number: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final payload = {
                'title': titleCtl.text.trim(),
                'author': authorCtl.text.trim(),
                'category': catCtl.text.trim(),
                'bookCode': codeCtl.text.trim(),
                'Cover_url': coverCtl.text.trim(),
                'pdfUrl': pdfCtl.text.trim(),
                'description': descCtl.text.trim(),
                'totalCopies': int.tryParse(totalCtl.text) ?? 1,
                'availableCopies': int.tryParse(availCtl.text) ?? 1,
                'status': 'active',
                'active': true,
                'createdAt': FieldValue.serverTimestamp(),
              };
              if (existing == null) {
                await FirebaseFirestore.instance.collection('books').add(payload);
              } else {
                await FirebaseFirestore.instance
                    .collection('books')
                    .doc(existing.id)
                    .update(payload);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Widget _tf(TextEditingController c, String label, {int lines = 1, bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        maxLines: lines,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
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
        title: Text('Manage Books',
            style: GoogleFonts.interTight(
              color: FlutterFlowTheme.of(context).alternate,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            )),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: kBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Book'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by title or author',
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('books')
                  .orderBy('title')
                  .snapshots(),
              builder: (context, snap) {
                if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                var docs = snap.data!.docs;
                if (_search.isNotEmpty) {
                  docs = docs.where((d) {
                    final m = d.data() as Map<String, dynamic>;
                    return ('${m['title']} ${m['author']}'.toLowerCase()).contains(_search);
                  }).toList();
                }
                if (docs.isEmpty) {
                  return const Center(child: Text('No books'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final m = doc.data() as Map<String, dynamic>;
                    final title = (m['title'] ?? '').toString();
                    final author = (m['author'] ?? '').toString();
                    final cat = (m['category'] ?? '').toString();
                    final code = (m['bookCode'] ?? '').toString();
                    final cover = (m['Cover_url'] ?? '').toString();
                    final total = (m['totalCopies'] as num?)?.toInt() ?? 0;
                    final avail = (m['availableCopies'] as num?)?.toInt() ?? 0;

                    return Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate.withOpacity(0.2),
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: cover.isNotEmpty
                                ? Image.network(cover,
                                    width: 48, height: 68, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                          width: 48, height: 68,
                                          color: FlutterFlowTheme.of(context).alternate,
                                          child: const Icon(Icons.menu_book_rounded),
                                        ))
                                : Container(
                                    width: 48, height: 68,
                                    color: FlutterFlowTheme.of(context).alternate,
                                    child: const Icon(Icons.menu_book_rounded),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.interTight(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    )),
                                Text(author,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    )),
                                Row(
                                  children: [
                                    if (cat.isNotEmpty)
                                      Text(cat,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                          )),
                                    if (code.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Text('· $code',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                          )),
                                    ],
                                    const SizedBox(width: 6),
                                    Text('· $avail/$total',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: avail > 0 ? kBlue : kRed,
                                          fontWeight: FontWeight.w700,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showAddEditDialog(existing: doc),
                            icon: const Icon(Icons.edit_rounded),
                          ),
                          IconButton(
                            onPressed: () => _delete(doc.id, title),
                            icon: const Icon(Icons.delete_outline_rounded, color: kRed),
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
