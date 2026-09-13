import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Anadanam Collection
  CollectionReference get anadanamCollection => _db.collection('anadanam');

  // Add new Anadanam
  Future<void> addAnadanam(Map<String, dynamic> data) async {
    final docRef = await anadanamCollection.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'approved', // Changed from 'pending' for development testing
    });

    // Trigger nearby notifications
    notifyNearbyUsers({...data, 'id': docRef.id}, data['userId']);
  }

  // Stream active Anadanam with advanced filters
  Stream<QuerySnapshot> streamActiveAnadanam({
    String? category,
    double? maxDistance,
  }) {
    Query query = anadanamCollection.where('status', isEqualTo: 'approved');
    
    // Only apply type filter if the category matches known types
    final knownTypes = ['Temple', 'NGO', 'Community', 'Other', 'Others'];
    if (category != null && category != 'All' && knownTypes.contains(category)) {
      final targetType = category == 'Others' ? 'Other' : category;
      query = query.where('type', isEqualTo: targetType);
    }
    
    // Note: Breakfast, Lunch, Dinner, Serving Now filters are handled client-side 
    // in MainDashboard to avoid complex composite index requirements during dev.
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
        .snapshots();
  }

  // Stream all Anadanam (Admin)
  Stream<QuerySnapshot> streamAllAnadanam() {
    return anadanamCollection
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

  // Delete Anadanam post
  Future<void> deleteAnadanam(String id) async {
    await anadanamCollection.doc(id).delete();
  }

  // Cleanup expired posts (Extra safety layer)
  Future<void> cleanupExpiredPosts() async {
    final now = Timestamp.now();
    
    // 1. Delete posts where expireAt has passed
    final expiredDocs = await anadanamCollection.where('expireAt', isLessThan: now).get();
    
    // 2. Also find old posts that might be missing the expireAt field (migration/old data)
    final legacyDocs = await anadanamCollection.where('createdAt', isLessThan: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1)))).get();
    
    final allToRemove = {...expiredDocs.docs, ...legacyDocs.docs}.toList();

    if (allToRemove.isNotEmpty) {
      print('CLEANUP: Found ${allToRemove.length} expired/legacy posts. Deleting...');
      final batch = _db.batch();
      for (var doc in allToRemove) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  // Toggle Like
  Future<void> toggleLike(String id, String userId) async {
    final docRef = anadanamCollection.doc(id);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    final List likedBy = data['likedBy'] ?? [];

    if (likedBy.contains(userId)) {
      await docRef.update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
      await docRef.update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  // Update User Location
  Future<void> updateUserLocation(String uid, double lat, double lng) async {
    await _db.collection('users').doc(uid).set({
      'latitude': lat,
      'longitude': lng,
      'lastLocationUpdate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Notify Nearby Users
  Future<void> notifyNearbyUsers(Map<String, dynamic> postData, String currentUserId) async {
    try {
      final double? postLat = postData['latitude']?.toDouble();
      final double? postLng = postData['longitude']?.toDouble();
      
      if (postLat == null || postLng == null) {
        print('DEBUG: Post location is missing. Cannot send notifications.');
        return;
      }

      if (currentUserId.isEmpty) {
        print('DEBUG: currentUserId is empty. Notification logic aborted.');
        return;
      }

      print('DEBUG: --- PROXIMITY NOTIFICATION START ---');
      print('DEBUG: Post Location: $postLat, $postLng');
      print('DEBUG: Uploader UID: "$currentUserId"');

      // Get all users who have location data
      // We use GetOptions(source: Source.server) to bypass cache and get latest locations
      final usersSnapshot = await _db.collection('users').get(const GetOptions(source: Source.server));
      
      print('DEBUG: Found ${usersSnapshot.docs.length} users in database.');

      for (var doc in usersSnapshot.docs) {
        final targetUserId = doc.id;
        
        // STRICT CHECK: Do not send a notification to the person who just uploaded
        if (targetUserId.trim() == currentUserId.trim()) {
          print('DEBUG: User "$targetUserId" is the uploader. SKIPPING.');
          continue;
        }

        final userData = doc.data() as Map<String, dynamic>;
        final double? userLat = userData['latitude']?.toDouble();
        final double? userLng = userData['longitude']?.toDouble();

        if (userLat != null && userLng != null) {
          final distance = Geolocator.distanceBetween(postLat, postLng, userLat, userLng);
          
          print('DEBUG: Checking User "$targetUserId" at ($userLat, $userLng). Distance: ${distance.toStringAsFixed(0)}m');
          
          if (distance <= 3000) { // 3 km radius
            print('DEBUG: User "$targetUserId" is within 3km. WRITING notification to Firestore.');
            await addNotification(targetUserId, {
              'title': 'New Anadanam Nearby!',
              'body': '${postData['name']} is serving ${postData['foodDetails']} near your location.',
              'icon': '📍',
              'type': 'nearby_post',
              'postId': postData['id'] ?? '',
              'timestamp': FieldValue.serverTimestamp(),
            });
            print('DEBUG: Notification SUCCESS for "$targetUserId"');
          } else {
            print('DEBUG: User "$targetUserId" is too far (${distance.toStringAsFixed(0)}m). skipping.');
          }
        } else {
          print('DEBUG: User "$targetUserId" has NO location data in Firestore. skipping.');
        }
      }
      print('DEBUG: --- PROXIMITY NOTIFICATION END ---');
    } catch (e) {
      print('!!! NOTIFICATION ERROR !!!');
      print('Error detail: $e');
    }
  }
}
