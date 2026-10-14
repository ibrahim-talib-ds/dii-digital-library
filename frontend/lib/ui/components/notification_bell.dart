import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../data/models/enums.dart';
import '../../data/models/notification.dart';
import '../../state/notifications_state.dart';
import '../../state/auth_state.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({
    super.key,
    this.iconColor = Colors.white,
    this.iconSize = 22,
  });

  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationsState>();
    final count = state.unread;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            count > 0
                ? Icons.notifications_rounded
                : Icons.notifications_none_rounded,
            color: iconColor,
            size: iconSize,
          ),
          tooltip: 'Notifications',
          onPressed: () => _openSheet(context),
        ),
        if (count > 0)
          Positioned(
            right: 4, top: 4,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 18),
                decoration: BoxDecoration(
                  color: DiiColors.danger,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openSheet(BuildContext context) async {
    final state = context.read<NotificationsState>();
    await state.refresh();
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NotificationSheet(),
    );
  }
}

class _NotificationSheet extends StatelessWidget {
  const _NotificationSheet();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationsState>();
    final items = state.items;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
                child: Row(
                  children: [
                    Text('Notifications',
                        style: GoogleFonts.interTight(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: DiiColors.blue,
                        )),
                    const Spacer(),
                    TextButton(
                      onPressed: state.unread == 0
                          ? null
                          : () => state.markAllRead(),
                      child: const Text('Mark all read'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              if (state.loading && items.isEmpty)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (items.isEmpty)
                Expanded(child: _empty())
              else
                Expanded(
                  child: ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                    itemBuilder: (context, i) => _row(context, state, items[i]),
                  ),
                ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_off_outlined,
                  size: 56,
                  color: DiiColors.blue.withValues(alpha: 0.2)),
              const SizedBox(height: 12),
              const Text('You are all caught up',
                  style: TextStyle(color: DiiColors.textSecondary)),
            ],
          ),
        ),
      );


  void _navigateToSource(BuildContext context, AppNotification n) {
    final role = context.read<AuthState>().user?.role;
    final isStaff = role == UserRole.librarian || role == UserRole.admin;

    // message → open chat thread with the sender
    if (n.relatedType == 'message' && n.relatedId != null) {
      context.go('/chat/${n.relatedId}');
      return;
    }

    switch (n.type) {
      case NotificationType.request:
        // Staff: pending request
        if (isStaff) {
          context.go(DiiRoutes.borrowRequests);
        } else {
          context.go(DiiRoutes.myBooks);
        }
        break;
      case NotificationType.approved:
      case NotificationType.returned:
      case NotificationType.overdue:
        // Student sees their loan; staff sees returns list
        if (isStaff) {
          context.go(DiiRoutes.receiveReturn);
        } else {
          context.go(DiiRoutes.myBooks);
        }
        break;
      case NotificationType.rejected:
        context.go(DiiRoutes.history);
        break;
      default:
        context.go(DiiRoutes.home);
    }
  }

  Widget _row(BuildContext context, NotificationsState state, AppNotification n) {
    final (icon, color) = _iconFor(n.type);
    final isRead = n.read;

    return Material(
      color: isRead ? Colors.transparent : DiiColors.blue.withValues(alpha: 0.04),
      child: InkWell(
        onTap: () {
          state.markRead(n.id);
          Navigator.of(context).pop();
          _navigateToSource(context, n);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(n.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontWeight: isRead
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                                fontSize: 14,
                                color: DiiColors.blue,
                              )),
                        ),
                        const SizedBox(width: 8),
                        Text(_relTime(n.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black.withValues(alpha: 0.45),
                            )),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(n.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withValues(alpha: 0.65),
                        )),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 6),
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: DiiColors.danger, shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _iconFor(NotificationType t) => switch (t) {
        NotificationType.request  => (Icons.inbox_rounded, DiiColors.yellow),
        NotificationType.approved => (Icons.check_circle_rounded, DiiColors.blue),
        NotificationType.rejected => (Icons.cancel_rounded, DiiColors.danger),
        NotificationType.returned => (Icons.assignment_turned_in_rounded, DiiColors.blue),
        NotificationType.overdue  => (Icons.warning_amber_rounded, DiiColors.danger),
        NotificationType.info     => (Icons.info_rounded, DiiColors.blue),
      };

  String _relTime(DateTime when) {
    final d = DateTime.now().difference(when);
    if (d.inSeconds < 60) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours   < 24) return '${d.inHours}h';
    if (d.inDays    < 7)  return '${d.inDays}d';
    return '${when.month}/${when.day}';
  }
}
