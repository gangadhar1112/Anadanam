import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Anadanam Collection
  CollectionReference get anadanamCollection => _db.collection('anadanam');

  // Add new Anadanam
  Future<void> addAnadanam(Map<String, dynamic> data) async {
    await anadanamCollection.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'approved', // Changed from 'pending' for development testing
    });
  }

  // Stream active Anadanam with advanced filters
  Stream<QuerySnapshot> streamActiveAnadanam({
    String? category,
    String? foodType,
    double? maxDistance, // Placeholder for future geo-queries
  }) {
    Query query = anadanamCollection.where('status', isEqualTo: 'approved');
    
    if (category != null && category != 'All') {
      query = query.where('type', isEqualTo: category);
    }
    
    // Temporarily removed orderBy to bypass all composite index requirements.
    // This allows categories like 'Temple' to work instantly.
    return query.snapshots();
  }

  // Search Anadanam by name
  Stream<QuerySnapshot> searchAnadanam(String queryText) {
    return anadanamCollection
        .where('status', isEqualTo: 'approved')
        .where('name', isGreaterThanOrEqualTo: queryText)
        .where('name', isLessThanOrEqualTo: '$queryText\uf8ff')
        .limit(20)
        .snapshots();
  }

  // Get user profile
  Stream<DocumentSnapshot> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // Get user's Anadanam
  Stream<QuerySnapshot> streamUserAnadanam(String userId, {String? status}) {
    Query query = anadanamCollection.where('userId', isEqualTo: userId);
    
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    // Temporarily removed orderBy again to bypass the NEW composite index requirement.
    // Re-enable this once the index for status + expireAt + createdAt is built.
    return query.snapshots();
  }

  // Stream pending Anadanam (Admin)
  Stream<QuerySnapshot> streamPendingAnadanam() {
    return anadanamCollection
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update status (Admin)
  Future<void> updateAnadanamStatus(String id, String status) async {
    final doc = await anadanamCollection.doc(id).get();
    final data = doc.data() as Map<String, dynamic>?;

    await anadanamCollection.doc(id).update({'status': status});

    // Notify user if post is approved
    if (status == 'approved' && data != null) {
      final userId = data['userId'];
      if (userId != null) {
        await addNotification(userId, {
          'title': 'Post Approved',
          'body': 'Your Anadanam submission "${data['name']}" has been approved.',
          'icon': '✓',
          'type': 'status_update',
        });
      }
    }
  }

  // FCM Tokens
  Future<void> saveFcmToken(String uid, String token) async {
    await _db.collection('users').doc(uid).set({
      'fcmToken': token,
      'lastTokenUpdate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Notifications
  Stream<QuerySnapshot> streamUserNotifications(String uid) {
    return _db.collection('users').doc(uid).collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> addNotification(String uid, Map<String, dynamic> notification) async {
    await _db.collection('users').doc(uid).collection('notifications').add({
      ...notification,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Future<void> markNotificationAsRead(String uid, String notificationId) async {
    await _db.collection('users').doc(uid).collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  // Delete Anadanam post (Reject)
  Future<void> deleteAnadanam(String id) async {
    await anadanamCollection.doc(id).delete();
  }
}
