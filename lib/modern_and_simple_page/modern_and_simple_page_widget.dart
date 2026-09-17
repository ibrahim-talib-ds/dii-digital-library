import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'modern_and_simple_page_model.dart';
export 'modern_and_simple_page_model.dart';

/// Create a modern and simple entry page for my university Digital Library
/// mobile application.
///
/// APP NAME:
/// Digital Library
///
/// PURPOSE:
/// This is a university digital library where students can browse books,
/// search for books, view book details, and access available digital
/// resources.
///
/// ENTRY PAGE DESIGN:
/// Create a clean splash/entry page that appears when the application starts.
///
/// Layout:
///
/// * Full-screen mobile layout.
/// * Clean academic and modern appearance.
/// * Use a simple library/book visual in the center.
/// * Show the application name: "Digital Library"
/// * Add a short subtitle: "Learn. Discover. Read."
/// * Add a simple "Get Started" button at the bottom.
/// * Keep enough spacing so the page does not look crowded.
/// * Use rounded corners and a professional university-style design.
/// * Do not make the design overly complicated.
///
/// ANIMATION:
/// Add a smooth startup animation:
///
/// 1. Library/book icon fades in.
/// 2. The icon slightly scales from small to normal size.
/// 3. "Digital Library" text fades in after the icon.
/// 4. Subtitle appears with a small upward slide animation.
/// 5. The "Get Started" button fades in last.
///
/// Animation should be smooth and short, approximately 1.5–2 seconds total.
///
/// BUTTON:
/// The "Get Started" button should navigate to the Login/Register page.
///
/// LOGIN/REGISTER FLOW:
/// After pressing "Get Started":
///
/// * Show Login page.
/// * Provide Email and Password fields.
/// * Provide Login button.
/// * Provide "Create Account" option.
/// * Use Firebase Authentication for login and registration.
///
/// DESIGN STYLE:
///
/// * Modern
/// * Minimal
/// * Academic
/// * Professional
/// * Student-friendly
/// * Responsive for different phone sizes
///
/// IMPORTANT:
/// Keep the implementation simple. Do not add unnecessary advanced
/// architecture, complicated animations, unnecessary pages, or excessive
/// components. The application should look like a real university student
/// project while remaining easy to understand and maintain.
///
/// FIREBASE:
/// The application will use Firebase Authentication and Cloud Firestore.
/// Do not create fake backend data or API connections.
/// The entry page only needs to handle navigation to the authentication
/// pages.
///
/// NAVIGATION:
/// Entry Page → Login/Register → Home → Books → Book Details
class ModernAndSimplePageWidget extends StatefulWidget {
  const ModernAndSimplePageWidget({super.key});

  static String routeName = 'ModernAndSimplePage';
  static String routePath = '/modernAndSimplePage';

  @override
  State<ModernAndSimplePageWidget> createState() =>
      _ModernAndSimplePageWidgetState();
}

class _ModernAndSimplePageWidgetState extends State<ModernAndSimplePageWidget> {
  late ModernAndSimplePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ModernAndSimplePageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      context.pushNamed(
        HomePageWidget.routeName,
        extra: <String, dynamic>{
          '__transition_info__': TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.fade,
            duration: Duration(milliseconds: 0),
          ),
        },
      );
    });

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
        backgroundColor: FlutterFlowTheme.of(context).primary,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 120.0,
                      height: 120.0,
                      decoration: BoxDecoration(
                        color: Color(0x1A060229),
                        borderRadius: BorderRadius.circular(9999.0),
                        shape: BoxShape.rectangle,
                      ),
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Container(
                        width: 200.0,
                        height: 200.0,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqrI-bVOjU1IiHtGgfFdbrAKMdjFixSikt_qbvtwjrvg&s=10',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(HomePageWidget.routeName);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  color: FlutterFlowTheme.of(context).tertiary,
                                  size: 40.0,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(
                                      FlutterFlowTheme.of(context)
                                          .designToken
                                          .spacing
                                          .xs),
                                  child: RichText(
                                    textScaler:
                                        MediaQuery.of(context).textScaler,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'DII ',
                                          style: FlutterFlowTheme.of(context)
                                              .displaySmall
                                              .override(
                                                font: GoogleFonts.interTight(
                                                  fontWeight: FontWeight.w900,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .displaySmall
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                fontSize: 40.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w900,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .displaySmall
                                                        .fontStyle,
                                              ),
                                        ),
                                        TextSpan(
                                          text: 'Library',
                                          style: TextStyle(
                                            color: FlutterFlowTheme.of(context)
                                                .tertiary,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 40.0,
                                          ),
                                        )
                                      ],
                                      style: FlutterFlowTheme.of(context)
                                          .displaySmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .displaySmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .displaySmall
                                                      .fontStyle,
                                            ),
                                            color: Colors.white,
                                            fontSize: 2.0,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .displaySmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .displaySmall
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          'Learn. Discover. Read.',
                          style: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontStyle,
                                lineHeight: 1.4,
                              ),
                        ),
                      ].divide(SizedBox(height: 4.0)),
                    ),
                  ].divide(SizedBox(height: 24.0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
