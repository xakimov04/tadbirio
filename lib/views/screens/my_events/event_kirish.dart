import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tadbirio/models/event_model.dart';
import '../../../service/user_firebase.dart';

class RegisteredEventsPage extends StatefulWidget {
  const RegisteredEventsPage({super.key});

  @override
  State<RegisteredEventsPage> createState() => _RegisteredEventsPageState();
}

class _RegisteredEventsPageState extends State<RegisteredEventsPage> {
  late Future<List<EventModel>> _registeredEventsFuture;

  @override
  void initState() {
    super.initState();
    _loadRegisteredEvents();
  }

  void _loadRegisteredEvents() {
    setState(() {
      _registeredEventsFuture = UserService().getRegisteredEvents();
    });
  }

  Future<void> _unregisterEvent(BuildContext context, String eventId) async {
    final userId = FirebaseAuth
        .instance.currentUser!.uid; // replace with actual current user ID logic
    try {
      await UserService().unregisterEvent(userId, eventId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ro\'yxatdan o\'tish bekor qilindi'.tr())),
      );
      // Refresh the list of registered events
      _loadRegisteredEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing registration: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<EventModel>>(
        future: _registeredEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading registered events'));
          }
          final events = snapshot.data!;
          if (events.isEmpty) {
            return const Center(
              child: Text("Ro'yxatdan o'tgan tadbirlar yo'q"),
            );
          }
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: InkWell(
                    onTap: () {
                      // Handle event tap if needed
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  event.image,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await _unregisterEvent(context, event.id);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            event.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.blue),
                              const SizedBox(width: 5),
                              Text(
                                DateFormat('dd MMMM, yyyy').format(event.day),
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.red),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  event.locationName,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
