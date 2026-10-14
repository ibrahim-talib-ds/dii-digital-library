import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/breakpoints.dart';
import '../../core/colors.dart';
import '../../data/api/api_client.dart';
import '../layout/responsive_shell.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_Msg> _messages = [];
  String? _conversationId;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _busy) return;

    setState(() {
      _messages.add(_Msg(text, mine: true));
      _busy = true;
      _controller.clear();
    });
    _scrollDown();

    final api = context.read<ApiClient>();
    try {
      final res = await api.post('/ai/chat', body: {
        'message': text,
        if (_conversationId != null) 'conversation_id': _conversationId,
      });
      if (!mounted) return;
      final reply = (res as Map<String, dynamic>)['reply'] as String? ?? '';
      final cid = res['conversation_id'] as String?;
      setState(() {
        _conversationId = cid;
        _messages.add(_Msg(reply, mine: false));
        _busy = false;
      });
      _scrollDown();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg('Error: $e', mine: false, error: true));
        _busy = false;
      });
      _scrollDown();
    }
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = DiiBreakpoints.isPhone(context);

    return ResponsiveShell(
      currentRoute: '/ai',
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isPhone ? 0 : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(isPhone ? 0 : 14),
                  border: isPhone
                      ? null
                      : Border.all(color: DiiColors.border),
                ),
                child: Column(
                  children: [
                    _header(isPhone),
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

  Widget _header(bool isPhone) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: DiiColors.yellow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: DiiColors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ibro_Ai',
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    )),
                Text('Powered by Groq · AI Library Assistant',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11.5,
                    )),
              ],
            ),
          ),
          if (_messages.isNotEmpty)
            IconButton(
              tooltip: 'New chat',
              onPressed: () => setState(() {
                _messages.clear();
                _conversationId = null;
              }),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_messages.isEmpty) return _welcome();

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_busy ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == _messages.length && _busy) {
          return _typingIndicator();
        }
        return _bubble(_messages[i]);
      },
    );
  }

  Widget _welcome() {
    final samples = [
      'What books do you have on AI?',
      'How do I borrow a book?',
      'How many books can I borrow?',
      'Do you have Calculus?',
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: DiiColors.yellow.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: DiiColors.blue, size: 44),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8)),
          const SizedBox(height: 20),
          Text('Hi! How can I help you?',
              textAlign: TextAlign.center,
              style: GoogleFonts.interTight(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: DiiColors.blue,
              ))
              .animate(delay: 100.ms)
              .fadeIn(),
          const SizedBox(height: 8),
          const Text(
            'Ask me anything about the library, books, or borrowing.',
            textAlign: TextAlign.center,
            style: TextStyle(color: DiiColors.textSecondary, fontSize: 13.5),
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: samples.map((s) => _sampleChip(s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _sampleChip(String text) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          _controller.text = text;
          _send();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DiiColors.border, width: 1.3),
          ),
          child: Text(text,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: DiiColors.textPrimary,
              )),
        ),
      ),
    );
  }

  Widget _bubble(_Msg m) {
    final isMine = m.mine;
    final bg = m.error
        ? DiiColors.danger
        : isMine
            ? DiiColors.blue
            : Colors.white;
    final fg = isMine || m.error ? Colors.white : DiiColors.textPrimary;
    final border = isMine || m.error ? null : Border.all(color: DiiColors.border);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 620),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: border,
          boxShadow: isMine
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 14, color: DiiColors.blue),
                    const SizedBox(width: 6),
                    Text('Ibro_Ai',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: DiiColors.blue,
                          letterSpacing: 0.6,
                        )),
                  ],
                ),
              ),
            Text(
              m.body,
              style: GoogleFonts.inter(
                color: fg,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 250.ms)
          .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DiiColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: DiiColors.blue.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 10),
            Text('Thinking...',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: DiiColors.textSecondary,
                  fontStyle: FontStyle.italic,
                )),
          ],
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
        border: Border(
          top: BorderSide(color: DiiColors.border.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _send(),
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'Ask anything about the library...',
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  borderSide: BorderSide(color: DiiColors.blue, width: 1.6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: _busy ? DiiColors.textDisabled : DiiColors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _busy ? null : _send,
              icon: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String body;
  final bool mine;
  final bool error;
  _Msg(this.body, {this.mine = false, this.error = false});
}
