import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/action_card.dart';
import '../widgets/home_header.dart';
import 'check_in_page.dart';
import 'permission_page.dart';

const _bg = Color(0xFFF7F7F8);
const _ink = Color(0xFF111827);
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
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FutureBuilder<UserModel>(
          future: _future,
          builder: (context, snap) {
            final user = snap.data;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _topBar(text),
                const SizedBox(height: 14),
                if (snap.connectionState == ConnectionState.waiting)
                  _section(
                    child: const SizedBox(
                      height: 118,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (snap.hasError)
                  _message(snap.error.toString())
                else
                  HomeHeader(name: user?.name ?? '-'),
                const SizedBox(height: 18),
                Text(
                  'Quick Actions',
                  style: text.titleMedium?.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _section(
                  padding: EdgeInsets.zero,
                  child: Column(
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
                      const Divider(height: 1, color: _line),
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
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _topBar(TextTheme text) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'HadirinAja',
            style: text.titleLarge?.copyWith(
              color: _ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_none_rounded),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _ink,
            fixedSize: const Size(42, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: _line),
            ),
          ),
        ),
      ],
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

  Widget _section({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(padding: padding, child: child),
    );
  }

  Widget _message(String message) {
    return _section(
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFFB91C1C),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
