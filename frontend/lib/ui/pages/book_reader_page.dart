import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../core/colors.dart';

class BookReaderPage extends StatefulWidget {
  const BookReaderPage({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  final String title;
  final String pdfUrl;

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  final _controller = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 1;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkMode ? const Color(0xFF1A1A1A) : const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: DiiColors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // dark/light toggle
          IconButton(
            tooltip: _darkMode ? 'Light mode' : 'Dark mode',
            icon: Icon(_darkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: () => setState(() => _darkMode = !_darkMode),
          ),
        ],
      ),
      body: Stack(
        children: [
          // PDF viewer
          PdfViewer.uri(
            Uri.parse(widget.pdfUrl),
            controller: _controller,
            params: PdfViewerParams(
              backgroundColor:
                  _darkMode ? const Color(0xFF1A1A1A) : const Color(0xFFE8E8E8),
              onViewerReady: (document, controller) {
                setState(() => _totalPages = document.pages.length);
              },
              onPageChanged: (page) {
                setState(() => _currentPage = page ?? 1);
              },
              loadingBannerBuilder:
                  (context, bytesDownloaded, totalBytes) {
                final pct = totalBytes != null
                    ? (bytesDownloaded / totalBytes * 100).toStringAsFixed(0)
                    : '';
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                          color: DiiColors.yellow),
                      const SizedBox(height: 16),
                      Text(
                        'Loading PDF  $pct%',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
              errorBannerBuilder: (context, error, stack, doc) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.redAccent, size: 64),
                      const SizedBox(height: 12),
                      Text(
                        'Could not load PDF',
                        style: GoogleFonts.interTight(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$error',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded, size: 16),
                        label: const Text('Back to Book'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // right-side floating controls
          Positioned(
            right: 16,
            top: 16,
            child: Column(
              children: [
                _controlButton(
                  Icons.zoom_in_rounded,
                  'Zoom in',
                  () => _controller.zoomUp(),
                ),
                const SizedBox(height: 8),
                _controlButton(
                  Icons.zoom_out_rounded,
                  'Zoom out',
                  () => _controller.zoomDown(),
                ),
                const SizedBox(height: 8),
                _controlButton(
                  Icons.fit_screen_rounded,
                  'Fit width',
                  () => _controller.zoomUp(),
                ),
              ],
            ),
          ),

          // bottom page controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: DiiColors.blue,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Previous page',
                      icon: const Icon(Icons.chevron_left_rounded,
                          color: Colors.white),
                      onPressed: _currentPage > 1
                          ? () {
                              _controller.goToPage(
                                  pageNumber: _currentPage - 1);
                            }
                          : null,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Page $_currentPage of $_totalPages',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: 'Next page',
                      icon: const Icon(Icons.chevron_right_rounded,
                          color: Colors.white),
                      onPressed: _currentPage < _totalPages
                          ? () {
                              _controller.goToPage(
                                  pageNumber: _currentPage + 1);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: DiiColors.blue,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
