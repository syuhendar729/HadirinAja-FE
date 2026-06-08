// file: lib/pages/home_page.dart

import 'package:flutter/material.dart';

import '../widgets/home_header.dart';
import '../widgets/action_card.dart';
import 'check_in_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HadirinAja'), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const HomeHeader(),

            const SizedBox(height: 24),

            ActionCard(
              title: 'Check In',
              subtitle: 'Mark Attendance',
              icon: Icons.access_time,

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
                    const SnackBar(content: Text('Check-in berhasil dikirim')),
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            ActionCard(
              title: 'Permission',
              subtitle: 'Request Permission',
              icon: Icons.calendar_today,

              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Permission Clicked')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
