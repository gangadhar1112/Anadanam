import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search Anadanam, temple, area...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Searches',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildRecentTag('Temple Anadanam'),
                _buildRecentTag('Whitefield'),
                _buildRecentTag('Lunch Today'),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Suggested for you',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildSuggestedItem(context, Icons.near_me, 'Near Me'),
            _buildSuggestedItem(context, Icons.access_time, 'Serving Now'),
            _buildSuggestedItem(context, Icons.restaurant, 'Community Food'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTag(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.grey[100],
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: () {},
    );
  }

  Widget _buildSuggestedItem(BuildContext context, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
