import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ServingStatus {
  servingNow,
  startingSoon,
  today,
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
      case ServingStatus.today:
        color = AppColors.primary;
        text = 'TODAY';
        break;
      case ServingStatus.ended:
        color = AppColors.textHint;
        text = 'ENDED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
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
