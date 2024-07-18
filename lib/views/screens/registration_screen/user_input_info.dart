import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tadbirio/views/screens/home_screen/home_screen.dart';
import 'package:tadbirio/views/widgets/registration/submit_button.dart';
import 'package:tadbirio/views/widgets/registration/text_feild.dart';

class UserInputInfo extends StatefulWidget {
  final String email;
  final String uid;
  const UserInputInfo({super.key, required this.email, required this.uid});

  @override
  State<UserInputInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInputInfo>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveToSharedPreferences(
      String name, String surname, String imageUrl, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('surname', surname);
    await prefs.setString('image_url', imageUrl);
    await prefs.setString('email', email);
  }

  Future<void> _submitData() async {
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${DateTime.now().toIso8601String()}.jpg');
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      final name = _nameController.text;
      final surname = _surnameController.text;
      final email = widget.email;

      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
        'name': name,
        'surname': surname,
        'image_url': imageUrl ?? '',
        'email': email,
      });

      await _saveToSharedPreferences(name, surname, imageUrl ?? '', email);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
        (route) => false,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Information',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Gap(50),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : null,
                      child: _selectedImage == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.black,
                            )
                          : null,
                    ),
                    Positioned(
                      right: 5,
                      bottom: 5,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                width: double.infinity,
                                height: 100,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              IconButton(
                                                onPressed: () => _pickImage(
                                                    ImageSource.gallery),
                                                icon: const Icon(
                                                    Icons.image_outlined),
                                              ),
                                              const Text(
                                                "Gallery",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              IconButton(
                                                onPressed: () => _pickImage(
                                                    ImageSource.camera),
                                                icon: const Icon(
                                                    Icons.camera_alt_outlined),
                                              ),
                                              const Text(
                                                "Camera",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(50),
                TextFieldWidget(
                  controller: _nameController,
                  hintText: "Username",
                  icon: Icons.person,
                ),
                const Gap(20),
                TextFieldWidget(
                  controller: _surnameController,
                  hintText: "Surname (not mandatory)",
                  icon: Icons.person_outline,
                ),
                const Spacer(),
                SlideTransition(
                  position: _slideAnimation,
                  child: SubmitButton(
                    text: "Submit",
                    onTap: _submitData,
                  ),
                ),
                const Gap(20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
