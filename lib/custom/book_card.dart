import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium book card — used everywhere in the app.
/// Cover floats inside the card with an inset margin.
/// Shows: floating cover, type badge, title, author, code.
/// Whole card is clickable.
class BookCard extends StatefulWidget {
  const BookCard({
    super.key,
    required this.book,
    this.width,
  });

  final BooksRecord book;
  final double? width;

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kDeep   = Color(0xFF081444);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kPurple = Color(0xFF7B1FA2);

  bool _hovering = false;

  Color get _badgeColor {
    final t = widget.book.bookType;
    if (t == 'digital') return kPurple;
    if (t == 'physical') return kBlue;
    return kGreen;
  }

  IconData get _badgeIcon {
    final t = widget.book.bookType;
    if (t == 'digital') return Icons.tablet_mac_rounded;
    if (t == 'physical') return Icons.menu_book_rounded;
    return Icons.auto_stories_rounded;
  }

  String get _badgeText {
    final t = widget.book.bookType;
    if (t == 'digital') return 'DIGITAL';
    if (t == 'physical') return 'PHYSICAL';
    return 'BOTH';
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return SizedBox(
      width: widget.width,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hovering ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovering
                  ? kYellow.withOpacity(0.7)
                  : FlutterFlowTheme.of(context).alternate.withOpacity(0.25),
              width: _hovering ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: _hovering ? 16 : 6,
                color: _hovering
                    ? kBlue.withOpacity(0.15)
                    : const Color(0x0A000000),
                offset: Offset(0, _hovering ? 6 : 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => context.pushNamed(
                DetailsWidget.routeName,
                queryParameters: {
                  'books': serializeParam(
                      book.reference, ParamType.DocumentReference),
                }.withoutNulls,
              ),
              borderRadius: BorderRadius.circular(14),
              splashColor: kBlue.withOpacity(0.06),
              highlightColor: kBlue.withOpacity(0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Floating cover section ───
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            book.coverUrl.isNotEmpty
                                ? Image.network(
                                    book.coverUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _placeholder(context),
                                  )
                                : _placeholder(context),
                            // Subtle dark gradient at bottom for badge legibility
                            Positioned(
                              left: 0, right: 0, bottom: 0, height: 50,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.35),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Type badge — top-left, solid color
                            Positioned(
                              top: 6, left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _badgeColor,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 4,
                                      color: Color(0x33000000),
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_badgeIcon,
                                        color: Colors.white, size: 9),
                                    const SizedBox(width: 3),
                                    Text(_badgeText,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.4,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ─── Title + author + code section ───
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Title + author
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                book.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.interTight(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                  color: FlutterFlowTheme.of(context)
                                      .primaryText,
                                ),
                              ),
                              if (book.author.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  book.author,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          // Book code — subtle, bottom
                          if (book.bookCode.isNotEmpty)
                            Text(
                              book.bookCode,
                              style: GoogleFonts.inter(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: kBlue.withOpacity(0.55),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: FlutterFlowTheme.of(context).alternate,
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_rounded,
        size: 32,
        color: FlutterFlowTheme.of(context).secondaryText,
      ),
    );
  }
}
