import '/components/app_bottom_nav.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

import 'help_model.dart';
export 'help_model.dart';

class HelpWidget extends StatefulWidget {
  const HelpWidget({super.key});

  static String routeName = 'Help';
  static String routePath = '/help';

  @override
  State<HelpWidget> createState() => _HelpWidgetState();
}

class _HelpWidgetState extends State<HelpWidget> {
  late HelpModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kDeep   = Color(0xFF081444);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);

  // ─── Real contact info ───
  static const String kSupportEmail = '240023018@dii.tj';
  static const String kSupportPhone = '+992 11 71 72 411';
  static const String kSupportPhoneRaw = '+992117172411';

  final List<Map<String, String>> _faqs = const [
    {
      'q': 'How do I borrow a book?',
      'a': 'Open any book from the home page or Browse Books, then tap "Request Book" on the details page. A librarian will approve your request — you will see the due date in "My Books" once approved.',
    },
    {
      'q': 'How long can I keep a book?',
      'a': 'Standard loans are 14 days from the approval date. You can see your exact due date in My Books. Overdue books will be marked in red.',
    },
    {
      'q': 'How many books can I borrow at once?',
      'a': 'Students can have up to 3 active loans. Librarians 5, admins 10. This is set per account.',
    },
    {
      'q': 'What if a book is already borrowed?',
      'a': 'The book card shows how many copies are available. If none are on the shelf, the button is disabled — check back later.',
    },
    {
      'q': 'How do I return a book?',
      'a': 'Bring the physical book to the DII Library desk. A librarian will scan/select your loan and mark it returned. Your history will update immediately.',
    },
    {
      'q': 'I forgot my password. What do I do?',
      'a': 'Contact the DII library administrator at 240023018@dii.tj or call +992 11 71 72 411. Password resets are done from the admin panel.',
    },
    {
      'q': 'Can I read PDFs online?',
      'a': 'Yes — if a book has a PDF preview, a "Read PDF Preview" button appears on the details page. This works on desktop and mobile.',
    },
    {
      'q': 'Who do I contact for technical problems?',
      'a': 'Email 240023018@dii.tj or call +992 11 71 72 411. Include a screenshot and short description.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HelpModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _mail() async {
    final uri = Uri(scheme: 'mailto', path: kSupportEmail,
        query: 'subject=DII Library Support');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: kSupportPhoneRaw);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: kBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Help Center',
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
              // ─── Contact hero ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
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
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: kYellow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.support_agent_rounded,
                              color: kBlue, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Need help?',
                                  style: GoogleFonts.interTight(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  )),
                              Text('We respond within 1 business day',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 12.5,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Email row
                    _contactRow(
                      icon: Icons.mail_rounded,
                      label: 'Email',
                      value: kSupportEmail,
                      onTap: _mail,
                    ),
                    const SizedBox(height: 8),
                    // Phone row
                    _contactRow(
                      icon: Icons.phone_rounded,
                      label: 'Call',
                      value: kSupportPhone,
                      onTap: _call,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── FAQ ───
              Row(
                children: [
                  Container(
                    width: 4, height: 20,
                    decoration: BoxDecoration(
                      color: kYellow,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Frequently Asked Questions',
                      style: GoogleFonts.interTight(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: FlutterFlowTheme.of(context).primaryText,
                      )),
                ],
              ),
              const SizedBox(height: 12),

              for (final faq in _faqs) _faqItem(context, faq),

              const SizedBox(height: 32),

              // ─── Office info ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: FlutterFlowTheme.of(context).alternate.withOpacity(0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: kBlue, size: 20),
                        const SizedBox(width: 8),
                        Text('Library Desk',
                            style: GoogleFonts.interTight(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: FlutterFlowTheme.of(context).primaryText,
                            )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dushanbe Innovation Institute\n'
                      'DII Library, Main Building\n'
                      'Dushanbe, Tajikistan',
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, color: kBlue, size: 18),
                        const SizedBox(width: 8),
                        Text('Mon–Fri · 08:00 – 18:00',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: FlutterFlowTheme.of(context).primaryText,
                            )),
                      ],
                    ),
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

  Widget _contactRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: kYellow, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      )),
                  const SizedBox(height: 2),
                  Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white54, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(BuildContext context, Map<String, String> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withOpacity(0.25),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: kBlue,
          collapsedIconColor: kBlue,
          title: Text(
            faq['q'] ?? '',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                faq['a'] ?? '',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
