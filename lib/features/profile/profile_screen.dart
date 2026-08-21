import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(context),
            const SizedBox(height: 32),
            _buildMenu(context),
            const SizedBox(height: 32),
            _buildLogoutButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, size: 80, color: AppColors.primary),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.edit, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Rahul Sharma',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '+91 98765 43210',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMenuItem(context, Icons.restaurant_menu, 'My Anadanam', onPressed: () {}),
          _buildMenuItem(context, Icons.favorite_border, 'Liked Posts', onPressed: () {}),
          _buildMenuItem(context, Icons.chat_bubble_outline, 'My Comments', onPressed: () {}),
          const Divider(height: 40),
          _buildMenuItem(context, Icons.notifications_none, 'Notification Settings', onPressed: () {}),
          _buildMenuItem(context, Icons.location_on_outlined, 'Location Settings', onPressed: () {}),
          _buildMenuItem(context, Icons.language, 'Language', trailing: 'English', onPressed: () {}),
          const Divider(height: 40),
          _buildMenuItem(context, Icons.privacy_tip_outlined, 'Privacy Policy', onPressed: () {}),
          _buildMenuItem(context, Icons.help_outline, 'Help & Support', onPressed: () {}),
          _buildMenuItem(context, Icons.info_outline, 'About AnnaDaan', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title, {
    String? trailing,
    required VoidCallback onPressed,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.charcoal, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
        ],
      ),
      onTap: onPressed,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
        ),
        child: const Text('Logout'),
      ),
    );
  }
}
