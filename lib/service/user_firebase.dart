import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tadbirio/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> getUserById(String id) async {
    final DocumentSnapshot doc = await _firestore.collection('users').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      throw Exception('User not found or data is null');
    }
  }

  Future<void> removeEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to remove event: $e');
    }
  }
}
