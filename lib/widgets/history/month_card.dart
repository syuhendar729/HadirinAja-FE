import 'package:flutter/material.dart';

class MonthCard extends StatelessWidget {
  final String monthName;

  final int totalPresent;

  final int totalDays;

  final VoidCallback onTap;

  const MonthCard({
    super.key,

    required this.monthName,

    required this.totalPresent,

    required this.totalDays,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(24),

      child: Container(
        margin: const EdgeInsets.only(bottom: 20),

        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(24),

          border: Border.all(color: Colors.grey.shade300),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),

              blurRadius: 10,

              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              monthName,

              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              '$totalPresent/$totalDays Days Present',

              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
