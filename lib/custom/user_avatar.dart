import 'dart:convert';
import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Central avatar widget — reads from Firestore `users/{uid}.photoUrl`.
/// This is the SINGLE SOURCE OF TRUTH for the user's photo.
///
/// Use everywhere instead of currentUserPhoto (Firebase Auth).
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.uid,
    this.size = 44,
    this.borderColor,
    this.borderWidth = 0,
    this.fallbackName,
  });

  final String? uid;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final String? fallbackName;

  @override
  Widget build(BuildContext context) {
    final targetUid = (uid ?? currentUserUid).trim();
    if (targetUid.isEmpty) {
      return _fallback();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .snapshots(),
      builder: (context, snap) {
        String photoUrl = '';
        String name = fallbackName ?? '';

        if (snap.hasData && snap.data!.exists) {
          final data = snap.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            photoUrl = (data['photoUrl'] ?? '').toString();
            if (name.isEmpty) {
              name = (data['name'] ?? '').toString();
            }
          }
        }

        return _render(photoUrl, name);
      },
    );
  }

  Widget _render(String photoUrl, String name) {
    Widget image;
    if (photoUrl.startsWith('data:image')) {
      try {
        final b64 = photoUrl.split(',').last;
        final bytes = base64Decode(b64);
        image = Image.memory(bytes,
            fit: BoxFit.cover, width: size, height: size);
      } catch (_) {
        image = _initialAvatar(name);
      }
    } else if (photoUrl.startsWith('http')) {
      image = Image.network(
        photoUrl,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _initialAvatar(name),
      );
    } else {
      image = _initialAvatar(name);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFC107),
        border: borderWidth > 0
            ? Border.all(color: borderColor ?? Colors.white, width: borderWidth)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: image,
    );
  }

  Widget _initialAvatar(String name) {
    final letter = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      color: const Color(0xFFFFC107),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF0A1E5C),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFC107),
      ),
      child: Icon(
        Icons.person_rounded,
        color: const Color(0xFF0A1E5C),
        size: size * 0.5,
      ),
    );
  }
}
