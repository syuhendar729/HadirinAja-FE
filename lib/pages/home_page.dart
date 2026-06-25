import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/action_card.dart';
import '../widgets/home_header.dart';
import 'check_in_page.dart';
import 'permission_page.dart';

const _teal = Color(AppColors.teal);
const _line = Color(0xFFE5E7EB);
const _primary = Color(0xFF2563EB);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<UserModel> _future = UserService.getUser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _teal,
      body: FutureBuilder<UserModel>(
        future: _future,
        builder: (context, snap) {
          final name = snap.data?.name ?? '-';

          return Column(
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.42,
                width: double.infinity,
                child: SafeArea(
                  bottom: false,
                  child: snap.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : snap.hasError
                      ? _error(snap.error.toString())
                      : HomeHeader(name: name),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 38, 24, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(56),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 120),
                    children: [
                      ActionCard(
                        title: 'Check In',
                        subtitle: 'Take a selfie and verify your location.',
                        icon: Icons.login_rounded,
                        color: _primary,
                        onTap: () => _open(
                          const CheckInPage(),
                          'Check-in submitted successfully',
                        ),
                      ),
                      const SizedBox(height: 14),
                      ActionCard(
                        title: 'Leave',
                        subtitle: 'Request leave when you cannot attend.',
                        icon: Icons.event_available_rounded,
                        color: const Color(0xFFF59E0B),
                        onTap: () => _open(
                          const PermissionPage(),
                          'Leave request submitted',
                        ),
                      ),
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

  Future<void> _open(Widget page, String message) async {
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (!mounted || success != true) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _error(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFB91C1C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
