import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/colors.dart';

/// Small floating "Ask Ibro_Ai" button visible on every page.
/// Opens the AI chat as a right-side drawer.
class AiFloatingButton extends StatelessWidget {
  const AiFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: SafeArea(
        child: Material(
          color: DiiColors.blue,
          borderRadius: BorderRadius.circular(30),
          elevation: 8,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => _open(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DiiColors.blue, DiiColors.deep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: DiiColors.yellow.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: DiiColors.blue.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: DiiColors.yellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: DiiColors.blue, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text('Ask Ibro_Ai',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40, height: 6,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: DiiColors.yellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: DiiColors.blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ibro_Ai',
                              style: GoogleFonts.interTight(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: DiiColors.blue,
                              )),
                          const Text('Quick chat',
                              style: TextStyle(
                                fontSize: 11,
                                color: DiiColors.textSecondary,
                              )),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Open full chat',
                      icon: const Icon(Icons.open_in_full_rounded,
                          size: 20, color: DiiColors.blue),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.go('/ai');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                            size: 48,
                            color: DiiColors.blue.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text('Quick AI chat',
                            style: GoogleFonts.interTight(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: DiiColors.blue,
                            )),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap "Open full chat" to start a conversation\nwith Ibro_Ai',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: DiiColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.go('/ai');
                          },
                          icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                          label: const Text('Open Ibro_Ai'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
