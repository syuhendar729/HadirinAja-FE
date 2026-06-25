import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/session_manager.dart';
import 'login_page.dart';

const _teal = Color(AppColors.primary);
const _ink = Color(AppColors.textPrimary);
const _muted = Color(AppColors.textSecondary);
const _line = Color(AppColors.border);
const _stats = [
  (AttendanceStatus.present, 'Present', Icons.check_circle_outline_rounded),
  (AttendanceStatus.late, 'Late', Icons.schedule_rounded),
  (AttendanceStatus.leave, 'Leave', Icons.description_outlined),
  (AttendanceStatus.absent, 'Absent', Icons.cancel_outlined),
];

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final Future<UserModel> _future = UserService.getUser();
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _teal,
      body: FutureBuilder<UserModel>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (snap.hasError) return _message(snap.error.toString());
          if (snap.data == null) return _message('User data is empty');

          final user = snap.data!;
          return Column(
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.38,
                width: double.infinity,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: _profileHeader(user),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 34, 16, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(56),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 120),
                    children: [
                      _infoSection(user),
                      const SizedBox(height: 12),
                      _attendanceSection(user.total),
                      const SizedBox(height: 18),
                      _logoutButton(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _profileHeader(UserModel user) {
    final text = Theme.of(context).textTheme;
    final image = user.profilePicture;

    return Column(
      children: [
        Text(
          'Profile',
          style: text.displaySmall?.copyWith(
            color: Colors.white,
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 96,
            height: 96,
            color: Colors.white.withValues(alpha: 0.18),
            child: image == null || image.isEmpty
                ? const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 58,
                  )
                : Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 58,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: text.headlineSmall?.copyWith(
            color: Colors.white,
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.position?.isNotEmpty == true ? user.position! : '-',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: Colors.white),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _infoSection(UserModel user) {
    return _section(
      child: Column(
        children: [
          _info(Icons.badge_outlined, 'NIK', user.nik),
          _info(Icons.email_outlined, 'Email', user.email),
          _info(Icons.phone_outlined, 'Phone', user.phone),
          _info(Icons.location_on_outlined, 'Address', user.alamat, last: true),
        ],
      ),
    );
  }

  Widget _attendanceSection(UserAttendanceTotal total) {
    final values = {
      AttendanceStatus.present: total.present,
      AttendanceStatus.late: total.late,
      AttendanceStatus.leave: total.leave,
      AttendanceStatus.absent: total.absent,
    };

    return _section(
      child: Column(
        children: [
          for (final item in _stats)
            _stat(
              icon: item.$3,
              label: item.$2,
              value: values[item.$1] ?? 0,
              color: item.$1.accentColor,
              last: item == _stats.last,
            ),
        ],
      ),
    );
  }

  Widget _logoutButton() {
    return FilledButton.icon(
      onPressed: _isLoggingOut ? null : _logout,
      icon: _isLoggingOut
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.logout_rounded),
      label: Text(_isLoggingOut ? 'Logging out...' : 'Logout'),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(AppColors.danger),
        disabledBackgroundColor: const Color(0xFFEBF4F6),
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);

    try {
      await AuthService.logout();
    } finally {
      await SessionManager.clearSession();
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  Widget _info(
    IconData icon,
    String label,
    String? value, {
    bool last = false,
  }) {
    return _row(
      icon: icon,
      label: label,
      value: value?.isNotEmpty == true ? value! : '-',
      last: last,
    );
  }

  Widget _stat({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
    required bool last,
  }) {
    return _row(
      icon: icon,
      label: label,
      value: '$value',
      color: color,
      valueWeight: FontWeight.w700,
      last: last,
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    required String value,
    Color color = _muted,
    FontWeight valueWeight = FontWeight.w500,
    bool last = false,
  }) {
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: text.bodyMedium?.copyWith(color: _muted),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: text.bodyMedium?.copyWith(
                  color: _ink,
                  fontWeight: valueWeight,
                ),
              ),
            ),
          ],
        ),
        if (!last) const Divider(height: 22, color: _line),
      ],
    );
  }

  Widget _section({required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }

  Widget _message(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFB91C1C)),
        ),
      ),
    );
  }
}
