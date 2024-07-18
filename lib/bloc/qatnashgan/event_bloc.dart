import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tadbirio/models/event_model.dart';
import '../../service/firebase_service.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final FirebaseService firebaseService;

  EventBloc({required this.firebaseService}) : super(EventInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<AddEvent>(_onAddEvent);
    on<ToggleFavoriteStatus>(_onToggleFavoriteStatus);
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventState> emit) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('events').get();
      final events = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EventModel(
          id: doc.id,
          title: data['title'] ?? '',
          day: (data['day'] as Timestamp).toDate(),
          beginTime: data['beginTime'] ?? '',
          endTime: data['endTime'] ?? '',
          locationName: data['locationName'] ?? '',
          image: data['image'] ?? '',
          latlang: data['latlang'],
          creatorId: data['creatorId'] ?? '',
          description: data['description'] ?? '',
          isFavorite: data['isFavorite'] ?? false,
        );
      }).toList();
      emit(EventLoaded(events: events));
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  void _onAddEvent(AddEvent event, Emitter<EventState> emit) async {
    try {
      firebaseService.addEvent(eventModel: event.eventModel);
      add(LoadEvents());
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onToggleFavoriteStatus(ToggleFavoriteStatus event, Emitter<EventState> emit) async {
    try {
      await firebaseService.updateFavoriteStatus(event.eventId, event.isFavorite);
      add(LoadEvents());
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }
}
