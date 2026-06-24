// file: lib/pages/home_page.dart

import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/action_card.dart';
import '../widgets/home_header.dart';
import 'check_in_page.dart';
import 'permission_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      body: SafeArea(
        child: FutureBuilder<UserModel>(
          future: _userFuture,
          builder: (context, snapshot) {
            final user = snapshot.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TopBar(),
                  const SizedBox(height: 18),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const _HeaderLoadingCard()
                  else if (snapshot.hasError)
                    _ErrorCard(message: snapshot.error.toString())
                  else
                    HomeHeader(name: user?.name ?? '-'),
                  const SizedBox(height: 22),
                  if (user != null) _AttendanceSummaryCard(total: user.total),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    title: 'Quick actions',
                    subtitle: 'Choose what you need for today',
                  ),
                  const SizedBox(height: 12),
                  ActionCard(
                    title: 'Check In',
                    subtitle: 'Take a selfie and verify your location.',
                    meta: 'Start attendance',
                    icon: Icons.login_rounded,
                    color: const Color(0xFF16A34A),
                    onTap: () async {
                      final success = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (_) => const CheckInPage()),
                      );

                      if (!context.mounted) {
                        return;
                      }

                      if (success == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Check-in submitted successfully'),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  ActionCard(
                    title: 'Permission',
                    subtitle:
                        'Request permission when you cannot attend on time.',
                    meta: 'Request permission',
                    icon: Icons.event_available_rounded,
                    color: const Color(0xFFF59E0B),
                    onTap: () async {
                      final success = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PermissionPage(),
                        ),
                      );

                      if (!context.mounted) {
                        return;
                      }

                      if (success == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Permission request submitted'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderLoadingCard extends StatelessWidget {
  const _HeaderLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFFB91C1C),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HadirinAja',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 4),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notifications',
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF111827),
            fixedSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttendanceSummaryCard extends StatelessWidget {
  final UserAttendanceTotal total;

  const _AttendanceSummaryCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.fact_check_rounded,
              color: Color(0xFF16A34A),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${total.attendance} attendances recorded',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Late ${total.late} | Permission ${total.permission} | Alpha ${total.alpha}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: 1.35,
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              total.attendance.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF16A34A),
              ),
            ),
          ),
        ],
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
