import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/comment_service.dart';
import '../../core/services/auth_service.dart';

class CommentsSection extends ConsumerStatefulWidget {
  final String postId;
  final ScrollController? scrollController;

  const CommentsSection({super.key, required this.postId, this.scrollController});

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    _commentController.clear();
    setState(() => _isSubmitting = true);
    try {
      await ref.read(commentServiceProvider).addComment(widget.postId, text);
      if (mounted) {
        // Scroll to top to show the new comment
        widget.scrollController?.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        _commentController.text = text; // Restore text on error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(authServiceProvider).currentUser?.uid;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ref.watch(commentServiceProvider).getComments(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('No comments yet. Be the first!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final commentId = docs[index].id;
                    return _buildCommentItem(context, data, commentId, currentUserId);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildCommentItem(BuildContext context, Map<String, dynamic> data, String commentId, String? currentUserId) {
    final bool isMe = data['userId'] == currentUserId;
    final timestamp = data['timestamp'] as Timestamp?;
    final timeStr = timestamp != null 
        ? DateFormat('MMM d, h:mm a').format(timestamp.toDate()) 
        : 'just now';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: data['userPhoto'] != null ? NetworkImage(data['userPhoto']) : null,
            child: data['userPhoto'] == null 
                ? Text(
                    (data['userName'] != null && data['userName'].toString().isNotEmpty)
                        ? data['userName'][0].toUpperCase()
                        : 'U',
                    style: const TextStyle(color: AppColors.primary, fontSize: 12),
                  ) 
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data['userName'] ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeStr,
                      style: TextStyle(color: AppColors.textHint, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['text']?.toString() ?? '',
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
          if (isMe)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textHint),
              onPressed: () => ref.read(commentServiceProvider).deleteComment(widget.postId, commentId),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        color: Colors.grey[50],
        child: const Center(child: Text('Please login to comment')),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + MediaQuery.of(context).viewInsets.bottom + 30,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Share your thoughts or ask a question...',
                hintStyle: const TextStyle(fontSize: 14),
                fillColor: Colors.grey[100],
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _isSubmitting
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _submitComment,
                ),
        ],
      ),
    );
  }
}
