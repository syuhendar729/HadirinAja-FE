// File profile_page.dart

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final Future<UserModel> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = UserService.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F8FB),
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<UserModel>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ProfileError(message: snapshot.error.toString());
            }

            final user = snapshot.data;

            if (user == null) {
              return const _ProfileError(message: 'User data is empty');
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _ProfileHeader(user: user),
                const SizedBox(height: 22),
                const _SectionTitle(
                  title: 'Attendance summary',
                  subtitle: 'Your current attendance overview',
                ),
                const SizedBox(height: 12),
                _AttendanceStatsGrid(total: user.total),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserModel user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final profilePicture = user.profilePicture;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: profilePicture == null || profilePicture.isEmpty
                ? const Icon(
                    Icons.person_rounded,
                    size: 42,
                    color: Color(0xFF2563EB),
                  )
                : Image.network(
                    profilePicture,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person_rounded,
                      size: 42,
                      color: Color(0xFF2563EB),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                _ProfileInfoRow(
                  icon: Icons.badge_outlined,
                  label: user.nik?.isNotEmpty == true ? user.nik! : '-',
                ),
                const SizedBox(height: 6),
                _ProfileInfoRow(
                  icon: Icons.work_outline_rounded,
                  label: user.position?.isNotEmpty == true
                      ? user.position!
                      : '-',
                ),
                const SizedBox(height: 6),
                _ProfileInfoRow(icon: Icons.email_outlined, label: user.email),
                const SizedBox(height: 6),
                _ProfileInfoRow(
                  icon: Icons.phone_outlined,
                  label: user.phone?.isNotEmpty == true ? user.phone! : '-',
                ),
                const SizedBox(height: 6),
                _ProfileInfoRow(
                  icon: Icons.location_on_outlined,
                  label: user.alamat?.isNotEmpty == true ? user.alamat! : '-',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfileInfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF6B7280)),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttendanceStatsGrid extends StatelessWidget {
  final UserAttendanceTotal total;

  const _AttendanceStatsGrid({required this.total});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _AttendanceStatCard(
          icon: Icons.check_circle_outline_rounded,
          label: 'Attendance',
          value: total.attendance.toString(),
          color: const Color(0xFF16A34A),
        ),
        _AttendanceStatCard(
          icon: Icons.schedule_rounded,
          label: 'Late',
          value: total.late.toString(),
          color: const Color(0xFFF59E0B),
        ),
        _AttendanceStatCard(
          icon: Icons.description_outlined,
          label: 'Permission',
          value: total.permission.toString(),
          color: const Color(0xFF2563EB),
        ),
        _AttendanceStatCard(
          icon: Icons.cancel_outlined,
          label: 'Alpha',
          value: total.alpha.toString(),
          color: const Color(0xFFDC2626),
        ),
      ],
    );
  }
}

class _AttendanceStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _AttendanceStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.sizeOf(context).width - 52) / 2;

    return SizedBox(
      width: cardWidth,
      height: 140,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 23, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  final String message;

  const _ProfileError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFFB91C1C),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
