import 'package:tadbirio/models/event_model.dart';

abstract class EventEvent {}

class LoadEvents extends EventEvent {}

class AddEvent extends EventEvent {
  final EventModel eventModel;

  AddEvent(this.eventModel);
}

class ToggleFavoriteStatus extends EventEvent {
  final String eventId;
  final bool isFavorite;

  ToggleFavoriteStatus(this.eventId, this.isFavorite);
}
