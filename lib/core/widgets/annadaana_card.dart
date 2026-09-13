import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import 'status_badge.dart';

class AnnaDaanCard extends StatelessWidget {
  final String? postId;
  final String title;
  final String type;
  final String distance;
  final String time;
  final String food;
  final double? latitude;
  final double? longitude;
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
    this.postId,
    required this.title,
    required this.type,
    required this.distance,
    required this.time,
    required this.food,
    this.latitude,
    this.longitude,
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
                        label: comments > 0
                            ? '$comments ${comments == 1 ? 'Comment' : 'Comments'}'
                            : 'Comments',
                        onPressed: onChatTap ?? () {},
                      ),
                      const Spacer(),
                      _ActionButton(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        onPressed: () {
                          String mapUrl = '';
                          if (latitude != null && longitude != null) {
                            mapUrl = '\n📍 Map: https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
                          }

                          Share.share(
                            'Join us for Anadanam at $title!$mapUrl\n\n'
                            '🍴 Food: $food\n'
                            '⏰ Time: $time\n\n'
                            'Download the Anadanam app to find more food services around you.',
                          );
                        },
                      ),
                    ],
                  ),
                  if (postId != null && comments > 0) ...[
                    const SizedBox(height: 12),
                    _RecentCommentsPreview(
                      postId: postId!,
                      commentCount: comments,
                      onTap: onChatTap,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentCommentsPreview extends StatelessWidget {
  final String postId;
  final int commentCount;
  final VoidCallback? onTap;

  const _RecentCommentsPreview({
    required this.postId,
    required this.commentCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('anadanam')
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .limit(2)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs;

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Comments ($commentCount)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final userName = data['userName'] ?? 'User';
                final text = data['text'] ?? '';

                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: InkWell(
                    onTap: onTap,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 9,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: data['userPhoto'] != null &&
                                  (data['userPhoto'] as String).isNotEmpty
                              ? NetworkImage(data['userPhoto'])
                              : null,
                          child: data['userPhoto'] == null ||
                                  (data['userPhoto'] as String).isEmpty
                              ? Text(
                                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(
                                  text: '$userName: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: text),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
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
