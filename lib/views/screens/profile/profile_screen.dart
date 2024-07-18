import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:tadbirio/views/widgets/leading_button.dart';
import 'package:tadbirio/views/widgets/registration/text_feild.dart';

import '../../../bloc/profile/profile_bloc.dart';
import '../../../bloc/profile/profile_event.dart';
import '../../../bloc/profile/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        firestore: FirebaseFirestore.instance,
        imagePicker: ImagePicker(),
        storage: FirebaseStorage.instance,
      )..add(LoadUserData()),
      child: ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(10.0),
          child: LeadingButton(),
        ),
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_as_outlined),
            onPressed: () {
              final bloc = context.read<ProfileBloc>();
              bloc.add(
                SaveUserData(
                  _nameController.text,
                  _surnameController.text,
                  bloc.state.email,
                  bloc.state.imageUrl,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.hardEdge,
                  backgroundColor: Colors.teal,
                  content: const Text(
                    'Profile data saved successfully!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              _nameController.text = state.name;
              _surnameController.text = state.surname;
              return Column(
                children: [
                  const Gap(20),
                  Stack(
                    children: [
                      state.loading
                          ? const CircleAvatar(
                              radius: 60,
                              child: CircularProgressIndicator(),
                            )
                          : CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: state.imageUrl.isNotEmpty
                                  ? NetworkImage(state.imageUrl)
                                  : null,
                              child: state.imageUrl.isEmpty
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
                              builder: (BuildContext bottomSheetContext) {
                                return BlocProvider.value(
                                  value: BlocProvider.of<ProfileBloc>(context),
                                  child: Container(
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
                                              child: GestureDetector(
                                                onTap: () {
                                                  context
                                                      .read<ProfileBloc>()
                                                      .add(PickImage(
                                                          ImageSource.gallery));
                                                  Navigator.pop(
                                                      bottomSheetContext);
                                                },
                                                child: const Row(
                                                  children: [
                                                    Gap(10),
                                                    Icon(Icons.image_outlined),
                                                    Gap(10),
                                                    Text(
                                                      "Gallery",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  context
                                                      .read<ProfileBloc>()
                                                      .add(PickImage(
                                                          ImageSource.camera));
                                                  Navigator.pop(
                                                      bottomSheetContext);
                                                },
                                                child: const Row(
                                                  children: [
                                                    Gap(10),
                                                    Icon(Icons
                                                        .camera_alt_outlined),
                                                    Gap(10),
                                                    Text(
                                                      "Camera",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
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
                  const Gap(15),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Email: ",
                          style: TextStyle(
                            color: AdaptiveTheme.of(context).mode ==
                                    AdaptiveThemeMode.dark
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: state.email,
                          style: TextStyle(
                            color: AdaptiveTheme.of(context).mode ==
                                    AdaptiveThemeMode.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                  const Gap(20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFieldWidget(
                          icon: Icons.person,
                          controller: _nameController,
                          hintText: "Enter your name",
                          onChanged: (value) {
                            context.read<ProfileBloc>().add(UpdateName(value));
                          },
                        ),
                        const Gap(20),
                        TextFieldWidget(
                          icon: Icons.person_2_outlined,
                          controller: _surnameController,
                          hintText: "Enter your surname",
                          onChanged: (value) {
                            context
                                .read<ProfileBloc>()
                                .add(UpdateSurname(value));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
