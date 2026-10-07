import '/flutter_flow/flutter_flow_theme.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable student info card for request and return lists.
/// Loads the student's photo + profile once, then caches it.
class StudentInfoTile extends StatefulWidget {
  const StudentInfoTile({
    super.key,
    required this.userId,
    this.name,
    this.studentNumber,
    this.email,
    this.department,
    this.year,
  });

  final String userId;
  final String? name;
  final String? studentNumber;
  final String? email;
  final String? department;
  final int? year;

  static final Map<String, Map<String, dynamic>> _cache = {};

  @override
  State<StudentInfoTile> createState() => _StudentInfoTileState();
}

class _StudentInfoTileState extends State<StudentInfoTile> {
  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kYellow = Color(0xFFFFC107);

  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.userId.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    // Use cache if present
    if (StudentInfoTile._cache.containsKey(widget.userId)) {
      setState(() {
        _profile = StudentInfoTile._cache[widget.userId];
        _loading = false;
      });
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (snap.exists) {
        final data = snap.data() ?? {};
        StudentInfoTile._cache[widget.userId] = data;
        if (!mounted) return;
        setState(() {
          _profile = data;
          _loading = false;
        });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _val(String? fallback, String key) {
    final fromWidget = fallback ?? '';
    if (fromWidget.isNotEmpty) return fromWidget;
    return (_profile?[key] ?? '').toString();
  }

  int _yearVal() {
    if (widget.year != null && widget.year! > 0) return widget.year!;
    return (_profile?['year'] as num?)?.toInt() ?? 0;
  }

  String _photo() {
    final p = (_profile?['photoUrl'] ?? '').toString();
    return p;
  }

  @override
  Widget build(BuildContext context) {
    final name = _val(widget.name, 'name');
    final num = _val(widget.studentNumber, 'studentNumber');
    final email = _val(widget.email, 'email');
    final dept = _val(widget.department, 'department');
    final year = _yearVal();
    final photo = _photo();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _avatar(photo, name),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'Unknown student' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.interTight(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              const SizedBox(height: 2),
              if (num.isNotEmpty)
                Text('#$num',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: kBlue,
                    )),
              if (email.isNotEmpty)
                Text(email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    )),
              if (dept.isNotEmpty || year > 0) ...[
                const SizedBox(height: 2),
                Text(
                  [
                    if (dept.isNotEmpty) dept,
                    if (year > 0) 'Year $year',
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatar(String photoUrl, String name) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kBlue.withOpacity(0.15),
        border: Border.all(color: kYellow, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildAvatarChild(photoUrl, name),
    );
  }

  Widget _buildAvatarChild(String photoUrl, String name) {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 16, height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (photoUrl.startsWith('data:image')) {
      try {
        final b64 = photoUrl.split(',').last;
        return Image.memory(base64Decode(b64), fit: BoxFit.cover);
      } catch (_) {}
    }
    if (photoUrl.startsWith('http')) {
      return Image.network(photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initial(name));
    }
    return _initial(name);
  }

  Widget _initial(String name) {
    return Container(
      color: kBlue,
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}
