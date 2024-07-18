import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:tadbirio/views/screens/my_events/add_event.dart';
import 'package:tadbirio/views/screens/my_events/organization_event.dart';
import 'package:tadbirio/views/screens/my_events/yaqin.dart';
import 'package:tadbirio/views/screens/notification/notification_screen.dart';
import 'package:tadbirio/views/widgets/leading_button.dart';

class MyEvents extends StatefulWidget {
  const MyEvents({super.key});

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: LeadingButton(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                RawDialogRoute(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return const NotificationScreen();
                  },
                ),
              );
            },
            icon: Image.asset(
              "assets/icons/noti.png",
              width: 30,
              height: 30,
              fit: BoxFit.cover,
              color: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ],
        centerTitle: true,
        title: Text(
          "Mening tadbirlarim",
          style: TextStyle(
            color: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark
                ? Colors.white
                : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          dividerColor: Colors.transparent,
          indicatorColor: Colors.orange,
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.orange,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: "Tashkil qilganlarim"),
            Tab(text: "Yaqinda"),
            Tab(text: "Ishtirok etganlarim"),
            Tab(text: "Bekor qilganlarim"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEventPage()),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.orange,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          EventPage(),
          NearbyEventsScreen(),
          Center(child: Text("Content for Tab 3")),
          Center(child: Text("Content for Tab 4")),
        ],
      ),
    );
  }
}
