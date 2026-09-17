import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/setting_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/homePage';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: false,
            toolbarHeight: 70.0,
            elevation: 2.0,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // --- Brand Logo ---
                    InkWell(
                      onTap: () => _navigateTo(context, HomePageWidget.routeName),
                      child: Row(
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            color: FlutterFlowTheme.of(context).alternate,
                            size: 32.0,
                          ),
                          const SizedBox(width: 8.0),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'DII ',
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w900,
                                    color: FlutterFlowTheme.of(context).alternate,
                                    fontSize: 22.0,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Library',
                                  style: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w900,
                                    color: FlutterFlowTheme.of(context).tertiary,
                                    fontSize: 22.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- Search Bar ---
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24.0),
                        constraints: const BoxConstraints(maxWidth: 450.0),
                        child: InkWell(
                          onTap: () => _navigateTo(context, BrowseBooksWidget.routeName),
                          child: Container(
                            height: 44.0,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(22.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  size: 20.0,
                                ),
                                const SizedBox(width: 10.0),
                                Text(
                                  'Search title, author, or ISBN...',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // --- Navigation Links & Actions ---
                    Row(
                      children: [
                        _navButton(context, 'Home', HomePageWidget.routeName),
                        _navButton(context, 'Books', BrowseBooksWidget.routeName),
                        _navButton(context, 'About', AboutPageWidget.routeName),
                        const SizedBox(width: 12.0),

                        // Auth Actions
                        if (loggedIn) ...[
                          AuthUserStreamWidget(
                            builder: (context) => InkWell(
                              onTap: () => _navigateTo(context, ProfilePageWidget.routeName),
                              child: Container(
                                width: 42.0,
                                height: 42.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).tertiary,
                                    width: 2.0,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(21.0),
                                  child: Image.network(
                                    currentUserPhoto.isNotEmpty
                                        ? currentUserPhoto
                                        : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          _navButton(context, 'Sign In', LoginPageWidget.routeName),
                          const SizedBox(width: 8.0),
                          FFButtonWidget(
                            onPressed: () => _navigateTo(context, SignUpPageWidget.routeName),
                            text: 'Create Account',
                            options: FFButtonOptions(
                              height: 38.0,
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              color: FlutterFlowTheme.of(context).tertiary,
                              textStyle: GoogleFonts.inter(
                                color: FlutterFlowTheme.of(context).primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                              borderRadius: BorderRadius.circular(19.0),
                            ),
                          ),
                        ],

                        const SizedBox(width: 12.0),
                        // Settings Drawer Trigger
                        IconButton(
                          icon: Icon(
                            Icons.grid_view_rounded,
                            color: FlutterFlowTheme.of(context).alternate,
                            size: 26.0,
                          ),
                          onPressed: () async {
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              enableDrag: false,
                              context: context,
                              builder: (context) => Padding(
                                padding: MediaQuery.viewInsetsOf(context),
                                child: const SettingWidget(),
                              ),
                            ).then((value) => safeSetState(() {}));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1280.0),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Hero Banner Section ---
                    _buildHeroSection(context),
                    const SizedBox(height: 40.0),

                    // --- Categories Banner Section ---
                    Text(
                      'Explore Categories',
                      style: FlutterFlowTheme.of(context).displaySmall.override(
                            font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                            fontSize: 24.0,
                          ),
                    ),
                    const SizedBox(height: 16.0),
                    _buildCategoriesRow(context),
                    const SizedBox(height: 40.0),

                    // --- Book Collections dynamically fetched from Firestore ---
                    _buildCategoryBooksSection(
                      context,
                      title: 'COMPUTER SCIENCE',
                      stream: queryBooksRecord(
                        queryBuilder: (r) => r.where('is_computer_science', isEqualTo: true),
                      ),
                    ),
                    _buildCategoryBooksSection(
                      context,
                      title: 'ARTIFICIAL INTELLIGENCE',
                      stream: queryBooksRecord(
                        queryBuilder: (r) => r.where('is_artificial_intelligence', isEqualTo: true),
                      ),
                    ),
                    _buildCategoryBooksSection(
                      context,
                      title: 'BIOTECHNOLOGY',
                      stream: queryBooksRecord(
                        queryBuilder: (r) => r.where('is_biotechnology', isEqualTo: true),
                      ),
                    ),
                    _buildCategoryBooksSection(
                      context,
                      title: 'ECONOMICS AND DATA SCIENCE',
                      stream: queryBooksRecord(
                        queryBuilder: (r) => r.where('is_business_data_science', isEqualTo: true),
                      ),
                    ),
                    _buildCategoryBooksSection(
                      context,
                      title: 'BUSINESS AND INNOVATION',
                      stream: queryBooksRecord(
                        queryBuilder: (r) => r.where('is_business_innovation', isEqualTo: true),
                      ),
                    ),
                    _buildCategoryBooksSection(
                      context,
                      title: 'MATHEMATICS',
                      stream: queryBooksRecord(
                        queryBuilder: (r) => r.where('is_mathematics', isEqualTo: true),
                      ),
                    ),

                    const SizedBox(height: 60.0),
                    const Divider(),
                    const SizedBox(height: 30.0),

                    // --- Responsive Footer ---
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget: Top Nav Text Button
  Widget _navButton(BuildContext context, String label, String routeName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () => _navigateTo(context, routeName),
        child: Text(
          label,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                color: FlutterFlowTheme.of(context).alternate,
                fontSize: 15.0,
              ),
        ),
      ),
    );
  }

  // Helper: Route Navigator with Fade Animation
  void _navigateTo(BuildContext context, String routeName, {Map<String, String>? params}) {
    context.pushNamed(
      routeName,
      queryParameters: params ?? {},
      extra: <String, dynamic>{
        '__transition_info__': const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 150),
        ),
      },
    );
  }

  // Hero Card Banner
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 320.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        gradient: LinearGradient(
          colors: [
            FlutterFlowTheme.of(context).primary,
            FlutterFlowTheme.of(context).primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            top: -20,
            child: Opacity(
              opacity: 0.25,
              child: Image.network(
                'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?w=1000',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to DII Library',
                  style: GoogleFonts.interTight(
                    fontSize: 36.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  'Your journey to knowledge starts here. Search, borrow, and manage academic resources with ease.',
                  style: GoogleFonts.inter(
                    fontSize: 16.0,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 24.0),
                FFButtonWidget(
                  onPressed: () => _navigateTo(context, BrowseBooksWidget.routeName),
                  text: 'Browse Books Catalog',
                  options: FFButtonOptions(
                    height: 48.0,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    color: FlutterFlowTheme.of(context).tertiary,
                    textStyle: GoogleFonts.inter(
                      color: FlutterFlowTheme.of(context).primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Static Categories Scrollable Cards
  Widget _buildCategoriesRow(BuildContext context) {
    final categories = [
      {'title': 'Computer Science', 'img': 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400'},
      {'title': 'Artificial Intelligence', 'img': 'https://images.unsplash.com/photo-1677442136019-21780efad99a?w=400'},
      {'title': 'Biotechnology', 'img': 'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?w=400'},
      {'title': 'Business Data Science', 'img': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400'},
      {'title': 'Business Innovation', 'img': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400'},
      {'title': 'Mathematics', 'img': 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400'},
    ];

    return SizedBox(
      height: 140.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () => _navigateTo(
                context,
                CategoryBooksPageWidget.routeName,
                params: {'category': cat['title']!},
              ),
              child: Container(
                width: 200.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.0),
                  image: DecorationImage(
                    image: NetworkImage(cat['img']!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.0),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    cat['title']!,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Reusable Stream-driven Book Category Section
  Widget _buildCategoryBooksSection(
    BuildContext context, {
    required String title,
    required Stream<List<BooksRecord>> stream,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: FlutterFlowTheme.of(context).displaySmall.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.w800),
                  fontSize: 20.0,
                  letterSpacing: 0.5,
                ),
          ),
        ),
        StreamBuilder<List<BooksRecord>>(
          stream: stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final books = snapshot.data!;
            if (books.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'No books available in this category yet.',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              );
            }

            return Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: books.map((book) {
                return InkWell(
                  onTap: () {
                    context.pushNamed(
                      DetailsWidget.routeName,
                      queryParameters: {
                        'books': serializeParam(
                          book.reference,
                          ParamType.DocumentReference,
                        ),
                      }.withoutNulls,
                      extra: <String, dynamic>{
                        '__transition_info__': const TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.fade,
                          duration: Duration(milliseconds: 150),
                        ),
                      },
                    );
                  },
                  child: Container(
                    width: 180.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).alternate.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
                          child: Image.network(
                            book.coverUrl.isNotEmpty
                                ? book.coverUrl
                                : 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400',
                            width: 180.0,
                            height: 230.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                  fontSize: 14.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // Modern Clean Footer
  Widget _buildFooter(BuildContext context) {
    return Wrap(
      spacing: 60.0,
      runSpacing: 30.0,
      alignment: WrapAlignment.spaceBetween,
      children: [
        _footerColumn(
          context,
          'DII Library',
          [
            _footerLink('About DII Library', () => _navigateTo(context, AboutPageWidget.routeName)),
            _footerLink('Our Vision', () => _navigateTo(context, VisionWidget.routeName)),
            _footerLink('Contact Us', () => _navigateTo(context, ContactWidget.routeName)),
            _footerLink('Privacy Policy', () => _navigateTo(context, PrivacyWidget.routeName)),
          ],
        ),
        _footerColumn(
          context,
          'Explore',
          [
            _footerLink('Search Books', () => _navigateTo(context, BrowseBooksWidget.routeName)),
            _footerLink('Book Categories', () => _navigateTo(context, BrowseBooksWidget.routeName)),
          ],
        ),
        _footerColumn(
          context,
          'Library Services',
          [
            _footerLink('Student Sign In', () => _navigateTo(context, LoginPageWidget.routeName)),
            _footerLink('Create Account', () => _navigateTo(context, SignUpPageWidget.routeName)),
            _footerLink('Book Availability', () => _navigateTo(context, BrowseBooksWidget.routeName)),
          ],
        ),
        _footerColumn(
          context,
          'Support',
          [
            _footerLink('Frequently Asked Questions', () => _navigateTo(context, HelpWidget.routeName)),
            _footerLink('Report a Problem', () => _navigateTo(context, HelpWidget.routeName)),
            _footerLink('Contact Librarian', () => _navigateTo(context, HelpWidget.routeName)),
          ],
        ),
      ],
    );
  }

  Widget _footerColumn(BuildContext context, String header, List<Widget> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: FlutterFlowTheme.of(context).primary,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 12.0),
        ...links,
      ],
    );
  }

  Widget _footerLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.0,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}