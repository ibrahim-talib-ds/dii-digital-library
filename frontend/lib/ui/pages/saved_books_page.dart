import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/breakpoints.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/result.dart';
import '../../data/models/book.dart';
import '../../data/repositories/saved_books_repository.dart';
import '../components/book_card.dart';
import '../layout/responsive_shell.dart';

class SavedBooksPage extends StatefulWidget {
  const SavedBooksPage({super.key});

  @override
  State<SavedBooksPage> createState() => _SavedBooksPageState();
}

class _SavedBooksPageState extends State<SavedBooksPage> {
  late Future<Ok<List<Book>>?> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context
        .read<SavedBooksRepository>()
        .list()
        .then((r) => r is Ok<List<Book>> ? r : null);
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = DiiBreakpoints.isPhone(context);

    return ResponsiveShell(
      currentRoute: '/saved',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isPhone ? 14 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Saved Books',
                                style: GoogleFonts.interTight(
                                  fontSize: isPhone ? 22 : 28,
                                  fontWeight: FontWeight.w900,
                                  color: DiiColors.textPrimary,
                                  letterSpacing: -0.5,
                                )),
                            const SizedBox(height: 4),
                            const Text('Books you bookmarked for later',
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
                  _body(isPhone),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(bool isPhone) {
    return FutureBuilder<Ok<List<Book>>?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(60),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final ok = snap.data;
        if (ok == null || ok.data.isEmpty) return _empty();

        final cols = DiiBreakpoints.gridCols(context,
            phone: 2, tablet: 3, desktop: 5);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 20,
            childAspectRatio: 0.58,
          ),
          itemCount: ok.data.length,
          itemBuilder: (context, i) => BookCard(
            book: ok.data[i],
            width: double.infinity,
            onTap: () =>
                context.go('${DiiRoutes.bookDetails}/${ok.data[i].id}'),
          ),
        );
      },
    );
  }

  Widget _empty() => Container(
        padding: const EdgeInsets.all(60),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: DiiColors.blue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bookmark_outline_rounded,
                  size: 50, color: DiiColors.blue.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 20),
            Text('No saved books yet',
                style: GoogleFonts.interTight(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.blue,
                )),
            const SizedBox(height: 6),
            const Text('Tap the bookmark icon on any book to save it',
                style: TextStyle(color: DiiColors.textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.go(DiiRoutes.browse),
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Browse Books'),
            ),
          ],
        ),
      );
}
