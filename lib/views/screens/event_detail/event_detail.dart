import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:tadbirio/bloc/qatnashgan/event_bloc.dart';
import 'package:tadbirio/models/event_model.dart';
import 'package:tadbirio/views/widgets/leading_button.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../../bloc/qatnashgan/event_event.dart';
import '../../../bloc/qatnashgan/event_state.dart';
import '../../../models/user_model.dart';
import '../../../service/user_firebase.dart';

class EventDetailPage extends StatefulWidget {
  final EventModel event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late YandexMapController mapController;

  Future<UserModel> fetchUserDetails() async {
    return await UserService().getUserById(widget.event.creatorId);
  }

  Future<void> _updateMapLocation(EventModel event) async {
    await mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: event.latlang.latitude,
            longitude: event.latlang.longitude,
          ),
          zoom: 14,
        ),
      ),
      animation:
          const MapAnimation(type: MapAnimationType.smooth, duration: .2),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEventExpired = DateTime.now().isAfter(widget.event.day);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: LeadingButton(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<EventBloc, EventState>(
              builder: (context, state) {
                bool isFavorite = widget.event.isFavorite;
                if (state is EventLoaded) {
                  final updatedEvent = state.events.firstWhere(
                    (e) => e.id == widget.event.id,
                    orElse: () => widget.event,
                  );
                  isFavorite = updatedEvent.isFavorite;
                }
                return CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.black,
                    ),
                    onPressed: () {
                      context.read<EventBloc>().add(
                          ToggleFavoriteStatus(widget.event.id, isFavorite));
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(30)),
              child: Image.network(
                widget.event.image,
                height: 270,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Text(
                    widget.event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AdaptiveTheme.of(context).mode ==
                              AdaptiveThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.blue[100],
                            ),
                            child: const Icon(
                              CupertinoIcons.calendar,
                              color: Colors.black,
                            ),
                          ),
                          const Gap(10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('dd MMMM, yyyy')
                                    .format(widget.event.day),
                                style: TextStyle(
                                  color: AdaptiveTheme.of(context).mode ==
                                          AdaptiveThemeMode.dark
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${widget.event.beginTime} - ${widget.event.endTime}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(10),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.blue[100],
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.locationName.contains(",")
                                ? widget.event.locationName.split(",")[0]
                                : widget.event.locationName,
                            maxLines: 2,
                            style: TextStyle(
                              color: AdaptiveTheme.of(context).mode ==
                                      AdaptiveThemeMode.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          widget.event.locationName.contains(",")
                              ? Text(
                                  widget.event.locationName.split(",")[1],
                                  maxLines: 2,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                )
                              : const Text(""),
                        ],
                      ),
                    ],
                  ),
                  const Gap(10),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.blue[100],
                        ),
                        child: const Icon(
                          Icons.people,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '243 kishi bormoqda',
                            style: TextStyle(
                              color: AdaptiveTheme.of(context).mode ==
                                      AdaptiveThemeMode.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "siz_ham_royxatdan_oting".tr(),
                            style: TextStyle(
                                color: AdaptiveTheme.of(context).mode ==
                                        AdaptiveThemeMode.dark
                                    ? Colors.white
                                    : Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(20),
                  FutureBuilder<UserModel>(
                    future: fetchUserDetails(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading user data'));
                      }
                      final user = snapshot.data!;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: user.imageUrl.isEmpty
                              ? const AssetImage("assets/icons/person_user.png")
                              : NetworkImage(user.imageUrl),
                        ),
                        title: Text(
                          "${user.name} ${user.surname}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Tadbir tashkilotchisi'.tr()),
                      );
                    },
                  ),
                  const Gap(20),
                  Text(
                    "tadbir_haqida_ma'lumot".tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(10),
                  Text(widget.event.description),
                  const Gap(20),
                  Text(
                    'Manzil'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(10),
                  Text(widget.event.locationName),
                  const Gap(10),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: YandexMap(
                    rotateGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    onMapCreated: (controller) {
                      mapController = controller;
                      _updateMapLocation(widget.event);
                    },
                    mapObjects: [
                      PlacemarkMapObject(
                        mapId: const MapObjectId("location"),
                        point: Point(
                            latitude: widget.event.latlang.latitude,
                            longitude: widget.event.latlang.longitude),
                        icon: PlacemarkIcon.single(
                          PlacemarkIconStyle(
                            scale: .1,
                            image: BitmapDescriptor.fromAssetImage(
                                "assets/icons/marker.png"),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: ElevatedButton(
                onPressed: isEventExpired
                    ? null
                    : () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            int selectedSeats = 1;
                            int selectedPayment = 1;
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    height: MediaQuery.of(context).size.height *
                                        0.9,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              icon:
                                                  const Icon(Icons.arrow_back),
                                            ),
                                            Text(
                                              "royxatdan_otish".tr(),
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: AdaptiveTheme.of(context)
                                                            .mode ==
                                                        AdaptiveThemeMode.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              icon: const Icon(Icons.close),
                                            ),
                                          ],
                                        ),
                                        const Gap(25),
                                        Text(
                                          "joylar_sonini_tanlang".tr(),
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: AdaptiveTheme.of(context)
                                                        .mode ==
                                                    AdaptiveThemeMode.dark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const Gap(10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (selectedSeats > 1) {
                                                    selectedSeats--;
                                                  }
                                                });
                                              },
                                              child: const Card(
                                                shape: CircleBorder(),
                                                child: CircleAvatar(
                                                  child: Icon(
                                                    Icons.remove,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Gap(10),
                                            Text(
                                              "$selectedSeats",
                                              style: TextStyle(
                                                fontSize: 25,
                                                color: AdaptiveTheme.of(context)
                                                            .mode ==
                                                        AdaptiveThemeMode.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                            const Gap(10),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedSeats++;
                                                });
                                              },
                                              child: const Card(
                                                shape: CircleBorder(),
                                                child: CircleAvatar(
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Gap(25),
                                        Text(
                                          "tolov_turini_tanlang".tr(),
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: AdaptiveTheme.of(context)
                                                        .mode ==
                                                    AdaptiveThemeMode.dark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const Gap(10),
                                        ListTile(
                                          leading: Image.asset(
                                              'assets/images/clic.png',
                                              width: 30),
                                          title: const Text("Click"),
                                          trailing: Radio(
                                            value: 1,
                                            groupValue: selectedPayment,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedPayment = value as int;
                                              });
                                            },
                                          ),
                                        ),
                                        ListTile(
                                          leading: Image.asset(
                                              'assets/images/payme.png',
                                              width: 30),
                                          title: const Text("Payme"),
                                          trailing: Radio(
                                            value: 2,
                                            groupValue: selectedPayment,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedPayment = value as int;
                                              });
                                            },
                                          ),
                                        ),
                                        const Gap(25),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              bool isRegistered =
                                                  await UserService()
                                                      .checkRegistration(
                                                          widget.event.id,
                                                          FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid);
                                              if (isRegistered) {
                                                Navigator.pop(context);
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          "Siz allaqachon ro'yxatdan o'tgansiz"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text('OK'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else {
                                                await UserService()
                                                    .registerEvent(
                                                        widget.event.id);
                                                Navigator.pop(context);
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Image.asset(
                                                              "assets/icons/check.gif"),
                                                          const Text(
                                                            "Muvaffaqiyatli ro'yxatdan o'tdingiz",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text('OK'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                            ),
                                            child: Text(
                                              "Keyingi".tr(),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEventExpired
                      ? Colors.grey
                      : Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                child: Text(
                  isEventExpired
                      ? 'tadbir_yakunlandi'.tr()
                      : "royxatdan_otish".tr(),
                  style: TextStyle(
                      fontSize: 16,
                      color: isEventExpired ? Colors.grey[700] : Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
