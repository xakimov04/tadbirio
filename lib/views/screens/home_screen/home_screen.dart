import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:tadbirio/bloc/qatnashgan/event_bloc.dart';
import 'package:tadbirio/bloc/qatnashgan/event_state.dart';
import 'package:tadbirio/views/screens/favorite/favorite_screen.dart';
import 'package:tadbirio/views/screens/notification/notification_screen.dart';
import 'package:tadbirio/views/widgets/carousel_container.dart';
import 'package:tadbirio/views/widgets/custom_drawer.dart';
import '../../../bloc/qatnashgan/event_event.dart';
import '../../widgets/event_card.dart';
import '../event_detail/event_detail.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventBloc = BlocProvider.of<EventBloc>(context, listen: true);
    eventBloc.add(LoadEvents());

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text(
          "Bosh sahifa",
          style: TextStyle(
            color: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.favorite_sharp,
              color: Colors.red,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            ),
            icon: Image.asset(
              "assets/icons/noti.png",
              width: 30,
              height: 30,
              color: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoaded) {
            final now = DateTime.now();
            final nextWeek = now.add(const Duration(days: 7));
            final upcomingEvents = state.events
                .where((event) =>
                    event.day.isAfter(now.subtract(const Duration(days: 1))) &&
                    event.day.isBefore(nextWeek))
                .toList();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  forceMaterialTransparency: true,
                  pinned: true,
                  leading: const SizedBox(),
                  toolbarHeight: 70,
                  flexibleSpace: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tadbirlarni izlash...',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Image.asset(
                            "assets/icons/search.png",
                            width: 10,
                            height: 10,
                          ),
                        ),
                        filled: true,
                        suffixIcon: GestureDetector(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              "assets/icons/suffix.png",
                              height: 10,
                            ),
                          ),
                        ),
                        fillColor: AdaptiveTheme.of(context).mode ==
                                AdaptiveThemeMode.dark
                            ? Colors.grey[700]
                            : Colors.grey[300],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Yaqin 7 kun ichida",
                          style: TextStyle(
                            color: AdaptiveTheme.of(context).mode ==
                                    AdaptiveThemeMode.dark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 180,
                        child: CarouselSlider(
                          items: upcomingEvents.map((event) {
                            return Builder(
                              builder: (BuildContext context) {
                                return CarouselContainer(
                                  event: event,
                                );
                              },
                            );
                          }).toList(),
                          options: CarouselOptions(
                            height: 200,
                            enlargeCenterPage: false,
                            autoPlay: false,
                            aspectRatio: 16 / 5,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enableInfiniteScroll: true,
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 800),
                            viewportFraction: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Barcha tadbirlar",
                      style: TextStyle(
                        color: AdaptiveTheme.of(context).mode ==
                                AdaptiveThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = state.events[index];
                      return EventCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailPage(event: event),
                            ),
                          ).then((_) {
                            eventBloc.add(LoadEvents());
                          });
                        },
                        event: event,
                      );
                    },
                    childCount: state.events.length,
                  ),
                ),
              ],
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
}
