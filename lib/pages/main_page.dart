import 'package:flutter/material.dart';

import '../config/app_config.dart';
import 'history/history_year_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

const _teal = Color(AppColors.primary);
const _inactive = Color(AppColors.textSecondary);
const _bar = Color(AppColors.background);
const _pill = Color(AppColors.border);

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1;

  final _pages = const [HistoryYearPage(), HomePage(), ProfilePage()];
  final _items = const [
    (Icons.assignment_outlined, 'History'),
    (Icons.home_rounded, 'Home'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _bar,
            borderRadius: BorderRadius.circular(44),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(child: _tab(i, _items[i].$1, _items[i].$2)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(int index, IconData icon, String label) {
    final selected = _selectedIndex == index;
    final color = selected ? _teal : _inactive;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(34),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _pill : Colors.transparent,
          borderRadius: BorderRadius.circular(34),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: selected ? 30 : 27),
            const SizedBox(height: 3),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
