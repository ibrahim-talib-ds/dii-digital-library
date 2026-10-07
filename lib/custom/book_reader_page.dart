import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the book's PDF in a new browser tab.
///
/// Simplest approach:
/// - No CORS issues
/// - Works with any PDF URL (NCERT, Google Drive, university sites, etc.)
///
/// Flow:
///   1. User taps "Read PDF"
///   2. This page opens briefly
///   3. PDF opens in a new tab automatically
///   4. User can close this page or go back to the library
class BookReaderPage extends StatefulWidget {
  const BookReaderPage({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  final String title;
  final String pdfUrl;

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  bool _opened = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPdf());
  }

  Future<void> _openPdf() async {
    final url = widget.pdfUrl.trim();
    if (url.isEmpty) {
      setState(() => _error = 'No PDF link for this book.');
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      setState(() => _error = 'Invalid PDF link.');
      return;
    }

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) return;
      if (ok) {
        setState(() {
          _opened = true;
          _error = null;
        });
      } else {
        setState(() => _error = 'Could not open the PDF.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not open the PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: BookReaderPage.kBlue,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Success state ───
              if (_opened && _error == null) ...[
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    color: BookReaderPage.kGreen.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.open_in_new_rounded,
                      size: 40, color: BookReaderPage.kGreen),
                ),
                const SizedBox(height: 20),
                const Text(
                  'PDF opened in a new tab',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check your browser tabs to read the book.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _openPdf,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Open again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BookReaderPage.kBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],

              // ─── Error state ───
              if (_error != null) ...[
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline_rounded,
                      size: 40, color: Colors.red),
                ),
                const SizedBox(height: 20),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _openPdf,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BookReaderPage.kBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],

              // ─── Loading state ───
              if (!_opened && _error == null) ...[
                const CircularProgressIndicator(
                    color: BookReaderPage.kYellow),
                const SizedBox(height: 20),
                const Text(
                  'Opening PDF…',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],

              const SizedBox(height: 32),

              // ─── PDF link for reference ───
              if (widget.pdfUrl.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PDF link:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        widget.pdfUrl,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
