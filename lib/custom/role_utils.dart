import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String _cachedRole = 'student';
Map<String, dynamic>? _cachedUserDoc;
String _cachedDocId = '';
bool _loaded = false;

Future<void> loadCurrentUserRole() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    _cachedRole = 'student';
    _cachedUserDoc = null;
    _cachedDocId = '';
    _loaded = true;
    return;
  }

  final uid = user.uid;
  final email = (user.email ?? '').toLowerCase();

  _cachedUserDoc = null;
  _cachedDocId = '';

  // Try uid doc first
  try {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (snap.exists && snap.data() != null) {
      _cachedUserDoc = snap.data();
      _cachedDocId = snap.id;
    }
  } catch (_) {}

  // Fallback to email doc if needed
  if ((_cachedUserDoc == null ||
          (_cachedUserDoc!['role'] ?? '').toString().isEmpty) &&
      email.isNotEmpty) {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get();
      if (snap.exists && snap.data() != null) {
        _cachedUserDoc = snap.data();
        _cachedDocId = snap.id;
      }
    } catch (_) {}
  }

  _cachedRole = (_cachedUserDoc?['role'] ?? 'student').toString();
  _loaded = true;
}

bool isRoleLoaded() => _loaded;
bool isAdminUser() => _cachedRole == 'admin';
bool isLibrarianUser() => _cachedRole == 'librarian';
bool isStaffUser() => isAdminUser() || isLibrarianUser();
String currentRole() => _cachedRole;
Map<String, dynamic>? currentUserDoc() => _cachedUserDoc;
String currentDocId() => _cachedDocId;

Future<bool> isAdminUserAsync() async {
  await loadCurrentUserRole();
  return isAdminUser();
}

Future<String> currentRoleAsync() async {
  await loadCurrentUserRole();
  return currentRole();
}

void clearRoleCache() {
  _cachedRole = 'student';
  _cachedUserDoc = null;
  _cachedDocId = '';
  _loaded = false;
}
