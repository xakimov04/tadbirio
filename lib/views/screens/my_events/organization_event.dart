import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadbirio/views/widgets/event_card.dart';

import '../../../bloc/qatnashgan/event_bloc.dart';
import '../../../bloc/qatnashgan/event_event.dart';
import '../../../bloc/qatnashgan/event_state.dart';
import '../../../service/user_firebase.dart';
import '../event_detail/event_detail.dart';

class EventPage extends StatelessWidget {
  const EventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoaded) {
            final events = state.events
                .where((event) =>
                    event.creatorId == FirebaseAuth.instance.currentUser!.uid)
                .toList();

            if (events.isEmpty) {
              return const Center(
                child: Text("Ma'lumot yo'q"),
              );
            }

            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return EventCard(
                  all: true,
                  event: event,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(event: event),
                      ),
                    ).then((_) {
                      BlocProvider.of<EventBloc>(context).add(LoadEvents());
                    });
                  },
                  onDelete: () async {
                    await _deleteEvent(context, event.id);
                  },
                );
              },
            );
          } else if (state is EventError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> _deleteEvent(BuildContext context, String eventId) async {
    try {
      await UserService().removeEvent(eventId);
      BlocProvider.of<EventBloc>(context).add(LoadEvents());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: $e')),
      );
    }
  }
}
