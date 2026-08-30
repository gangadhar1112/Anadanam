import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/auth_service.dart';
import 'chat_detail_screen.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authServiceProvider).currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: currentUserId == null
          ? const Center(child: Text('Please login to view messages'))
          : StreamBuilder<QuerySnapshot>(
              stream: ref.watch(chatServiceProvider).getMyChats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final chats = snapshot.data?.docs ?? [];

                if (chats.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 60, color: AppColors.textHint),
                        SizedBox(height: 16),
                        Text('No conversations yet', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: chats.length,
                  separatorBuilder: (context, index) => const Divider(height: 32),
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final data = chat.data() as Map<String, dynamic>;
                    final participants = data['participants'] as List;
                    final otherUserId = participants.firstWhere((id) => id != currentUserId);
                    final otherUserName = (data['participantNames'] as Map)[otherUserId] ?? 'User';
                    final lastMessage = data['lastMessage'] ?? '';
                    final timestamp = data['lastMessageTime'] as Timestamp?;
                    final timeStr = timestamp != null
                        ? DateFormat.jm().format(timestamp.toDate())
                        : '';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          otherUserName[0].toUpperCase(),
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            otherUserName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            timeStr,
                            style: TextStyle(color: AppColors.textHint, fontSize: 12),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              chatId: chat.id,
                              otherUserName: otherUserName,
                              otherUserId: otherUserId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
