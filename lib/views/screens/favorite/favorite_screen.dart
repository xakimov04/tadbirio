import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadbirio/bloc/qatnashgan/event_bloc.dart';
import 'package:tadbirio/models/event_model.dart';
import 'package:tadbirio/views/widgets/event_card.dart';
import 'package:tadbirio/views/widgets/leading_button.dart';

import '../../../bloc/qatnashgan/event_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: LeadingButton(),
        ),
        title: Text(
          'Sevimli'.tr(),
          style: TextStyle(
            color: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark
                ? Colors.white
                : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventLoaded) {
            final favoriteEvents =
                state.events.where((event) => event.isFavorite).toList();

            if (favoriteEvents.isEmpty) {
              return const Center(child: Text('No favorite events found'));
            }

            return ListView.builder(
              itemCount: favoriteEvents.length,
              itemBuilder: (context, index) {
                final event = favoriteEvents[index];
                return EventCard(
                  event: event,
                  onTap: () {},
                  onDelete: () {},
                );
              },
            );
          } else {
            return const Center(child: Text('Error loading events'));
          }
        },
      ),
    );
  }
}
