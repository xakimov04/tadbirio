import 'package:tadbirio/models/event_model.dart';

abstract class EventState {}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  final List<EventModel> events;

  EventLoaded({required this.events});
}

class EventError extends EventState {
  final String message;

  EventError({required this.message});
}
