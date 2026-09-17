import '/components/policy_section_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'privacy_model.dart';
export 'privacy_model.dart';

/// Create a simple and modern "Privacy Policy" page for Dii Library.
///
/// Design:
/// - Match the existing Dii Library style.
/// - Dark navy background with white content sections.
/// - Clean academic design.
/// - Add a small book/library icon at the top.
/// - Page title: "Privacy Policy"
/// - Add "Last Updated: September 2026"
///
/// Content:
///
/// 1. Information We Collect
/// Dii Library may collect information such as your name and email address
/// when you create an account.
///
/// 2. How We Use Your Information
/// We use your information to create and manage your account, provide access
/// to the library, and improve the app.
///
/// 3. Account Security
/// Your account information is handled using Firebase Authentication. We do
/// not ask users to provide unnecessary personal information.
///
/// 4. Books and Learning Resources
/// Dii Library stores information about books and learning resources, such as
/// titles, authors, descriptions, and categories.
///
/// 5. Data Sharing
/// We do not sell or share your personal information with third parties for
/// advertising purposes.
///
/// 6. Data Protection
/// We take reasonable steps to protect user information and use trusted
/// services such as Firebase for authentication and data storage.
///
/// 7. Your Choices
/// You can choose whether to create an account and can stop using the
/// application at any time.
///
/// 8. Contact Us
/// If you have questions about this Privacy Policy, please contact the Dii
/// Library team.
///
/// At the bottom add:
/// "Your privacy matters to us."
///
/// Keep the text readable, use clear headings, moderate spacing, and make the
/// page scrollable. Do not add complicated features or unnecessary sections.
class PrivacyWidget extends StatefulWidget {
  const PrivacyWidget({super.key});

  static String routeName = 'privacy';
  static String routePath = '/privacy';

  @override
  State<PrivacyWidget> createState() => _PrivacyWidgetState();
}

class _PrivacyWidgetState extends State<PrivacyWidget> {
  late PrivacyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PrivacyModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF0A192F),
        body: SingleChildScrollView(
          primary: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 24.0),
                  child: Container(
                    child: Container(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 64.0,
                            height: 64.0,
                            decoration: BoxDecoration(
                              color: Color(0x1A060229),
                              borderRadius: BorderRadius.circular(9999.0),
                              shape: BoxShape.rectangle,
                            ),
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Icon(
                              Icons.auto_stories_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 32.0,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Privacy Policy',
                                style: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .override(
                                      font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .headlineMedium
                                          .fontStyle,
                                      lineHeight: 1.4,
                                    ),
                              ),
                              Text(
                                'Last Updated: September 2026',
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                      lineHeight: 1.4,
                                    ),
                              ),
                            ].divide(SizedBox(height: 4.0)),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  minHeight: 600.0,
                ),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32.0),
                    topRight: Radius.circular(32.0),
                  ),
                  shape: BoxShape.rectangle,
                ),
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 32.0),
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        wrapWithModel(
                          model: _model.policySectionModel1,
                          updateCallback: () => safeSetState(() {}),
                          child: PolicySectionWidget(
                            title: '1. Information We Collect',
                            body:
                                'Dii Library may collect information such as your name and email address when you create an account.',
                          ),
                        ),
                        wrapWithModel(
                          model: _model.policySectionModel2,
                          updateCallback: () => safeSetState(() {}),
                          child: PolicySectionWidget(
                            title: '2. How We Use Your Information',
                            body:
                                'We use your information to create and manage your account, provide access to the library, and improve the app.',
                          ),
                        ),
                        wrapWithModel(
                          model: _model.policySectionModel3,
                          updateCallback: () => safeSetState(() {}),
                          child: PolicySectionWidget(
                            title: '3. Account Security',
                            body:
                                'Your account information is handled using Firebase Authentication. We do not ask users to provide unnecessary personal information.',
                          ),
                        ),
                        wrapWithModel(
                          model: _model.policySectionModel4,
                          updateCallback: () => safeSetState(() {}),
                          child: PolicySectionWidget(
                            title: '4. Books and Learning Resources',
                            body:
                                'Dii Library stores information about books and learning resources, such as titles, authors, descriptions, and categories.',
                          ),
                        ),
                        Divider(
                          height: 16.0,
                          thickness: 1.0,
                          indent: 0.0,
                          endIndent: 0.0,
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                        wrapWithModel(
                          model: _model.policySectionModel5,
                          updateCallback: () => safeSetState(() {}),
                          child: PolicySectionWidget(
                            title: '5. Data Sharing',
                            body:
                                'We do not sell or share your personal information with third parties for advertising purposes.',
                          ),
                        ),
                        wrapWithModel(
                          model: _model.policySectionModel6,
                          updateCallback: () => safeSetState(() {}),
                          child: PolicySectionWidget(
                            title: '6. Data Protection',
                            body:
                                'We take reasonable steps to protect user information and use trusted services such as Firebase for authentication and data storage.',
                          ),
                        ),
                        wrapWithModel(
                          model: _model.policySectionModel7,
                          updateCallback: () => safeSetState(() {}),
                          child: PolicySectionWidget(
                            title: '7. Your Choices',
                            body:
                                'You can choose whether to create an account and can stop using the application at any time.',
                          ),
                        ),
                        wrapWithModel(
                          model: _model.policySectionModel8,
                          updateCallback: () => safeSetState(() {}),
                          child: PolicySectionWidget(
                            title: '8. Contact Us',
                            body:
                                'If you have questions about this Privacy Policy, please contact the Dii Library team.',
                          ),
                        ),
                        Container(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 24.0, 0.0, 24.0),
                            child: Container(
                              child: Container(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.help,
                                      color:
                                          FlutterFlowTheme.of(context).success,
                                      size: 24.0,
                                    ),
                                    Text(
                                      'Your privacy matters to us.',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontWeight,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmall
                                                    .fontWeight,
                                            fontStyle: FontStyle.italic,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(height: 24.0)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
