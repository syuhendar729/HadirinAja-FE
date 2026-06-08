import 'package:flutter/material.dart';

class YearCard extends StatelessWidget {
  final int year;

  final int totalAttendance;

  final VoidCallback onTap;

  const YearCard({
    super.key,

    required this.year,

    required this.totalAttendance,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(20),

      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: Colors.grey.shade300),
        ),

        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 32),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    year.toString(),

                    style: const TextStyle(
                      fontSize: 20,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text('$totalAttendance Attendances'),
                ],
              ),
            ),

            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
