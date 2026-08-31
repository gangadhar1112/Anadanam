import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

enum ServingStatus {
  servingNow,
  startingSoon,
  upcoming,
  ended,
}

class StatusBadge extends StatelessWidget {
  final ServingStatus status;
  final String? customText;

  const StatusBadge({
    super.key,
    required this.status,
    this.customText,
  });

  static ServingStatus calculate(String startTimeStr, String endTimeStr) {
    if (startTimeStr.isEmpty || endTimeStr.isEmpty) return ServingStatus.upcoming;
    
    final now = DateTime.now();
    
    DateTime? parseTime(String timeStr) {
      try {
        final formats = [
          DateFormat.jm(), // "12:00 PM"
          DateFormat('h:mm a'),
          DateFormat('HH:mm'),
          DateFormat('H:mm'),
        ];

        for (var f in formats) {
          try {
            final parsed = f.parse(timeStr.trim());
            // Create DateTime for today
            return DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
          } catch (_) {}
        }
        return null;
      } catch (_) {
        return null;
      }
    }

    final startTime = parseTime(startTimeStr);
    final endTime = parseTime(endTimeStr);

    if (startTime == null || endTime == null) return ServingStatus.upcoming;

    // Handle case where endTime is after midnight (e.g., 10 PM to 2 AM)
    DateTime adjustedEndTime = endTime;
    if (endTime.isBefore(startTime)) {
      adjustedEndTime = endTime.add(const Duration(days: 1));
    }

    if (now.isAfter(startTime) && now.isBefore(adjustedEndTime)) {
      return ServingStatus.servingNow;
    } else if (now.isBefore(startTime)) {
      if (startTime.difference(now).inMinutes <= 60) {
        return ServingStatus.startingSoon;
      }
      return ServingStatus.upcoming;
    } else {
      return ServingStatus.ended;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case ServingStatus.servingNow:
        color = AppColors.success;
        text = '● SERVING NOW';
        break;
      case ServingStatus.startingSoon:
        color = AppColors.warning;
        text = 'STARTING SOON';
        break;
      case ServingStatus.upcoming:
        color = Colors.blue;
        text = 'UPCOMING';
        break;
      case ServingStatus.ended:
        color = AppColors.error;
        text = 'ENDED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status == ServingStatus.ended 
            ? color.withOpacity(0.2) 
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.5), 
          width: status == ServingStatus.ended ? 2 : 1.5,
        ),
      ),
      child: Text(
        customText ?? text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
