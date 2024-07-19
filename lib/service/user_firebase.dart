import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getCurrentUserId() async {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  Future<UserModel> getUserById(String id) async {
    final DocumentSnapshot doc =
        await _firestore.collection('users').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      throw Exception('User not found or data is null');
    }
  }

  Future<void> registerEvent(String eventId) async {
    String uid = await getCurrentUserId();
    await _firestore.collection('users').doc(uid).update({
      'registeredEvents': FieldValue.arrayUnion([eventId]),
    });
  }

  Future<List<EventModel>> getRegisteredEvents() async {
    String uid = await getCurrentUserId();
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(uid).get();
    List<String> eventIds =
        List<String>.from(userDoc['registeredEvents'] ?? []);
    List<EventModel> events = [];
    for (String eventId in eventIds) {
      DocumentSnapshot eventDoc =
          await _firestore.collection('events').doc(eventId).get();
      events.add(EventModel.fromDocument(eventDoc));
    }
    return events;
  }

  Future<void> removeEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to remove event: $e');
    }
  }

  Future<bool> checkRegistration(String userId, String eventId) async {
    final DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('registrations')
        .doc(eventId)
        .get();
    return doc.exists;
  }

  // Future<void> unregisterEvent(String userId, String eventId) async {
  //   try {
  //     await _firestore
  //         .collection('users')
  //         .doc(userId)
  //         .collection('registrations')
  //         .doc(eventId)
  //         .delete();
  //   } catch (e) {
  //     throw Exception('Failed to remove registration: $e');
  //   }
  // }
  Future<void> unregisterEvent(String userId, String eventId) async {
    final userRef = _firestore.collection('users').doc(userId);
    try {
      // Remove eventId from the user's registeredEvents array
      await userRef.update({
        'registeredEvents': FieldValue.arrayRemove([eventId])
      });
    } catch (e) {
      throw Exception('Failed to unregister event: $e');
    }
  }
}
