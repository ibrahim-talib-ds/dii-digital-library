import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/app_bottom_nav.dart';
import '/components/app_sidebar.dart';
import '/components/setting_widget.dart';
import '/custom/role_utils.dart';
import '/custom/user_avatar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_page_model.dart';
import '/custom/dii_logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/custom/book_card.dart';
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

  static const Color kBlue   = Color(0xFF0A1E5C);
  static const Color kDeep   = Color(0xFF081444);
  static const Color kYellow = Color(0xFFFFC107);
  static const Color kGreen  = Color(0xFF10B981);
  static const Color kRed    = Color(0xFFDC0F0F);

  final TextEditingController _searchCtl = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = const [
    {
      'key': 'is_computer_science',
      'title': 'Computer Science',
      'icon': Icons.computer_rounded,
      'color': Color(0xFF3B82F6),
      'img': 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800',
    },
    {
      'key': 'is_artificial_intelligence',
      'title': 'Artificial Intelligence',
      'icon': Icons.psychology_rounded,
      'color': Color(0xFF7B1FA2),
      'img': 'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=800',
    },
    {
      'key': 'is_biotechnology',
      'title': 'Biotechnology',
      'icon': Icons.biotech_rounded,
      'color': Color(0xFF10B981),
      'img': 'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?w=800',
    },
    {
      'key': 'is_business_data_science',
      'title': 'Data Science',
      'icon': Icons.insights_rounded,
      'color': Color(0xFFFFC107),
      'img': 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800',
    },
    {
      'key': 'is_business_innovation',
      'title': 'Business',
      'icon': Icons.lightbulb_rounded,
      'color': Color(0xFFEF4444),
      'img': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800',
    },
    {
      'key': 'is_mathematics',
      'title': 'Mathematics',
      'icon': Icons.calculate_rounded,
      'color': Color(0xFF06B6D4),
      'img': 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=800',
    },
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    Future.microtask(() => loadCurrentUserRole());
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _model.dispose();
    super.dispose();
  }

  bool get _isDesktop => MediaQuery.of(context).size.width >= 1024;


  // Only this email can edit category images.
  static const String _ownerEmail = '240023018@dii.tj';
  bool get _isOwner {
    final email = (FirebaseAuth.instance.currentUser?.email ?? '').toLowerCase();
    return email == _ownerEmail;
  }

  // Show dialog: 2 options — Edit Image or Continue
  Future<void> _showCategoryOptions(String catKey, String catTitle) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(catTitle),
        content: const Text('Choose an action'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'edit'),
            child: const Text('Edit Image'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kBlue),
            onPressed: () => Navigator.pop(ctx, 'continue'),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (choice == 'edit') {
      await _editCategoryImage(catKey, catTitle);
    } else if (choice == 'continue') {
      _openCategory(catTitle);
    }
  }

  // Ask for URL and save to Firestore
  Future<void> _editCategoryImage(String catKey, String catTitle) async {
    final ctl = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit "$catTitle" image'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Paste image URL here',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kBlue),
            onPressed: () => Navigator.pop(ctx, ctl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (url == null || url.isEmpty) return;
    if (!url.startsWith('http')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL must start with http')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('category_images')
          .doc(catKey)
          .set({
        'imageUrl': url,
        'name': catTitle,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category image updated'),
          backgroundColor: kGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: kRed),
      );
    }
  }

  // Navigate to category
  void _openCategory(String title) {
    context.pushNamed(
      CategoryBooksPageWidget.routeName,
      queryParameters: {'category': title},
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isPhone = w < 600;
    final isTablet = w >= 600 && w < 1024;
    final cols = isPhone ? 2 : (isTablet ? 4 : 6);
    final isDesktop = w >= 1024;

    final body = Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: isDesktop ? null : _appBar(context, isPhone),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isPhone ? 16 : (isTablet ? 24 : 32),
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _hero(context, isPhone, isTablet)
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.1, end: 0, curve: Curves.easeOut),

                    const SizedBox(height: 24),
                    _statsStrip(context, isPhone)
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),

                    const SizedBox(height: 32),
                    _sectionTitle(context, 'Browse by Category'),
                    const SizedBox(height: 14),
                    _categoryGrid(context, isPhone, isTablet)
                        .animate(delay: 400.ms)
                        .fadeIn(duration: 500.ms),

                    const SizedBox(height: 36),

                    if (_searchQuery.isNotEmpty)
                      _searchResults(context, cols)
                    else
                      for (final cat in _categories)
                        _bookSection(context, cat, cols),

                    const SizedBox(height: 48),
                    _footer(context, isPhone),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        children: [
          const AppSidebar(currentRoute: 'HomePage'),
          Expanded(child: body),
        ],
      );
    }
    return body;
  }

  // ═══════════════════════════════════════════════════════════════
  // APP BAR (mobile/tablet only)
  // ═══════════════════════════════════════════════════════════════
  PreferredSizeWidget _appBar(BuildContext context, bool isPhone) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AppBar(
        backgroundColor: kBlue,
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        elevation: 0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                InkWell(
                  onTap: () => context.pushNamed(HomePageWidget.routeName),
                  borderRadius: BorderRadius.circular(8),
                  child: const DiiBrand(),
                ),
                const Spacer(),
                if (loggedIn)
                  InkWell(
                    onTap: () => context.pushNamed(ProfilePageWidget.routeName),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: kYellow.withOpacity(0.4),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: UserAvatar(
                        size: 40,
                        borderWidth: 2.5,
                        borderColor: kYellow,
                        fallbackName: currentUserDisplayName,
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () =>
                        context.pushNamed(LoginPageWidget.routeName),
                    child: const Text('Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.grid_view_rounded,
                      color: Colors.white, size: 22),
                  onPressed: () async {
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (_) => Padding(
                        padding: MediaQuery.viewInsetsOf(context),
                        child: const SettingWidget(),
                      ),
                    ).then((_) => safeSetState(() {}));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO
  // ═══════════════════════════════════════════════════════════════
  Widget _hero(BuildContext context, bool isPhone, bool isTablet) {
    final h = isPhone ? 200.0 : (isTablet ? 210.0 : 220.0);
    return Container(
      width: double.infinity,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [kBlue, kDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ─── Library photo — RIGHT SIDE ONLY ───
          Positioned(
            right: 0, top: 0, bottom: 0,
            width: 340,
            child: ShaderMask(
              // Fade from transparent (left) to visible (right)
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,        // left edge — fades into blue
                  Color(0x33000000),         // 20% dark
                  Color(0x99000000),         // 60% dark
                  Color(0xCC000000),         // 80% dark (photo fully visible)
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,  // ← KEY: shows photo where gradient is OPAQUE
              child: Image.asset(
                'assets/images/library.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

          // ─── Text overlay ───
          Padding(
            padding: EdgeInsets.all(isPhone ? 24 : 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  loggedIn
                      ? 'Welcome back, ${currentUserDisplayName.split(" ").first}'
                      : 'Welcome to DII Library',
                  style: GoogleFonts.interTight(
                    fontSize: isPhone ? 22 : 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find your next book from our collection',
                  style: TextStyle(
                    fontSize: isPhone ? 13 : 15,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20),
                // ─── Search bar INSIDE hero ───
                Container(
                  constraints: const BoxConstraints(maxWidth: 460),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 12,
                        color: Color(0x22000000),
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtl,
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search by title, author, or code...',
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                      prefixIcon:
                          const Icon(Icons.search_rounded, color: kBlue),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchCtl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SEARCH BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _searchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: kBlue.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            color: Color(0x0A000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtl,
        onChanged: (v) => setState(() => _searchQuery = v.trim()),
        decoration: InputDecoration(
          hintText: 'Search books by title, author, code...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: kBlue),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchCtl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: FlutterFlowTheme.of(context).primaryText,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STATS STRIP
  // ═══════════════════════════════════════════════════════════════
  Widget _statsStrip(BuildContext context, bool isPhone) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('books').snapshots(),
      builder: (context, bookSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('borrowings')
              .where('userId', isEqualTo: currentUserUid)
              .snapshots(),
          builder: (context, borrowSnap) {
            int totalBooks = 0;
            int availableBooks = 0;
            if (bookSnap.hasData) {
              totalBooks = bookSnap.data!.docs.length;
              for (final d in bookSnap.data!.docs) {
                final m = d.data() as Map<String, dynamic>;
                final av = (m['availableCopies'] as num?)?.toInt() ?? 0;
                if (av > 0) availableBooks++;
              }
            }

            int activeLoans = 0;
            int overdue = 0;
            if (borrowSnap.hasData) {
              final now = DateTime.now();
              for (final d in borrowSnap.data!.docs) {
                final m = d.data() as Map<String, dynamic>;
                final s = (m['status'] ?? '').toString();
                if (s == 'borrowed' || s == 'approved') {
                  final due = m['dueDate'] is Timestamp
                      ? (m['dueDate'] as Timestamp).toDate()
                      : null;
                  if (due != null && due.isBefore(now)) {
                    overdue++;
                  } else {
                    activeLoans++;
                  }
                }
              }
            }

            final cols = isPhone ? 2 : 4;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: isPhone ? 2.6 : 2.4,
              children: [
                // ─── Total Books → Browse all ───
                _statCard(
                  context,
                  'Total Books',
                  '$totalBooks',
                  Icons.menu_book_rounded,
                  kBlue,
                  onTap: () => context.pushNamed(
                    BrowseBooksWidget.routeName,
                  ),
                ),
                // ─── Available Now → Browse with available filter ───
                _statCard(
                  context,
                  'Available Now',
                  '$availableBooks',
                  Icons.check_circle_rounded,
                  kGreen,
                  onTap: () => context.pushNamed(
                    BrowseBooksWidget.routeName,
                    queryParameters: {'filter': 'available'},
                  ),
                ),
                // ─── My Active → My Books ───
                _statCard(
                  context,
                  'My Active',
                  '$activeLoans',
                  Icons.book_rounded,
                  kYellow,
                  onTap: () {
                    if (!loggedIn) {
                      context.pushNamed(LoginPageWidget.routeName);
                    } else {
                      context.pushNamed(MyBooksWidget.routeName);
                    }
                  },
                ),
                // ─── Overdue → My Books ───
                _statCard(
                  context,
                  'Overdue',
                  '$overdue',
                  Icons.warning_amber_rounded,
                  kRed,
                  onTap: () {
                    if (!loggedIn) {
                      context.pushNamed(LoginPageWidget.routeName);
                    } else {
                      context.pushNamed(MyBooksWidget.routeName);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _statCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: color.withOpacity(0.12),
        highlightColor: color.withOpacity(0.06),
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.25), width: 1.2),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: color.withOpacity(0.08),
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Colored icon block
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: color.withOpacity(0.35),
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              // Value + label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.interTight(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: color,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color:
                            FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron indicator
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color.withOpacity(0.5),
                  size: 12,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SECTION TITLE
  // ═══════════════════════════════════════════════════════════════
  Widget _sectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4, height: 22,
          decoration: BoxDecoration(
            color: kYellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: GoogleFonts.interTight(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: FlutterFlowTheme.of(context).primaryText,
            )),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CATEGORY GRID
  // ═══════════════════════════════════════════════════════════════
  Widget _categoryGrid(BuildContext context, bool isPhone, bool isTablet) {
    final w = MediaQuery.of(context).size.width;
    // Fewer columns at each breakpoint so cards stay wide enough
    final cols = w >= 1400
        ? 6
        : w >= 1100
            ? 4
            : w >= 800
                ? 3
                : 2;
    // Taller cards on phones so text has room
    final aspect = isPhone ? 1.9 : 2.2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: aspect,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, i) {
        final cat = _categories[i];
        return _categoryCard(context, cat, isPhone);
      },
    );
  }

  Widget _categoryCard(BuildContext context, Map<String, dynamic> cat, bool isPhone) {
    final title = (cat['title'] ?? '').toString();
    final icon = cat['icon'] as IconData? ?? Icons.menu_book_rounded;
    final key = cat['key'] as String;

    return StreamBuilder<List<BooksRecord>>(
      stream: queryBooksRecord(
        queryBuilder: (q) => q.where(key, isEqualTo: true),
      ),
      builder: (context, snap) {
        final count = snap.data?.length ?? 0;

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onLongPress: _isOwner
                ? () => _showCategoryOptions(key, title)
                : null,
            onTap: () {
              if (_isOwner) {
                _showCategoryOptions(key, title);
              } else {
                _openCategory(title);
              }
            },
            borderRadius: BorderRadius.circular(12),
            splashColor: kYellow.withOpacity(0.15),
            child: Container(
              decoration: BoxDecoration(
                color: kBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: kYellow.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Color(0x33000000),
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ─── Icon ───
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: kYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: kBlue, size: 18),
                  ),
                  const SizedBox(width: 8),
                  // ─── Text ───
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.interTight(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$count ${count == 1 ? 'book' : 'books'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: kYellow,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ─── Right indicator ───
                  if (_isOwner)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: kYellow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_rounded,
                              color: kBlue, size: 10),
                          const SizedBox(width: 3),
                          Text('EDIT',
                              style: GoogleFonts.inter(
                                color: kBlue,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              )),
                        ],
                      ),
                    )
                  else
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: kYellow.withOpacity(0.6),
                      size: 11,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BOOK SECTIONS
  // ═══════════════════════════════════════════════════════════════
  Widget _bookSection(BuildContext context, Map<String, dynamic> cat, int cols) {
    final catKey = cat['key'] as String;
    final title = cat['title'] as String;
    final icon = cat['icon'] as IconData? ?? Icons.menu_book_rounded;
    final color = cat['color'] as Color? ?? kBlue;

    return StreamBuilder<List<BooksRecord>>(
      stream: queryBooksRecord(
        queryBuilder: (q) => q.where(catKey, isEqualTo: true),
      ),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final books = snap.data!;
        if (books.isEmpty) return const SizedBox.shrink();

        final w = MediaQuery.of(context).size.width;
        final isPhone = w < 600;

        return Container(
          margin: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Section header ───
              _sectionHeader(context, title, icon, color, books.length, isPhone),
              const SizedBox(height: 16),

              // ─── Horizontal book scroll ───
              SizedBox(
                height: isPhone ? 250 : 285,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  itemCount: books.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, i) => _horizontalBookCard(
                    context,
                    books[i],
                    isPhone: isPhone,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Beautiful section header with icon, title, count and "See all"
  // ═══════════════════════════════════════════════════════════════
  Widget _sectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    int count,
    bool isPhone,
  ) {
    return Row(
      children: [
        // Colored icon block
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: color.withOpacity(0.35),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),

        // Title + count
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.interTight(
                  fontSize: isPhone ? 17 : 20,
                  fontWeight: FontWeight.w900,
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count ${count == 1 ? 'book' : 'books'} in this collection',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ],
          ),
        ),

        // "See all" button
        InkWell(
          onTap: () => _openCategory(title),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See all',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: color, size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Beautiful horizontal book card
  // ═══════════════════════════════════════════════════════════════
  Widget _horizontalBookCard(
    BuildContext context,
    BooksRecord book, {
    required bool isPhone,
  }) {
    return SizedBox(
      width: isPhone ? 145 : 175,
      child: BookCard(book: book),
    );
  }

  Widget _bookPlaceholder(BuildContext context) {
    return Container(
      color: FlutterFlowTheme.of(context).alternate,
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_rounded,
        size: 44,
        color: FlutterFlowTheme.of(context).secondaryText,
      ),
    );
  }

  Widget _searchResults(BuildContext context, int cols) {
    return StreamBuilder<List<BooksRecord>>(
      stream: queryBooksRecord(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final q = _searchQuery.toLowerCase();
        final matches = snap.data!.where((b) {
          final hay = '${b.title} ${b.author} ${b.bookCode} ${b.category}'
              .toLowerCase();
          return hay.contains(q);
        }).toList();

        if (matches.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 64,
                      color: FlutterFlowTheme.of(context).secondaryText),
                  const SizedBox(height: 12),
                  Text('No results for "$_searchQuery"',
                      style: TextStyle(
                        fontSize: 15,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      )),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'Search Results (${matches.length})'),
            const SizedBox(height: 14),
            _bookGrid(context, matches, cols),
          ],
        );
      },
    );
  }

  Widget _bookGrid(BuildContext context, List<BooksRecord> books, int cols) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: books.length,
      itemBuilder: (context, i) => _bookCard(context, books[i]),
    );
  }

  Widget _bookCard(BuildContext context, BooksRecord book) {
    return BookCard(book: book);
  }

  // ═══════════════════════════════════════════════════════════════
  // FOOTER
  // ═══════════════════════════════════════════════════════════════
  Widget _footer(BuildContext context, bool isPhone) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withOpacity(0.2),
        ),
      ),
      child: Wrap(
        spacing: 40,
        runSpacing: 24,
        children: [
          SizedBox(
            width: 200,
            child: _footerCol(context, 'DII Library', [
              _footerLink(context, 'About', AboutPageWidget.routeName),
              _footerLink(context, 'Contact', ContactWidget.routeName),
              _footerLink(context, 'Help Center', HelpWidget.routeName),
              _footerLink(context, 'Privacy', PrivacyWidget.routeName),
            ]),
          ),
          SizedBox(
            width: 200,
            child: _footerCol(context, 'Explore', [
              _footerLink(context, 'Browse Books', BrowseBooksWidget.routeName),
              _footerLink(context, 'My Books', MyBooksWidget.routeName),
              _footerLink(context, 'History', HistoryWidget.routeName),
            ]),
          ),
          if (!isPhone)
            SizedBox(
              width: 200,
              child: _footerCol(context, 'Account', [
                _footerLink(context, 'Profile', ProfilePageWidget.routeName),
                if (!loggedIn)
                  _footerLink(context, 'Sign In', LoginPageWidget.routeName),
              ]),
            ),
          SizedBox(
            width: 200,
            child: _footerCol(context, 'Contact', [
              Text('240023018@dii.tj',
                  style: TextStyle(
                    fontSize: 13,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  )),
              const SizedBox(height: 4),
              Text('+992 11 71 72 411',
                  style: TextStyle(
                    fontSize: 13,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  )),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _footerCol(BuildContext context, String h, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(h,
            style: GoogleFonts.interTight(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: FlutterFlowTheme.of(context).primaryText,
            )),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _footerLink(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => context.pushNamed(route),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              color: FlutterFlowTheme.of(context).secondaryText,
            )),
      ),
    );
  }
}
