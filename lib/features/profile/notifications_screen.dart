import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Today',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            context,
            '🍚',
            'Free food available near you',
            'Sri Sai Anadanam is serving lunch 1.2 km away.',
            '12 min ago',
            isUnread: true,
          ),
          _buildNotificationItem(
            context,
            '⏰',
            'Anadanam starts in 30 minutes',
            'Temple Anadanam near you starts at 12:00 PM.',
            '45 min ago',
            isUnread: true,
          ),
          const SizedBox(height: 32),
          const Text(
            'Earlier',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            context,
            '✓',
            'Post Approved',
            'Your Anadanam submission has been approved.',
            '2 hours ago',
          ),
          _buildNotificationItem(
            context,
            '💬',
            'New Comment',
            'Priya commented on your post: "Very helpful information."',
            '5 hours ago',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    String icon,
    String title,
    String body,
    String time, {
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.primaryLight.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? AppColors.primaryLight : Colors.grey[200]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
