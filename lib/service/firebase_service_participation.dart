import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tadbirio/models/event_model.dart';

class FirebaseServiceParticipation {
  final _firestore = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('qatnashgan');

  Stream<QuerySnapshot> getEvent() async* {
    yield* _firestore.snapshots();
  }

  void addEvent({required EventModel eventModel}) {
    _firestore.add({
      'title': eventModel.title,
      'day': eventModel.day,
      'beginTime': eventModel.beginTime,
      'endTime': eventModel.endTime,
      'locationName': eventModel.locationName,
      'image': eventModel.image,
      'latlang': eventModel.latlang,
      'creatorId': eventModel.creatorId,
      'description': eventModel.description,
      'isFavorite': eventModel.isFavorite,
    });
  }
}
