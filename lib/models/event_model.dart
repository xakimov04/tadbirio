import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  bool isFavorite;
  String title;
  DateTime day;
  String beginTime;
  String endTime;
  String locationName;
  String image;
  GeoPoint latlang;
  String creatorId;
  String description;
  String id;

  EventModel({
    required this.isFavorite,
    required this.title,
    required this.day,
    required this.beginTime,
    required this.endTime,
    required this.locationName,
    required this.image,
    required this.latlang,
    required this.creatorId,
    required this.description,
    required this.id,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      title: map['title'],
      day: (map['day'] as Timestamp).toDate(),
      beginTime: map['beginTime'],
      endTime: map['endTime'],
      description: map['description'],
      image: map['image'],
      latlang: map['latlang'],
      creatorId: map['creatorId'],
      isFavorite: map['isFavorite'],
      locationName: map['locationName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isFavorite': isFavorite,
      'title': title,
      'day': day,
      'beginTime': beginTime,
      'endTime': endTime,
      'locationName': locationName,
      'image': image,
      'latlang': latlang,
      'creatorId': creatorId,
      'description': description,
    };
  }
}
