import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/in_app_update_service.dart';
import 'my_anadanam_screen.dart';
import 'privacy_policy_screen.dart';
import 'help_support_screen.dart';
import 'about_anadanam_screen.dart';
import '../admin/admin_dashboard.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showImageSourcePicker(BuildContext context, WidgetRef ref, String uid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Profile Picture',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.camera_alt, color: AppColors.primary),
                  ),
                  title: const Text('Take Photo (Camera)', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadImage(context, ref, uid, ImageSource.camera);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.photo_library, color: AppColors.primary),
                  ),
                  title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndUploadImage(context, ref, uid, ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(
    BuildContext context,
    WidgetRef ref,
    String uid,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 70,
    );

    if (pickedFile == null) return;

    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading profile image...')),
        );
      }

      final bytes = await File(pickedFile.path).readAsBytes();
      final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'photoUrl': base64String,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save to Firebase Auth
      final user = ref.read(authServiceProvider).currentUser;
      if (user != null) {
        await user.updatePhotoURL(base64String);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    }
  }

  Widget _buildAvatarWidget(String? photoUrl) {
    if (photoUrl == null || photoUrl.trim().isEmpty) {
      return const CircleAvatar(
        radius: 60,
        backgroundColor: AppColors.primaryLight,
        child: Icon(Icons.person, size: 70, color: AppColors.primary),
      );
    }

    if (photoUrl.startsWith('data:image') || !photoUrl.startsWith('http')) {
      try {
        final String base64Str = photoUrl.contains(',')
            ? photoUrl.split(',').last
            : photoUrl;
        return CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: MemoryImage(base64Decode(base64Str)),
        );
      } catch (_) {
        return const CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.primaryLight,
          child: Icon(Icons.person, size: 70, color: AppColors.primary),
        );
      }
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: AppColors.primaryLight,
      backgroundImage: NetworkImage(photoUrl),
    );
  }

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
                      _buildProfileHeader(context, ref, user.uid, displayName, email, photoUrl),
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

  Widget _buildProfileHeader(
    BuildContext context,
    WidgetRef ref,
    String uid,
    String name,
    String email,
    String? photoUrl,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () => _showImageSourcePicker(context, ref, uid),
          borderRadius: BorderRadius.circular(60),
          child: Stack(
            children: [
              _buildAvatarWidget(photoUrl),
              const Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
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
          _buildMenuItem(
            context, 
            Icons.system_update_outlined, 
            'Check for Updates', 
            onPressed: () {
              InAppUpdateService.manualCheckForUpdate(context);
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
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
