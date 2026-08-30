import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';

final chatServiceProvider = Provider((ref) => ChatService(ref));

class ChatService {
  final Ref _ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ChatService(this._ref);

  // Get all chats for the current user
  Stream<QuerySnapshot> getMyChats() {
    final user = _ref.read(authServiceProvider).currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .snapshots();
  }

  // Get messages for a specific chat
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Send a message
  Future<void> sendMessage(String chatId, String text, String receiverId) async {
    final user = _ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final messageData = {
      'senderId': user.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Add message to subcollection
    await _db.collection('chats').doc(chatId).collection('messages').add(messageData);

    // Update chat metadata
    await _db.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': FieldValue.increment(1),
    });
  }

  // Create or get existing chat
  Future<String> getOrCreateChat(String otherUserId, String otherUserName) async {
    final user = _ref.read(authServiceProvider).currentUser;
    if (user == null) throw Exception('User not logged in');

    // Check if chat already exists
    final existingChat = await _db
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .get();

    for (var doc in existingChat.docs) {
      List participants = doc['participants'];
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    // Create new chat
    final newChat = await _db.collection('chats').add({
      'participants': [user.uid, otherUserId],
      'participantNames': {
        user.uid: user.displayName ?? 'User',
        otherUserId: otherUserName,
      },
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': 0,
    });

    return newChat.id;
  }
}
