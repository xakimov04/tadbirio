import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class YandexScreen extends StatefulWidget {
  const YandexScreen({super.key});

  @override
  State<YandexScreen> createState() => _YandexScreenState();
}

class _YandexScreenState extends State<YandexScreen> {
  late YandexMapController mapController;
  LocationPermission? permission;
  Point? myCurrentLocation;
  List<MapObject> mapObjects = [];
  List<MapObject> polylines = [];
  double searchHeight = 250;
  List<SuggestItem> _suggestionList = [];
  Point _initialLocation = const Point(latitude: 41.02155, longitude: 69.0112);
  final YandexSearch yandexSearch = YandexSearch();
  final TextEditingController _searchTextController = TextEditingController();

  final ValueNotifier<bool> _isBottomSheetVisible = ValueNotifier(false);
  String _bottomSheetTitle = "";
  String _bottomSheetAddress = "";
  Point? _bottomSheetLocation;
  late String _locationName;

  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _initLocation();

    _loadUserEmail();
  }

  _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail') ?? 'No Email';
    });
  }

  Future<void> _initLocation() async {
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _initialLocation = Point(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    });
    _moveCameraTo(_initialLocation);
  }

  Future<void> _moveCameraTo(Point target) async {
    await mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 17),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.smooth,
        duration: .2,
      ),
    );
  }

  void _toggleBottomSheet(Point destination, String title, String address) {
    setState(() {
      _bottomSheetTitle = title;
      _bottomSheetAddress = address;
      _bottomSheetLocation = destination;
      _isBottomSheetVisible.value = !_isBottomSheetVisible.value;
    });
  }

  Future<void> _showBottomSheet(Point destination,
      [String? title, String? address]) async {
    String displayAddress = address ?? "Unknown location";
    String displayTitle = title ?? "";

    if (address == null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          destination.latitude,
          destination.longitude,
        );
        if (placemarks.isNotEmpty) {
          displayAddress =
              "${placemarks.first.subLocality}, ${placemarks.first.street}";
          setState(() {
            _locationName = displayAddress;
          });
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Gap(30),
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: Colors.red,
                    ),
                    Text(
                      "Location",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Gap(10),
                Text(
                  displayAddress,
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const Gap(10),
                Text(
                  "${destination.latitude}, ${destination.longitude}",
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    _addPlacemark(destination, displayTitle, displayAddress);
                    _onConfirm();
                    Navigator.pop(context, {
                      'latitude': myCurrentLocation!.latitude,
                      'longitude': myCurrentLocation!.longitude,
                      'locationName': _locationName,
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.teal,
                    ),
                    child: const Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onConfirm() {
    if (myCurrentLocation != null) {
      Navigator.pop(context, {
        'latitude': myCurrentLocation!.latitude,
        'longitude': myCurrentLocation!.longitude,
        'locationName': _locationName,
      });
    }
  }

  Future<SuggestSessionResult> _suggest() async {
    final resultWithSession = await YandexSuggest.getSuggestions(
      text: _searchTextController.text,
      boundingBox: const BoundingBox(
        northEast: Point(latitude: 56.0421, longitude: 38.0284),
        southWest: Point(latitude: 55.5143, longitude: 37.24841),
      ),
      suggestOptions: const SuggestOptions(
        suggestType: SuggestType.geo,
        suggestWords: true,
        userPosition: Point(latitude: 56.0321, longitude: 38),
      ),
    );

    return await resultWithSession.$2;
  }

  void _addPlacemark(Point point, String title, String address) {
    final placemark = PlacemarkMapObject(
      mapId: MapObjectId(title),
      onTap: (mapObject, point) {
        _toggleBottomSheet(point, title, address);
      },
      point: point,
      opacity: 1,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          scale: .15,
          image: BitmapDescriptor.fromAssetImage("assets/icons/marker.png"),
        ),
      ),
    );
    setState(() {
      mapObjects.add(placemark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.teal,
        onPressed: () {
          _moveCameraTo(_initialLocation);
        },
        child: const Icon(CupertinoIcons.location_fill, color: Colors.white),
      ),
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: (controller) {
              mapController = controller;
            },
            onMapLongTap: (point) {
              setState(() {
                myCurrentLocation = point;
              });
              _moveCameraTo(point).then((_) => _showBottomSheet(point));
            },
            mapObjects: [
              PlacemarkMapObject(
                mapId: const MapObjectId("My location"),
                point: _initialLocation,
                opacity: 1,
                icon: PlacemarkIcon.single(
                  PlacemarkIconStyle(
                    scale: .1,
                    image: BitmapDescriptor.fromAssetImage(
                        "assets/icons/marker.png"),
                  ),
                ),
              ),
              ...mapObjects,
              ...polylines,
            ],
          ),
          Positioned(
            top: 70,
            left: 10,
            right: 10,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _searchTextController.text.isNotEmpty ? searchHeight : 0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: ListView.builder(
                itemCount: _suggestionList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      setState(() {
                        searchHeight = 0;
                        myCurrentLocation = _suggestionList[index].center;
                        _showBottomSheet(myCurrentLocation!);
                      });

                      mapController.moveCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: myCurrentLocation!,
                            zoom: 17,
                          ),
                        ),
                        animation: const MapAnimation(
                          type: MapAnimationType.smooth,
                          duration: 1.5,
                        ),
                      );
                    },
                    title: Text(
                      _suggestionList[index].title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      _suggestionList[index].subtitle ?? "",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          if (polylines.isNotEmpty)
            Positioned(
              top: 100,
              left: 10,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    polylines = [];
                  });
                },
                child: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 25,
                  child: Icon(
                    Icons.clear,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: ValueListenableBuilder(
                valueListenable: _isBottomSheetVisible,
                builder: (context, isVisible, child) {
                  return Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          onTap: () {
                            _isBottomSheetVisible.value = false;
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.location_on_rounded,
                                color: Colors.red),
                            hintText: "Search for a place and address",
                            hintStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.green),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          controller: _searchTextController,
                          onChanged: (value) async {
                            final res = await _suggest();
                            if (res.items != null) {
                              setState(() {
                                searchHeight = 250;
                                _suggestionList = res.items!.toSet().toList();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ],
      ),
    );
  }
}
