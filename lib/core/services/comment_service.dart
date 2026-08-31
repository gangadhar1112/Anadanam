import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';

final commentServiceProvider = Provider((ref) => CommentService(ref));

class CommentService {
  final Ref _ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CommentService(this._ref);

  // Get comments for a specific post
  Stream<QuerySnapshot> getComments(String postId) {
    return _db
        .collection('anadanam')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  // Add a comment
  Future<void> addComment(String postId, String text) async {
    final user = _ref.read(authServiceProvider).currentUser;
    if (user == null) throw Exception('User not logged in');

    final commentData = {
      'userId': user.uid,
      'userName': (user.displayName != null && user.displayName!.isNotEmpty) 
          ? user.displayName 
          : 'Anonymous',
      'userPhoto': user.photoURL,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Use a transaction to add comment and increment count
    await _db.runTransaction((transaction) async {
      DocumentReference postRef = _db.collection('anadanam').doc(postId);
      DocumentSnapshot postSnapshot = await transaction.get(postRef);

      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }

      // Add comment to subcollection
      transaction.set(postRef.collection('comments').doc(), commentData);

      // Increment comments count in main post
      transaction.update(postRef, {
        'comments': FieldValue.increment(1),
      });
    });
  }

  // Delete a comment
  Future<void> deleteComment(String postId, String commentId) async {
    final user = _ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final commentRef = _db.collection('anadanam').doc(postId).collection('comments').doc(commentId);
    final commentDoc = await commentRef.get();
    
    if (commentDoc.exists && commentDoc['userId'] == user.uid) {
      await _db.runTransaction((transaction) async {
        transaction.delete(commentRef);
        transaction.update(_db.collection('anadanam').doc(postId), {
          'comments': FieldValue.increment(-1),
        });
      });
    }
  }
}
