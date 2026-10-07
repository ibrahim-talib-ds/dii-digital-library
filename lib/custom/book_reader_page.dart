import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

/// Full-screen online PDF reader for digital books.
class BookReaderPage extends StatelessWidget {
  const BookReaderPage({super.key, required this.title, required this.pdfUrl});

  final String title;
  final String pdfUrl;

  static const Color kBlue = Color(0xFF0A1E5C);
  static const Color kYellow = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(pdfUrl);

    if (uri == null || !uri.hasScheme) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: kBlue,
          foregroundColor: Colors.white,
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This book has no valid PDF link.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBlue,
        foregroundColor: Colors.white,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: PdfViewer.uri(
        uri,
        params: PdfViewerParams(
          loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
            return Container(
              color: kBlue,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: kYellow),
                  const SizedBox(height: 16),
                  Text(
                    totalBytes != null
                        ? 'Loading… ${(bytesDownloaded / 1024).toStringAsFixed(0)} / ${(totalBytes / 1024).toStringAsFixed(0)} KB'
                        : 'Loading PDF…',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            );
          },
          errorBannerBuilder: (context, error, stackTrace, documentRef) {
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Could not load this PDF',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check your connection or try again later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
