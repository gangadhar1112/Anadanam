import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AboutAnadanamScreen extends StatelessWidget {
  const AboutAnadanamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About AnnaDaan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'AnnaDaan',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: AppColors.textHint),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Our Moto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Helping every person get access to free, healthy food. We believe that no one should go hungry when there is food to share.',
              style: TextStyle(fontSize: 16, height: 1.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            const Text(
              'What is AnnaDaan?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'AnnaDaan is a community-driven platform that connects food donors with those in need. Whether it\'s a temple, an NGO, or a community event, we help you find and share free food services in real-time.',
              style: TextStyle(fontSize: 16, height: 1.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Developed with ❤️ by',
                style: TextStyle(color: AppColors.textHint),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'VG Software Solutions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
