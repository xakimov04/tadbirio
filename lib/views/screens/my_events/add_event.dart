import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tadbirio/views/screens/yandex/yandex_screen.dart';
import 'package:tadbirio/views/widgets/leading_button.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  late YandexMapController mapController;

  String? _title,
      _description,
      _startTime,
      _stopTime,
      _imageUrl,
      _videoUrl,
      _locationName;
  DateTime? _eventDate;
  GeoPoint _eventLocation = const GeoPoint(0, 0);
  File? _pickedImage;
  bool _isUploading = false; // Added loading state

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is denied.')),
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _eventLocation = GeoPoint(position.latitude, position.longitude);
        _updateMapLocation();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final event = {
        'title': _title,
        'description': _description,
        'beginTime': _startTime,
        'endTime': _stopTime,
        'day': Timestamp.fromDate(_eventDate!),
        'image': _imageUrl,
        'videoUrl': _videoUrl,
        'latlang': _eventLocation,
        'creatorId': FirebaseAuth.instance.currentUser!.uid,
        'isFavorite': false,
        'locationName': _locationName,
      };

      await FirebaseFirestore.instance.collection('events').add(event);
      Navigator.pop(context, true);
    }
  }

  Future<void> _pickMedia(bool isImage) async {
    setState(() {
      _isUploading = true; // Set loading state to true
    });

    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: isImage ? 80 : null,
    );

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String folder = isImage ? 'images' : 'videos';
      String url = await _uploadFile(file, folder);

      setState(() {
        if (isImage) {
          _imageUrl = url;
          _pickedImage = file;
        } else {
          _videoUrl = url;
        }
        _isUploading = false; // Set loading state to false
      });
    } else {
      setState(() {
        _isUploading = false; // Set loading state to false if no file picked
      });
    }
  }

  Future<String> _uploadFile(File file, String folder) async {
    String fileName = file.path.split('/').last;
    Reference storageReference =
        FirebaseStorage.instance.ref().child('$folder/$fileName');
    UploadTask uploadTask = storageReference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const YandexScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _eventLocation = GeoPoint(result['latitude'], result['longitude']);
        _locationName = result['locationName'];
        _updateMapLocation();
      });
    }
  }

  Future<void> _updateMapLocation() async {
    await mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: Point(
                latitude: _eventLocation.latitude,
                longitude: _eventLocation.longitude),
            zoom: 14),
      ),
      animation:
          const MapAnimation(type: MapAnimationType.smooth, duration: .2),
    );
  }

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
          "Tadbir Qo'shish".tr(),
          style: TextStyle(
            color: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('nomi'.tr(), (value) => _title = value),
              const Gap(10),
              _buildDatePickerField('kuni'.tr(), _eventDate,
                  (date) => setState(() => _eventDate = date)),
              const Gap(10),
              _buildTimePickerField('Boshlanish vaqti'.tr(), _startTime,
                  (time) => setState(() => _startTime = time)),
              const Gap(10),
              _buildTimePickerField('Tugash vaqti'.tr(), _stopTime,
                  (time) => setState(() => _stopTime = time)),
              const Gap(10),
              _buildTextField("tadbir_haqida_ma'lumot".tr(),
                  (value) => _description = value,
                  maxLines: 3),
              const Gap(10),
              Row(
                children: [
                  _buildMediaButton(
                    Icons.photo_camera,
                    'Rasm'.tr(),
                    () => _pickMedia(true),
                    _pickedImage,
                    isUploading: _isUploading, 
                  ),
                ],
              ),
              const Gap(10),
              Text('manzilni_belgilash'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Gap(10),
              Stack(
                children: [
                  Container(
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
                          _updateMapLocation();
                        },
                        mapObjects: [
                          PlacemarkMapObject(
                            mapId: const MapObjectId("location"),
                            point: Point(
                                latitude: _eventLocation.latitude,
                                longitude: _eventLocation.longitude),
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
                  GestureDetector(
                    onTap: _pickLocation,
                    child: Container(
                      height: 200,
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
              const Gap(20),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitForm,
                    child: Text("qoshish".tr()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, FormFieldSetter<String> onSaved,
      {int maxLines = 1}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onSaved: onSaved,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Iltimos, $label kiriting';
        }
        return null;
      },
    );
  }

  Widget _buildDatePickerField(String label, DateTime? selectedDate,
      ValueChanged<DateTime?> onDateSelected) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: selectedDate == null
            ? ''
            : selectedDate.toLocal().toString().split(' ')[0],
      ),
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        DateTime? date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        onDateSelected(date);
      },
    );
  }

  Widget _buildTimePickerField(String label, String? selectedTime,
      ValueChanged<String?> onTimeSelected) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        suffixIcon: const Icon(Icons.access_time),
      ),
      readOnly: true,
      controller: TextEditingController(text: selectedTime ?? ''),
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        TimeOfDay? time = await showTimePicker(
            context: context, initialTime: TimeOfDay.now());
        if (time != null) {
          onTimeSelected(time.format(context));
        }
      },
    );
  }

  Widget _buildMediaButton(
      IconData icon, String label, VoidCallback onPressed, File? pickedImage,
      {bool isUploading = false}) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: isUploading
            ? const CircularProgressIndicator()
            : pickedImage != null
                ? Image.file(
                    pickedImage,
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  )
                : Icon(icon),
        label: Text(label),
        onPressed: isUploading ? null : onPressed,
      ),
    );
  }
}
