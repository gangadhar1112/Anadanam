import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import 'status_badge.dart';

class AnnaDaanCard extends StatelessWidget {
  final String title;
  final String type;
  final String distance;
  final String time;
  final String food;
  final String? imageUrl;
  final File? imageFile;
  final ServingStatus status;
  final bool isVerified;
  final int likes;
  final bool isLiked;
  final int comments;
  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onChatTap;

  const AnnaDaanCard({
    super.key,
    required this.title,
    required this.type,
    required this.distance,
    required this.time,
    required this.food,
    this.imageUrl,
    this.imageFile,
    required this.status,
    this.isVerified = false,
    this.likes = 0,
    this.isLiked = false,
    this.comments = 0,
    this.onTap,
    this.onLikeTap,
    this.onChatTap,
  });

  Widget _buildImage() {
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    final String? localImageUrl = imageUrl;
    if (localImageUrl != null && localImageUrl.isNotEmpty) {
      // Check if it's a Base64 string
      if (localImageUrl.startsWith('data:image') || !localImageUrl.startsWith('http')) {
        try {
          final String base64Str = localImageUrl.contains(',') 
              ? localImageUrl.split(',').last 
              : localImageUrl;
          return Image.memory(
            base64Decode(base64Str),
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            cacheWidth: 800, // Optimize memory usage
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
        } catch (e) {
          return _buildPlaceholder();
        }
      }

      // Normal Network Image
      return Image.network(
        localImageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      color: Colors.grey[200],
      child: const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                _buildImage(),
                Positioned(
                  top: 12,
                  left: 12,
                  child: StatusBadge(status: status),
                ),
                if (isVerified)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.blue, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        distance,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.restaurant, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          food,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      _ActionButton(
                        icon: isLiked ? Icons.favorite : Icons.favorite_border,
                        iconColor: isLiked ? Colors.red : null,
                        label: likes.toString(),
                        onPressed: onLikeTap ?? () {},
                      ),
                      const SizedBox(width: 16),
                      _ActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: 'Chat',
                        onPressed: onChatTap ?? () {},
                      ),
                      const Spacer(),
                      _ActionButton(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        onPressed: () {
                          Share.share(
                            'Join us for Anadanam at $title!\n\n'
                            '🍴 Food: $food\n'
                            '⏰ Time: $time\n\n'
                            'Download the Anadanam app to find more food services around you.',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
