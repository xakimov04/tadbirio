import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:tadbirio/models/event_model.dart';

import '../../bloc/qatnashgan/event_bloc.dart';
import '../../bloc/qatnashgan/event_event.dart';
import '../../bloc/qatnashgan/event_state.dart';
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onDelete,
    this.all = false,
  });

  final bool all;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMMM, yyyy').format(event.day);
    final formattedTime = DateFormat('HH:mm').format(event.day);

    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        bool isFavorite = event.isFavorite;
        if (state is EventLoaded) {
          isFavorite = state.events.firstWhere((e) => e.id == event.id).isFavorite;
        }

        return GestureDetector(
          onTap: onTap,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Container(
              width: double.infinity,
              height: 100,
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      event.image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        Text(
                          "$formattedTime $formattedDate",
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.locationName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      if (all)
                        Expanded(
                          child: PopupMenuButton<String>(
                            icon: const Icon(CupertinoIcons.ellipsis_vertical),
                            onSelected: (String value) {
                              if (value == 'delete') {
                                onDelete!();
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text("O'chirish"),
                                ),
                              ];
                            },
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                      const Gap(10),
                      Expanded(
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: () {
                            context.read<EventBloc>().add(
                              ToggleFavoriteStatus(event.id, isFavorite),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

