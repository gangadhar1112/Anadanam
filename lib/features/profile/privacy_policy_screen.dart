import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy for AnnaDaan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last updated: September 2026',
              style: TextStyle(color: AppColors.textHint),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Information Collection',
              'We collect information you provide directly to us when you create an account, share food details, or interact with other users. This includes your name, email address, and location data.',
            ),
            _buildSection(
              '2. Use of Location',
              'AnnaDaan uses your real-time location to help you find nearby food services and to notify you of food donations within a 3km radius. This is central to our mission of providing timely food access.',
            ),
            _buildSection(
              '3. Data Security',
              'We use industry-standard security measures provided by Firebase to protect your data. We do not sell your personal information to third parties.',
            ),
            _buildSection(
              '4. Community Standards',
              'By using AnnaDaan, you agree to post only genuine and accurate food donation details. Misleading information may lead to account suspension.',
            ),
            _buildSection(
              '5. Contact Us',
              'For any privacy concerns, contact VG Software Solutions at gangadharg1112@gmail.com.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
