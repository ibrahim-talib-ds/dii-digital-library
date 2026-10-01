import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Universal book card — used on home, browse, category, my_books, etc.
/// Displays cover with 3-state badge (Available / Few left / All out) + copies count.
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    this.width,
    this.aspectRatio = 0.62,
  });

  final BooksRecord book;
  final double? width;
  final double aspectRatio;

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kRed    = Color(0xFFDC0F0F);

  @override
  Widget build(BuildContext context) {
    final total = book.totalCopies;
    final available = book.availableCopies;
    final isAvailable = available > 0;
    final isLow = available > 0 && available <= 2;

    Color badgeColor;
    IconData badgeIcon;
    String badgeText;
    if (!isAvailable) {
      badgeColor = kRed;
      badgeIcon = Icons.cancel_rounded;
      badgeText = 'All out';
    } else if (isLow) {
      badgeColor = kYellow;
      badgeIcon = Icons.access_time_rounded;
      badgeText = 'Few left';
    } else {
      badgeColor = kGreen;
      badgeIcon = Icons.check_circle_rounded;
      badgeText = 'Available';
    }

    return InkWell(
      onTap: () => context.pushNamed(
        DetailsWidget.routeName,
        queryParameters: {
          'books': serializeParam(book.reference, ParamType.DocumentReference),
        }.withoutNulls,
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate.withOpacity(0.25),
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Color(0x0A000000),
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      book.coverUrl.isNotEmpty
                          ? book.coverUrl
                          : 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: FlutterFlowTheme.of(context).alternate,
                        child: const Icon(Icons.menu_book_rounded, size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
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
                          Icon(badgeIcon, color: Colors.white, size: 11),
                          const SizedBox(width: 4),
                          Text(badgeText,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              )),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('$available / $total copies',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.interTight(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              color: FlutterFlowTheme.of(context).primaryText,
                            )),
                        if (book.author.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(book.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText,
                              )),
                        ],
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? kBlue.withOpacity(0.1)
                              : kRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isAvailable ? 'View & Borrow' : 'Out of stock',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: isAvailable ? kBlue : kRed,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
