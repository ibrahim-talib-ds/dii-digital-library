import '/components/app_bottom_nav.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

import 'contact_model.dart';
export 'contact_model.dart';

class ContactWidget extends StatefulWidget {
  const ContactWidget({super.key});

  static String routeName = 'Contact';
  static String routePath = '/contact';

  @override
  State<ContactWidget> createState() => _ContactWidgetState();
}

class _ContactWidgetState extends State<ContactWidget> {
  late ContactModel _model;
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
    _model = createModel(context, () => ContactModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _mail() async {
    final uri = Uri(scheme: 'mailto', path: kSupportEmail,
        query: 'subject=DII Library Contact');
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
        title: Text('Contact Us',
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
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
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: kYellow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.support_agent_rounded,
                          color: kBlue, size: 30),
                    ),
                    const SizedBox(height: 16),
                    Text('Get in touch',
                        style: GoogleFonts.interTight(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        )),
                    const SizedBox(height: 6),
                    Text('We are here to help with any question',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _tile(context,
                  icon: Icons.mail_rounded,
                  label: 'Email',
                  value: kSupportEmail,
                  onTap: _mail),
              const SizedBox(height: 12),
              _tile(context,
                  icon: Icons.phone_rounded,
                  label: 'Phone',
                  value: kSupportPhone,
                  onTap: _call),
              const SizedBox(height: 12),
              _tile(context,
                  icon: Icons.location_on_rounded,
                  label: 'Office',
                  value: 'DII Library, Dushanbe',
                  onTap: null),
              const SizedBox(height: 12),
              _tile(context,
                  icon: Icons.schedule_rounded,
                  label: 'Hours',
                  value: 'Mon–Fri · 08:00 – 18:00',
                  onTap: null),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context,
      {required IconData icon,
      required String label,
      required String value,
      VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate.withOpacity(0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: kBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: kBlue, size: 22),
              ),
              const SizedBox(width: 14),
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
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
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
