import 'package:flutter/material.dart';

import '../models/attendance_model.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

const _bg = Color(0xFFF7F7F8);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF6B7280);
const _line = Color(0xFFE5E7EB);
const _primary = Color(0xFF2563EB);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _bg,
        foregroundColor: _ink,
      ),
      body: FutureBuilder<UserModel>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return _message(snap.error.toString());
          if (snap.data == null) return _message('User data is empty');

          final user = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _profileHeader(user),
              const SizedBox(height: 12),
              _infoSection(user),
              const SizedBox(height: 12),
              _attendanceSection(user.total),
            ],
          );
        },
      ),
    );
  }

  Widget _profileHeader(UserModel user) {
    final text = Theme.of(context).textTheme;
    final image = user.profilePicture;

    return _section(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 64,
              height: 64,
              color: const Color(0xFFEFF6FF),
              child: image == null || image.isEmpty
                  ? const Icon(Icons.person_rounded, color: _primary, size: 36)
                  : Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.person_rounded,
                        color: _primary,
                        size: 36,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleLarge?.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.position?.isNotEmpty == true ? user.position! : '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
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
