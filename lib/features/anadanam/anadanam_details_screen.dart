import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/services/chat_service.dart';
import '../chat/chat_detail_screen.dart';

class AnadanamDetailsScreen extends ConsumerWidget {
  final Map<String, dynamic> data;
  
  const AnadanamDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: _buildContent(context),
              ),
            ],
          ),
          _buildBottomAction(context, ref),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final String? imageUrl = data['imageUrl'];
    Widget imageWidget;

    if (imageUrl != null) {
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
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.charcoal),
              onPressed: () {},
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

  Widget _buildContent(BuildContext context) {
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
          Row(
            children: [
              const StatusBadge(status: ServingStatus.servingNow),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 18, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                '${data['startTime']} – ${data['endTime']}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 16),
              const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textHint),
              const SizedBox(width: 4),
              const Text(
                '1.2 km away',
                style: TextStyle(fontSize: 14),
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
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('Map Preview Implementation'),
            ),
          ),
          const SizedBox(height: 100), // Space for bottom action
        ],
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
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
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
                onPressed: () {},
                icon: const Icon(Icons.navigation_outlined),
                label: const Text('GET DIRECTIONS'),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () async {
                final otherUserId = data['userId'];
                final otherUserName = data['name'] ?? 'Provider';
                if (otherUserId == null) return;
                
                final chatId = await ref.read(chatServiceProvider).getOrCreateChat(otherUserId, otherUserName);
                
                if (context.mounted) {
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
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
