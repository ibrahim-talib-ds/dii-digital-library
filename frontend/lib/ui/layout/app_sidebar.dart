import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../state/auth_state.dart';
import '../components/user_avatar.dart';
import '../components/notification_bell.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem(this.label, this.icon, this.route);
}

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.currentRoute,
    this.compact = false,
  });

  final String currentRoute;
  final bool compact;

  static final List<_NavItem> _mainItems = [
    _NavItem('Home',         Icons.home_rounded,           DiiRoutes.home),
    _NavItem('Browse',       Icons.library_books_rounded,  DiiRoutes.browse),
    _NavItem('My Books',     Icons.book_rounded,           DiiRoutes.myBooks),
    _NavItem('History',      Icons.history_rounded,        DiiRoutes.history),
    _NavItem('Saved Books',  Icons.bookmark_outline_rounded, '/saved'),
    _NavItem('Messages',     Icons.chat_bubble_outline_rounded, '/messages'),
    _NavItem('Ibro_Ai',       Icons.auto_awesome_rounded,      '/ai'),
    _NavItem('Profile',      Icons.person_rounded,         DiiRoutes.profile),
  ];

  static final List<_NavItem> _staffItems = [
    _NavItem('Requests',     Icons.inbox_rounded,          DiiRoutes.borrowRequests),
    _NavItem('Returns',      Icons.assignment_return_rounded, DiiRoutes.receiveReturn),
    _NavItem('Manage Books', Icons.edit_note_rounded,      DiiRoutes.manageBooks),
    _NavItem('Students',     Icons.people_rounded,         DiiRoutes.students),
  ];

  static final List<_NavItem> _adminItems = [
    _NavItem('Users',        Icons.group_rounded,          DiiRoutes.manageUsers),
    _NavItem('Librarians',   Icons.badge_rounded,          DiiRoutes.manageLibrarians),
    _NavItem('Reports',      Icons.bar_chart_rounded,      DiiRoutes.reports),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final user = auth.user;
    final width = compact ? 72.0 : 260.0;

    return Material(
      color: DiiColors.deep,
      child: SizedBox(
        width: width,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Brand ───
              Padding(
                padding: EdgeInsets.fromLTRB(compact ? 16 : 20, 20, compact ? 16 : 20, 16),
                child: compact
                    ? Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: DiiColors.yellow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.menu_book_rounded,
                                color: DiiColors.blue, size: 22),
                          ),
                          const SizedBox(height: 8),
                          const NotificationBell(
                            iconColor: Colors.white,
                            iconSize: 22,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: DiiColors.yellow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.menu_book_rounded,
                                color: DiiColors.blue, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: 'DII ',
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Library',
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w900,
                                    color: DiiColors.yellow,
                                    fontSize: 18,
                                  ),
                                ),
                              ]),
                            ),
                          ),
                          const NotificationBell(
                            iconColor: Colors.white,
                            iconSize: 22,
                          ),
                        ],
                      ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              const SizedBox(height: 8),

              // ─── Links ───
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    if (!compact) _section('LIBRARY'),
                    ..._mainItems.map((it) => _link(context, it)),
                    if (user?.isStaff ?? false) ...[
                      const SizedBox(height: 12),
                      if (!compact) _section('STAFF TOOLS'),
                      ..._staffItems.map((it) => _link(context, it)),
                    ],
                    if (user?.isAdmin ?? false) ...[
                      const SizedBox(height: 12),
                      if (!compact) _section('ADMIN'),
                      ..._adminItems.map((it) => _link(context, it)),
                    ],
                  ],
                ),
              ),

              // ─── Account strip ───
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              _accountStrip(context, user?.name ?? 'Guest', user?.role.label ?? '',
                  compact: compact),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      );

  Widget _link(BuildContext context, _NavItem it) {
    final active = currentRoute == it.route;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: active ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.go(it.route),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: compact ? 0 : 12, vertical: 12),
            child: Row(
              mainAxisAlignment:
                  compact ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(it.icon,
                    size: 20,
                    color: active ? DiiColors.yellow : Colors.white.withValues(alpha: 0.75)),
                if (!compact) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      it.label,
                      style: GoogleFonts.inter(
                        color: active
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.75),
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (active)
                    Container(
                      width: 4, height: 20,
                      decoration: BoxDecoration(
                        color: DiiColors.yellow,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _accountStrip(BuildContext context, String name, String role,
      {required bool compact}) {
    return Padding(
      padding: EdgeInsets.all(compact ? 10 : 14),
      child: compact
          ? UserAvatar(
              name: name,
              imageUrl: context.read<AuthState>().user?.avatarUrl,
              size: 36,
              borderColor: DiiColors.yellow,
              borderWidth: 2,
            )
          : Row(
              children: [
                UserAvatar(
                  name: name,
                  imageUrl: context.read<AuthState>().user?.avatarUrl,
                  size: 36,
                  borderColor: DiiColors.yellow,
                  borderWidth: 2,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: DiiColors.yellow.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: GoogleFonts.inter(
                            color: DiiColors.yellow,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
