import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/datetime_helper.dart';

class HomeHeader extends StatefulWidget {
  final String name;

  const HomeHeader({super.key, this.name = 'Syuhada'});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F4C81),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C81).withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 38,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.76),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HeaderMetric(
                    label: 'Date',
                    value: DateTimeHelper.formattedDate(),
                    icon: Icons.calendar_month_rounded,
                  ),
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _HeaderMetric(
                    label: 'Time',
                    value: DateTimeHelper.formattedTime(),
                    icon: Icons.schedule_rounded,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 11) {
      return 'Good morning';
    }
    if (hour < 15) {
      return 'Good afternoon';
    }
    if (hour < 18) {
      return 'Good evening';
    }

    return 'Good night';
  }
}

class _HeaderMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool alignEnd;

  const _HeaderMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: alignEnd
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.76)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
