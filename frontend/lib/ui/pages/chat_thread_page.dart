import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/breakpoints.dart';
import '../../core/colors.dart';
import '../../data/api/api_client.dart';
import '../layout/responsive_shell.dart';

class ChatThreadPage extends StatefulWidget {
  const ChatThreadPage({super.key, required this.partnerId});

  final String partnerId;

  @override
  State<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<ChatThreadPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [];
  String _partnerName = 'Loading...';
  String _partnerRole = 'student';
  bool _busy = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final api = context.read<ApiClient>();
    try {
      final res = await api.get('/messages/thread/${widget.partnerId}');
      if (!mounted) return;
      final data = res as Map<String, dynamic>;
      final partner = data['partner'] as Map<String, dynamic>;
      final list = (data['messages'] as List<dynamic>)
          .map((e) => _Msg(
                body: (e as Map)['body'] as String,
                mine: e['mine'] as bool,
              ))
          .toList();
      setState(() {
        _partnerName = partner['name'] as String? ?? 'User';
        _partnerRole = partner['role'] as String? ?? 'student';
        _messages.addAll(list);
        _loading = false;
      });
      _scrollDown();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _busy) return;

    setState(() {
      _messages.add(_Msg(body: text, mine: true));
      _busy = true;
      _controller.clear();
    });
    _scrollDown();

    final api = context.read<ApiClient>();
    try {
      await api.post('/messages', body: {
        'recipient_id': widget.partnerId,
        'body': text,
      });
      if (!mounted) return;
      setState(() => _busy = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(body: 'Failed: $e', mine: false, error: true));
        _busy = false;
      });
    }
    _scrollDown();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = DiiBreakpoints.isPhone(context);

    return ResponsiveShell(
      currentRoute: '/chat',
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isPhone ? 0 : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isPhone ? 0 : 14),
                  border: isPhone ? null : Border.all(color: DiiColors.border),
                ),
                child: Column(
                  children: [
                    _header(),
                    Expanded(child: _body()),
                    _inputBar(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [DiiColors.blue, DiiColors.deep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/messages'),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: DiiColors.yellow,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(_partnerName),
              style: GoogleFonts.inter(
                color: DiiColors.blue,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_partnerName,
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    )),
                Text(_partnerRole.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 56, color: DiiColors.textDisabled),
            const SizedBox(height: 12),
            Text(_error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _load();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 56, color: DiiColors.blue.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text('No messages yet',
                  style: GoogleFonts.interTight(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: DiiColors.blue,
                  )),
              const SizedBox(height: 4),
              const Text('Send the first message below',
                  style: TextStyle(color: DiiColors.textSecondary)),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, i) => _bubble(_messages[i]),
    );
  }

  Widget _bubble(_Msg m) {
    final mine = m.mine;
    final bg = m.error
        ? DiiColors.danger
        : mine
            ? DiiColors.blue
            : Colors.white;
    final fg = mine || m.error ? Colors.white : DiiColors.textPrimary;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: mine
              ? null
              : Border.all(color: DiiColors.border),
        ),
        child: Text(
          m.body,
          style: GoogleFonts.inter(color: fg, fontSize: 13.5, height: 1.45),
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DiiColors.background,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
        border: Border(top: BorderSide(color: DiiColors.border.withValues(alpha: 0.6))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _send(),
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: DiiColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: DiiColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: DiiColors.blue, width: 1.6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: _busy ? DiiColors.textDisabled : DiiColors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _busy ? null : _send,
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.isEmpty || p.first.isEmpty) return '?';
    if (p.length == 1) return p.first[0].toUpperCase();
    return (p.first[0] + p.last[0]).toUpperCase();
  }
}

class _Msg {
  final String body;
  final bool mine;
  final bool error;
  _Msg({required this.body, required this.mine, this.error = false});
}
