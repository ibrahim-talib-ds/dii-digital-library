import '/components/app_bottom_nav.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

import 'about_page_model.dart';
export 'about_page_model.dart';

class AboutPageWidget extends StatefulWidget {
  const AboutPageWidget({super.key});

  static String routeName = 'AboutPage';
  static String routePath = '/aboutPage';

  @override
  State<AboutPageWidget> createState() => _AboutPageWidgetState();
}

class _AboutPageWidgetState extends State<AboutPageWidget> {
  late AboutPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kDeep   = Color(0xFF081444);
  static const Color kYellow = Color(0xFFFFC107);

  static const String kSupportEmail = '240023018@dii.tj';
  static const String kSupportPhone = '+992 11 71 72 411';
  static const String kSupportPhoneRaw = '+992117172411';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AboutPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _mail() async {
    final uri = Uri(scheme: 'mailto', path: kSupportEmail,
        query: 'subject=About DII Library');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: kSupportPhoneRaw);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: kBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('About DII Library',
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Hero ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [kBlue, kDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: kYellow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.menu_book_rounded,
                              color: kBlue, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DII Library',
                                style: GoogleFonts.interTight(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                )),
                            Text('Dushanbe Innovation Institute',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12.5,
                                )),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'A complete digital library for DII students, librarians and administrators. '
                      'Browse thousands of books, request titles, and track your borrowing — '
                      'all in one place.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              _sectionTitle(context, 'What you can do'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _feature(context, Icons.search_rounded, 'Browse & Search',
                      'Find any book by title, author or code'),
                  _feature(context, Icons.book_online_rounded, 'Request Books',
                      'Request titles and wait for approval'),
                  _feature(context, Icons.history_rounded, 'Track History',
                      'See everything you ever borrowed'),
                  _feature(context, Icons.picture_as_pdf_rounded, 'Read PDFs',
                      'Preview digital copies where available'),
                ],
              ),

              const SizedBox(height: 28),
              _sectionTitle(context, 'Contact'),
              const SizedBox(height: 12),

              _contactCard(
                context,
                icon: Icons.mail_rounded,
                label: 'Email',
                value: kSupportEmail,
                onTap: _mail,
              ),
              const SizedBox(height: 10),
              _contactCard(
                context,
                icon: Icons.phone_rounded,
                label: 'Phone',
                value: kSupportPhone,
                onTap: _call,
              ),
              const SizedBox(height: 10),
              _contactCard(
                context,
                icon: Icons.location_on_rounded,
                label: 'Address',
                value: 'DII Library, Dushanbe, Tajikistan',
                onTap: null,
              ),

              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Text('DII Digital Library',
                        style: GoogleFonts.interTight(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: FlutterFlowTheme.of(context).primaryText,
                        )),
                    const SizedBox(height: 4),
                    Text('© 2026 Dushanbe Innovation Institute',
                        style: TextStyle(
                          fontSize: 12,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String t) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
            color: kYellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(t,
            style: GoogleFonts.interTight(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: FlutterFlowTheme.of(context).primaryText,
            )),
      ],
    );
  }

  Widget _feature(BuildContext context, IconData icon, String title, String sub) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: kBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: FlutterFlowTheme.of(context).primaryText,
                    )),
                const SizedBox(height: 2),
                Text(sub,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.3,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate.withOpacity(0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: kYellow.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: kBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        )),
                    const SizedBox(height: 2),
                    Text(value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: FlutterFlowTheme.of(context).primaryText,
                        )),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.grey, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
