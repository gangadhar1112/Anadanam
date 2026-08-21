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
      'status': 'pending', // Default status for moderation
    });
  }

  // Stream active Anadanam
  Stream<QuerySnapshot> streamActiveAnadanam() {
    return anadanamCollection
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get user's Anadanam
  Stream<QuerySnapshot> streamUserAnadanam(String userId) {
    return anadanamCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update status (Admin)
  Future<void> updateAnadanamStatus(String id, String status) async {
    await anadanamCollection.doc(id).update({'status': status});
  }
}
