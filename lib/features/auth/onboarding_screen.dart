import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_colors.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const Spacer(),
              FadeInDown(
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.volunteer_activism,
                      size: 150,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              FadeInUp(
                child: Column(
                  children: [
                    Text(
                      'Free food, closer to you.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Discover Anadanam and free food services happening around you.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text('Continue with Mobile OTP'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        // Navigate to Guest Dashboard
                      },
                      child: Text(
                        'Continue as Guest',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your location helps us show food services near you.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
