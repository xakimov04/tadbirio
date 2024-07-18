import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tadbirio/bloc/qatnashgan/event_bloc.dart';
import 'package:tadbirio/models/event_model.dart';
import 'package:tadbirio/views/widgets/event_card.dart';

import '../../../bloc/qatnashgan/event_event.dart';
import '../../../bloc/qatnashgan/event_state.dart';
import '../event_detail/event_detail.dart';

class NearbyEventsScreen extends StatefulWidget {
  const NearbyEventsScreen({super.key});

  @override
  State<NearbyEventsScreen> createState() => _NearbyEventsScreenState();
}

class _NearbyEventsScreenState extends State<NearbyEventsScreen> {
  Position? _currentPosition;
  late EventBloc _eventBloc;

  @override
  void initState() {
    super.initState();
    _eventBloc = BlocProvider.of<EventBloc>(context);
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      _getCurrentLocation();
    } else if (status.isDenied) {
      final result = await Permission.location.request();
      if (result.isGranted) {
        _getCurrentLocation();
      } else if (result.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
      }
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      _eventBloc.add(LoadEvents());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Denied'),
        content: const Text(
            'Please enable location permissions in your settings to use this feature.'),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventBloc = context.watch<EventBloc>();

    return Scaffold(
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventLoaded) {
            if (_currentPosition == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final nearbyEvents = state.events.where((event) {
              final distance = Geolocator.distanceBetween(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                event.latlang.latitude,
                event.latlang.longitude,
              );
              return distance <= 5000;
            }).toList();

            if (nearbyEvents.isEmpty) {
              return const Center(child: Text('No events within 5 km'));
            }

            return ListView.builder(
              itemCount: nearbyEvents.length,
              itemBuilder: (context, index) {
                final event = nearbyEvents[index];
                return EventCard(
                  event: event,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailPage(event: event),
                      ),
                    ).then((_) {
                      eventBloc.add(LoadEvents());
                    });
                  },
                  onDelete: () {},
                );
              },
            );
          } else if (state is EventError) {
            return Center(
                child: Text('Error loading events: ${state.message}'));
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }
}
