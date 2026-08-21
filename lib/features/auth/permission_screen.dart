import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PermissionScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const PermissionScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onAllow,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 80, color: AppColors.primary),
            ),
            const SizedBox(height: 40),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: onAllow,
              child: const Text('Allow'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onDeny,
              child: const Text(
                'Not now',
                style: TextStyle(color: AppColors.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
