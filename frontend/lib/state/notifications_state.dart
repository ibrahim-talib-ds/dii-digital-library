import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/result.dart';
import '../data/api/api_exception.dart';
import '../data/models/notification.dart';
import '../data/repositories/notifications_repository.dart';

/// Holds the current user's notifications + unread count.
/// Subscribes to the SSE stream so the bell badge updates in real time.
class NotificationsState extends ChangeNotifier {
  NotificationsState({required NotificationsRepository repo}) : _repo = repo;

  final NotificationsRepository _repo;

  List<AppNotification> _items = const [];
  int _unread = 0;
  bool _loading = false;
  String? _error;

  StreamSubscription<String>? _sub;
  Timer? _reconnectTimer;

  List<AppNotification> get items => _items;
  int get unread => _unread;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();

    final res = await _repo.list();
    _loading = false;

    switch (res) {
      case Ok(:final data):
        _items = data;
        _unread = data.where((n) => !n.read).length;
        _error = null;
      case Err(:final error):
        _error =
            error is ApiException ? error.friendlyMessage : error.toString();
    }
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    final res = await _repo.markRead(id);
    if (res is Ok) {
      _items = _items
          .map((n) => n.id == id ? n.copyWith(read: true) : n)
          .toList();
      _unread = _items.where((n) => !n.read).length;
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    final res = await _repo.markAllRead();
    if (res is Ok) {
      _items = _items.map((n) => n.copyWith(read: true)).toList();
      _unread = 0;
      notifyListeners();
    }
  }

  void startStream() {
    _sub?.cancel();
    _sub = _repo.stream().listen(
          _onEvent,
          onError: (_) => _scheduleReconnect(),
          onDone: () => _scheduleReconnect(),
          cancelOnError: false,
        );
  }

  void _onEvent(String chunk) {
    final lines = chunk.split('\n');
    for (final line in lines) {
      if (!line.startsWith('data:')) continue;
      final raw = line.substring(5).trim();
      if (raw.isEmpty) continue;
      try {
        final obj = jsonDecode(raw) as Map<String, dynamic>;
        final count = (obj['unread'] as num?)?.toInt() ?? 0;
        if (count != _unread) {
          _unread = count;
          notifyListeners();
          if (count > 0) refresh();
        }
      } catch (_) {}
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), startStream);
  }

  void stopStream() {
    _sub?.cancel();
    _sub = null;
    _reconnectTimer?.cancel();
  }

  @override
  void dispose() {
    stopStream();
    super.dispose();
  }
}
