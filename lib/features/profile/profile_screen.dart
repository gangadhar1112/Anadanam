import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/notification_service.dart';
import 'my_anadanam_screen.dart';
import 'privacy_policy_screen.dart';
import 'help_support_screen.dart';
import 'about_anadanam_screen.dart';
import '../admin/admin_dashboard.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: user == null
          ? const Center(child: Text('Please login to view profile'))
          : StreamBuilder<DocumentSnapshot>(
              stream: firestoreService.getUserProfile(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData = snapshot.data?.data() as Map<String, dynamic>?;
                final displayName = userData?['displayName'] ?? 'User';
                final email = userData?['email'] ?? user.email ?? '';
                final photoUrl = userData?['photoUrl'] ?? user.photoURL;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileHeader(context, displayName, email, photoUrl),
                      const SizedBox(height: 32),
                      _buildMenu(context, ref),
                      const SizedBox(height: 32),
                      _buildLogoutButton(context, ref),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String email, String? photoUrl) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null ? const Icon(Icons.person, size: 80, color: AppColors.primary) : null,
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
          name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            email,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  Widget _buildMenu(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            Icons.restaurant_menu,
            'My Anadanam',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyAnadanamScreen()),
              );
            },
          ),
          if (authService.isAdmin) ...[
            const Divider(height: 40),
            _buildMenuItem(
              context,
              Icons.admin_panel_settings_outlined,
              'Admin Console',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminDashboard()),
                );
              },
            ),
          ],
          const Divider(height: 40),
          _buildMenuItem(
            context, 
            Icons.privacy_tip_outlined, 
            'Privacy Policy', 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
              );
            },
          ),
          _buildMenuItem(
            context, 
            Icons.help_outline, 
            'Help & Support', 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
              );
            },
          ),
          _buildMenuItem(
            context, 
            Icons.info_outline, 
            'About AnnaDaan', 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutAnadanamScreen()),
              );
            },
          ),
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

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton(
        onPressed: () async {
          await ref.read(authServiceProvider).signOut();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Logout'),
      ),
    );
  }
}
