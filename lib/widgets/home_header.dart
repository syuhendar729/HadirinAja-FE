import 'dart:async';

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../utils/datetime_helper.dart';

class HomeHeader extends StatefulWidget {
  final String name;

  const HomeHeader({super.key, required this.name});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 20),
      child: Column(
        children: [
          Text(
            'HadirinAja',
            style: text.displaySmall?.copyWith(
              color: Colors.white,
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.person_rounded, color: Colors.white, size: 116),
              const SizedBox(width: 28),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateTimeHelper.formattedDate(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium?.copyWith(
                        color: Colors.white,
                        fontFamily: AppFonts.mono,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      DateTimeHelper.formattedTimeWithPeriod(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.displaySmall?.copyWith(
                        color: Colors.white,
                        fontFamily: AppFonts.mono,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
