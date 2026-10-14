import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/breakpoints.dart';
import '../../core/colors.dart';
import '../../data/api/api_client.dart';
import '../layout/responsive_shell.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final api = context.read<ApiClient>();
    _future = api.get('/messages/inbox').then((res) {
      final data = res as Map<String, dynamic>;
      return (data['items'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = DiiBreakpoints.isPhone(context);

    return ResponsiveShell(
      currentRoute: '/messages',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isPhone ? 14 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Messages',
                                style: GoogleFonts.interTight(
                                  fontSize: isPhone ? 22 : 28,
                                  fontWeight: FontWeight.w900,
                                  color: DiiColors.textPrimary,
                                  letterSpacing: -0.5,
                                )),
                            const SizedBox(height: 4),
                            const Text('Conversations with staff and students',
                                style: TextStyle(
                                  color: DiiColors.textSecondary,
                                  fontSize: 13,
                                )),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(_reload),
                        icon: const Icon(Icons.refresh_rounded),
                        color: DiiColors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final list = snap.data ?? [];
                      if (list.isEmpty) return _empty();
                      return Column(
                        children: [
                          for (final row in list) ...[
                            _conversation(row),
                            const SizedBox(height: 10),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _conversation(Map<String, dynamic> row) {
    final partnerId = row['partner_id'] as String;
    final name = row['partner_name'] as String? ?? 'User';
    final role = row['partner_role'] as String? ?? 'student';
    final lastBody = row['last_body'] as String? ?? '';
    final unread = (row['unread'] as num?)?.toInt() ?? 0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go('/chat/$partnerId'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: unread > 0
                  ? DiiColors.blue.withValues(alpha: 0.4)
                  : DiiColors.border,
              width: unread > 0 ? 1.4 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: const BoxDecoration(
                  color: DiiColors.blue,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(name),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
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
                        Expanded(
                          child: Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.interTight(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: DiiColors.textPrimary,
                              )),
                        ),
                        Text(role.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: DiiColors.blue,
                              letterSpacing: 0.5,
                            )),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(lastBody,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: DiiColors.textSecondary
                              .withValues(alpha: unread > 0 ? 1 : 0.8),
                          fontWeight:
                              unread > 0 ? FontWeight.w600 : FontWeight.w400,
                        )),
                  ],
                ),
              ),
              if (unread > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: DiiColors.yellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$unread',
                      style: GoogleFonts.inter(
                        color: DiiColors.blue,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      )),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty() => Container(
        padding: const EdgeInsets.all(60),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 64, color: DiiColors.blue.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No messages yet',
                style: GoogleFonts.interTight(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.blue,
                )),
            const SizedBox(height: 6),
            const Text('Messages from librarians will appear here',
                style: TextStyle(color: DiiColors.textSecondary)),
          ],
        ),
      );

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.isEmpty || p.first.isEmpty) return '?';
    if (p.length == 1) return p.first[0].toUpperCase();
    return (p.first[0] + p.last[0]).toUpperCase();
  }
}
