import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/colors.dart';
import '../../data/models/book.dart';

class BookCard extends StatefulWidget {
  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.width = 170,
  });

  final Book book;
  final VoidCallback? onTap;
  final double width;

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return SizedBox(
      width: widget.width,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit:  (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, _hovering ? -4 : 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: DiiColors.blue.withValues(
                                    alpha: _hovering ? 0.22 : 0.12),
                                blurRadius: _hovering ? 22 : 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _cover(book),
                        ),
                      ),
                      Positioned(top: 8, right: 8, child: _badge(book)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: DiiColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: DiiColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (book.bookCode != null) ...[
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: DiiColors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      book.bookCode!,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: DiiColors.blue,
                        letterSpacing: 0.5,
                      ),
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

  Widget _cover(Book book) {
    if (book.coverUrl != null && book.coverUrl!.isNotEmpty) {
      return Image.network(
        book.coverUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(color: DiiColors.blue.withValues(alpha: 0.06));
        },
        errorBuilder: (_, __, ___) => _fallbackCover(book),
      );
    }
    return _fallbackCover(book);
  }

  /// Blue gradient + white text + yellow bookmark ribbon.
  Widget _fallbackCover(Book book) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DiiColors.blue, DiiColors.deep],
        ),
      ),
      child: Stack(
        children: [
          // yellow "ribbon" corner
          Positioned(
            top: 0, right: 0,
            child: ClipPath(
              clipper: _CornerClipper(),
              child: Container(
                width: 50, height: 50,
                color: DiiColors.yellow,
              ),
            ),
          ),
          Positioned(
            top: 10, right: 10,
            child: Icon(Icons.bookmark_rounded,
                color: DiiColors.blue, size: 16),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 40, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.menu_book_rounded,
                    color: DiiColors.yellow.withValues(alpha: 0.9), size: 22),
                Flexible(
                  child: Text(
                    book.title,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: DiiColors.yellow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    book.author.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: DiiColors.blue,
                      fontWeight: FontWeight.w900,
                      fontSize: 8,
                      letterSpacing: 0.8,
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

  Widget _badge(Book book) {
    final Color bg;
    final Color fg;
    final String label;

    if (book.isOut) {
      bg = DiiColors.danger;
      fg = Colors.white;
      label = 'OUT';
    } else if (book.isLowStock) {
      bg = DiiColors.yellow;
      fg = DiiColors.blue;
      label = '${book.availableCopies} LEFT';
    } else {
      bg = DiiColors.blue;
      fg = DiiColors.yellow;
      label = '${book.availableCopies}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _CornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.moveTo(0, 0);
    p.lineTo(size.width, 0);
    p.lineTo(0, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
