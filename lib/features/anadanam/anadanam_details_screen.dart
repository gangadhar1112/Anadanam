import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/auth_service.dart';
import '../chat/chat_detail_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers/location_provider.dart';

class AnadanamDetailsScreen extends ConsumerWidget {
  final Map<String, dynamic> data;
  
  const AnadanamDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distance = ref.watch(locationProvider.notifier).calculateDistance(
          data['latitude'] as double?,
          data['longitude'] as double?,
        );

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: _buildContent(context, distance),
              ),
            ],
          ),
          // Floating Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          _buildBottomAction(context, ref),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final String? imageUrl = data['imageUrl'];
    Widget imageWidget;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('data:image') || !imageUrl.startsWith('http')) {
        try {
          final String base64Str = imageUrl.contains(',') 
              ? imageUrl.split(',').last 
              : imageUrl;
          imageWidget = Image.memory(
            base64Decode(base64Str),
            fit: BoxFit.cover,
          );
        } catch (e) {
          imageWidget = _buildPlaceholder();
        }
      } else {
        imageWidget = Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    } else {
      imageWidget = _buildPlaceholder();
    }

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.charcoal),
              onPressed: () {
                final name = data['name'] ?? 'Anadanam';
                final address = data['address'] ?? '';
                final food = data['foodDetails'] ?? '';
                Share.share(
                  'Join us for Anadanam at $name!\n\n'
                  '📍 Location: $address\n'
                  '🍴 Food: $food\n'
                  '⏰ Time: ${data['startTime']} - ${data['endTime']}\n\n'
                  'Download the Anadanam app to find more food services around you.',
                );
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: imageWidget,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.image, size: 80, color: Colors.grey)),
    );
  }

  Widget _buildContent(BuildContext context, String distance) {
    final foodDetails = data['foodDetails'] as String? ?? '';
    final foodList = foodDetails.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data['name'] ?? 'No Name',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (data['isVerified'] ?? false)
                const Icon(Icons.verified, color: Colors.blue, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data['type'] ?? 'Community Food',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const StatusBadge(status: ServingStatus.servingNow),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 18, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    '${data['startTime']} – ${data['endTime']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    distance,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 40),
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            data['description'] ?? 'No description provided.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          if (foodList.isNotEmpty) ...[
            Text(
              'Food Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...foodList.map((item) => _buildFoodItem(item)),
            const SizedBox(height: 24),
          ],
          Text(
            'Location',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.place, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data['address'] ?? 'No address provided',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildMapPreview(),
          const SizedBox(height: 180), // More space to prevent overlap with bottom action bar
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    final lat = data['latitude'] as double?;
    final lng = data['longitude'] as double?;

    if (lat == null || lng == null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Location coordinates not available', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    final position = LatLng(lat, lng);

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: position,
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('anadanam_location'),
              position: position,
            ),
          },
          // Disable interactions for preview mode
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  Widget _buildFoodItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, WidgetRef ref) {
    Future<void> openMapDirections() async {
      final lat = data['latitude'] as double?;
      final lng = data['longitude'] as double?;
      if (lat == null || lng == null) return;

      final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open map directions.')),
          );
        }
      }
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: openMapDirections,
                icon: const Icon(Icons.navigation_outlined),
                label: const Text('GET DIRECTIONS'),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () async {
                try {
                  final otherUserId = data['userId'];
                  final otherUserName = data['name'] ?? 'Provider';
                  
                  if (otherUserId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Provider information not available.')),
                    );
                    return;
                  }
                  
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );

                  final chatId = await ref.read(chatServiceProvider).getOrCreateChat(otherUserId, otherUserName);
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          chatId: chatId,
                          otherUserName: otherUserName,
                          otherUserId: otherUserId,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading if open
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to start chat: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primary,
                elevation: 0,
              ),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: (data['likedBy'] as List?)?.contains(ref.watch(authServiceProvider).currentUser?.uid) == true
                    ? Colors.red.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: () {
                  final userId = ref.read(authServiceProvider).currentUser?.uid;
                  if (userId != null) {
                    ref.read(firestoreServiceProvider).toggleLike(data['id'] ?? '', userId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please login to like.')),
                    );
                  }
                },
                icon: Icon(
                  (data['likedBy'] as List?)?.contains(ref.watch(authServiceProvider).currentUser?.uid) == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: (data['likedBy'] as List?)?.contains(ref.watch(authServiceProvider).currentUser?.uid) == true
                      ? Colors.red
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
