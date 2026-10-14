import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/breakpoints.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/result.dart';
import '../../data/models/user.dart';
import '../../data/repositories/users_repository.dart';
import '../../state/auth_state.dart';
import '../layout/responsive_shell.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _department = TextEditingController();
  int? _year;

  bool _editing = false;
  bool _saving = false;
  bool _loaded = false;

  // pending avatar change
  Uint8List? _pickedBytes;
  String? _pickedMime;
  bool _removeAvatar = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _department.dispose();
    super.dispose();
  }

  void _loadFrom(User u) {
    if (_loaded) return;
    _name.text = u.name;
    _phone.text = u.phone ?? '';
    _department.text = u.department ?? '';
    _year = u.year;
    _loaded = true;
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (xfile == null) return;

      final bytes = await xfile.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pickedBytes = bytes;
        _pickedMime = xfile.mimeType ?? 'image/jpeg';
        _removeAvatar = false;
      });
    } catch (e) {
      _snack('Could not open gallery: $e', DiiColors.danger);
    }
  }

  void _clearPickedAvatar() {
    setState(() {
      _pickedBytes = null;
      _pickedMime = null;
    });
  }

  Future<void> _save() async {
    final auth = context.read<AuthState>();
    final me = auth.user;
    if (me == null) return;

    setState(() => _saving = true);
    final repo = context.read<UsersRepository>();

    String? newAvatar;
    if (_pickedBytes != null) {
      final mime = _pickedMime ?? 'image/jpeg';
      newAvatar = 'data:$mime;base64,${base64Encode(_pickedBytes!)}';
    } else if (_removeAvatar) {
      newAvatar = '';
    }

    final body = <String, dynamic>{
      'name': _name.text.trim(),
      'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      'department': _department.text.trim().isEmpty
          ? null
          : _department.text.trim(),
      'year': _year,
      if (newAvatar != null) 'avatar_url': newAvatar,
    };

    final res = await repo.update(me.id, body);
    if (!mounted) return;
    setState(() => _saving = false);

    switch (res) {
      case Ok(:final data):
        auth.updateUser(data);
        setState(() {
          _editing = false;
          _pickedBytes = null;
          _pickedMime = null;
          _removeAvatar = false;
        });
        _snack('Profile updated successfully', DiiColors.blue);
      case Err(:final error):
        _snack(error.toString(), DiiColors.danger);
    }
  }

  void _cancelEdit() {
    setState(() {
      _editing = false;
      _pickedBytes = null;
      _pickedMime = null;
      _removeAvatar = false;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DiiColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      if (!mounted) return;
      await context.read<AuthState>().logout();
      if (!mounted) return;
      context.go(DiiRoutes.splash);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final me = auth.user;
    if (me == null) {
      return const ResponsiveShell(
        currentRoute: DiiRoutes.profile,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    _loadFrom(me);

    final isPhone = DiiBreakpoints.isPhone(context);

    return ResponsiveShell(
      currentRoute: DiiRoutes.profile,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isPhone ? 14 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pageHeader(isPhone),
                  const SizedBox(height: 20),
                  isPhone
                      ? Column(
                          children: [
                            _avatarCard(me),
                            const SizedBox(height: 16),
                            _detailsCard(me),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 300, child: _avatarCard(me)),
                            const SizedBox(width: 20),
                            Expanded(child: _detailsCard(me)),
                          ],
                        ),
                  const SizedBox(height: 20),
                  _actions(isPhone),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── header ───
  Widget _pageHeader(bool isPhone) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: GoogleFonts.interTight(
                  fontSize: isPhone ? 22 : 28,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  InkWell(
                    onTap: () => context.go(DiiRoutes.home),
                    child: Text(
                      'Home',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: DiiColors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 14, color: DiiColors.textSecondary),
                  ),
                  Text(
                    _editing ? 'Update My Profile' : 'View Profile',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: DiiColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── avatar card with photo picker ───
  Widget _avatarCard(User u) {
    // decide what to show
    Uint8List? previewBytes = _pickedBytes;
    final hasRemote = u.avatarUrl != null &&
        u.avatarUrl!.isNotEmpty &&
        !_removeAvatar;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DiiColors.border),
      ),
      child: Column(
        children: [
          // ── avatar with edit overlay ──
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  color: DiiColors.blue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DiiColors.yellow,
                    width: 3,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _avatarContent(u, previewBytes, hasRemote),
              ),
              if (_editing)
                Positioned.fill(
                  child: ClipOval(
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.35),
                      child: InkWell(
                        onTap: _pickImage,
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.photo_camera_rounded,
                                  color: Colors.white, size: 28),
                              SizedBox(height: 6),
                              Text(
                                'Change',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            u.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.interTight(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: DiiColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            u.email,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: DiiColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          // role pill
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: DiiColors.yellow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              u.role.label.toUpperCase(),
              style: GoogleFonts.inter(
                color: DiiColors.blue,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // status pill
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: u.isActive
                  ? DiiColors.blue.withValues(alpha: 0.08)
                  : DiiColors.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: u.isActive
                    ? DiiColors.blue.withValues(alpha: 0.3)
                    : DiiColors.danger.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  u.isActive
                      ? Icons.check_circle_rounded
                      : Icons.block_rounded,
                  size: 12,
                  color: u.isActive ? DiiColors.blue : DiiColors.danger,
                ),
                const SizedBox(width: 5),
                Text(
                  u.isActive ? 'ACTIVE' : 'BLOCKED',
                  style: GoogleFonts.inter(
                    color: u.isActive ? DiiColors.blue : DiiColors.danger,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // ─── edit photo buttons ───
          if (_editing) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library_outlined, size: 16),
                    label: Text(
                      _pickedBytes == null ? 'Choose Photo' : 'Replace',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DiiColors.blue,
                      side: const BorderSide(color: DiiColors.blue, width: 1.3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (_pickedBytes != null || hasRemote) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Remove photo',
                    onPressed: () {
                      _clearPickedAvatar();
                      setState(() => _removeAvatar = true);
                    },
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: DiiColors.danger),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          DiiColors.danger.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'JPG or PNG · Max 512×512',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: DiiColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _avatarContent(User u, Uint8List? preview, bool hasRemote) {
    if (preview != null) {
      return Image.memory(preview, fit: BoxFit.cover);
    }
    if (hasRemote && u.avatarUrl!.startsWith('data:')) {
      final comma = u.avatarUrl!.indexOf(',');
      if (comma > 0) {
        try {
          return Image.memory(
            base64Decode(u.avatarUrl!.substring(comma + 1)),
            fit: BoxFit.cover,
          );
        } catch (_) {}
      }
    }
    if (hasRemote && u.avatarUrl!.startsWith('http')) {
      return Image.network(
        u.avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _avatarFallback(u.name),
      );
    }
    return _avatarFallback(u.name);
  }

  Widget _avatarFallback(String name) {
    return Container(
      color: DiiColors.blue,
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: GoogleFonts.interTight(
          color: Colors.white,
          fontSize: 52,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // ─── details card ───
  Widget _detailsCard(User u) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DiiColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 20,
                decoration: BoxDecoration(
                  color: DiiColors.yellow,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _editing ? 'Update Details' : 'Account Details',
                style: GoogleFonts.interTight(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: DiiColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!_editing) _readOnly(u) else _editForm(u),
        ],
      ),
    );
  }

  Widget _readOnly(User u) {
    return Column(
      children: [
        _infoRow('Student Number', u.studentNumber, Icons.badge_outlined),
        _divider(),
        _infoRow('Email', u.email, Icons.email_outlined),
        _divider(),
        _infoRow('Full Name', u.name, Icons.person_outline_rounded),
        _divider(),
        _infoRow('Department', u.department ?? '—', Icons.school_outlined),
        _divider(),
        _infoRow(
          'Year',
          u.year == null ? '—' : 'Year ${u.year}',
          Icons.timeline_rounded,
        ),
        _divider(),
        _infoRow('Phone', u.phone ?? '—', Icons.phone_outlined),
        _divider(),
        _infoRow(
          'Borrow Limit',
          '${u.borrowLimit} books',
          Icons.bookmark_outline_rounded,
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: DiiColors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: DiiColors.blue, size: 18),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: DiiColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: DiiColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        color: DiiColors.border.withValues(alpha: 0.6),
      );

  Widget _editForm(User u) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // read-only
        _readOnlyRow('Student Number', u.studentNumber, Icons.badge_outlined),
        const SizedBox(height: 12),
        _readOnlyRow('Email', u.email, Icons.email_outlined),
        const SizedBox(height: 20),
        // editable
        TextField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'Full name',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _department,
          decoration: const InputDecoration(
            labelText: 'Department',
            prefixIcon: Icon(Icons.school_outlined),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int?>(
          initialValue: _year,
          decoration: const InputDecoration(
            labelText: 'Year',
            prefixIcon: Icon(Icons.timeline_rounded),
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('—')),
            DropdownMenuItem(value: 1, child: Text('Year 1')),
            DropdownMenuItem(value: 2, child: Text('Year 2')),
            DropdownMenuItem(value: 3, child: Text('Year 3')),
            DropdownMenuItem(value: 4, child: Text('Year 4')),
          ],
          onChanged: (v) => setState(() => _year = v),
        ),
      ],
    );
  }

  Widget _readOnlyRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: DiiColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DiiColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: DiiColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: DiiColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: DiiColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ─── bottom action buttons ───
  Widget _actions(bool isPhone) {
    return Align(
      alignment: isPhone ? Alignment.center : Alignment.centerRight,
      child: _editing
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: _saving ? null : _cancelEdit,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Icon(Icons.save_rounded, size: 16),
                  label: const Text('Save Changes'),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DiiColors.danger,
                    side: const BorderSide(color: DiiColors.danger),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _editing = true),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit Profile'),
                ),
              ],
            ),
    );
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.isEmpty || p.first.isEmpty) return '?';
    if (p.length == 1) return p.first[0].toUpperCase();
    return (p.first[0] + p.last[0]).toUpperCase();
  }
}
