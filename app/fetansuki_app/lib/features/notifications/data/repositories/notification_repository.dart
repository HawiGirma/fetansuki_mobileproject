import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fetansuki_app/features/notifications/domain/entities/app_notification.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationRepository(this._firestore, this._auth);

  Future<void> addNotification({
    required String title,
    required String description,
    required NotificationType type,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('notifications').doc();
    await docRef.set({
      'id': docRef.id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'timestamp': FieldValue.serverTimestamp(),
      'user_id': user.uid,
      'is_read': false,
    });
  }

  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: user.uid)
        .where('is_read', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'is_read': true});
    }

    await batch.commit();
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'is_read': true,
    });
  }

  Stream<List<AppNotification>> watchNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['timestamp'] is Timestamp) {
          data['timestamp'] = (data['timestamp'] as Timestamp).toDate().toIso8601String();
        }
        return AppNotification.fromJson({...data, 'id': doc.id});
      }).toList();
      
      // Sort in memory instead of using Firestore orderBy to avoid index requirement
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return notifications;
    });
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  return ref.watch(notificationRepositoryProvider).watchNotifications();
});
