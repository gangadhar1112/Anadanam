import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'recurring_schedule_screen.dart';

class LocationSelectionScreen extends StatelessWidget {
  const LocationSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: Stack(
        children: [
          // Mock Map
          Container(
            color: Colors.blue[50],
            child: const Center(
              child: Icon(Icons.location_on, size: 60, color: AppColors.primary),
            ),
          ),
          
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.textHint),
                  SizedBox(width: 12),
                  Text('Search for a location...', style: TextStyle(color: AppColors.textHint)),
                ],
              ),
            ),
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your current location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Whitefield, Bengaluru, Karnataka 560066',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RecurringScheduleScreen()),
                      );
                    },
                    child: const Text('Use This Location'),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Adjust location manually'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
