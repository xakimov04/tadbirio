import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseFirestore firestore;
  final ImagePicker imagePicker;
  final FirebaseStorage storage;

  ProfileBloc({
    required this.firestore,
    required this.imagePicker,
    required this.storage,
  }) : super(ProfileState(name: '', surname: '', email: '', imageUrl: '')) {
    on<LoadUserData>(_onLoadUserData);
    on<SaveUserData>(_onSaveUserData);
    on<PickImage>(_onPickImage);
    on<UpdateName>(_onUpdateName);
    on<UpdateSurname>(_onUpdateSurname);
  }

  Future<void> _onLoadUserData(
      LoadUserData event, Emitter<ProfileState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? 'No name';
    final email = prefs.getString('email') ?? 'No email';
    final imageUrl = prefs.getString('image_url') ?? '';
    final surname = prefs.getString('surname') ?? '';

    emit(state.copyWith(
      name: name,
      surname: surname,
      email: email,
      imageUrl: imageUrl,
    ));
  }

  Future<void> _onSaveUserData(
      SaveUserData event, Emitter<ProfileState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString('name', event.name),
      prefs.setString('surname', event.surname),
      prefs.setString('email', event.email),
      prefs.setString('image_url', event.imageUrl),
    ]);

    final userDoc = firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    await userDoc.set({
      'name': event.name,
      'surname': event.surname,
      'email': event.email,
      'image_url': event.imageUrl,
    });

    emit(state.copyWith(
      name: event.name,
      surname: event.surname,
      email: event.email,
      imageUrl: event.imageUrl,
    ));
  }

  Future<void> _onPickImage(PickImage event, Emitter<ProfileState> emit) async {
    final pickedFile = await imagePicker.pickImage(source: event.source);
    emit(state.copyWith(loading: true));

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final imageUrl = await _uploadImageToStorage(file);
      emit(state.copyWith(imageUrl: imageUrl, loading: false));
    } else {
      emit(state.copyWith(loading: false));
    }
  }

  Future<String> _uploadImageToStorage(File file) async {
    final storageRef =
        storage.ref().child('user_images/${file.uri.pathSegments.last}');
    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => {});
    return await snapshot.ref.getDownloadURL();
  }

  void _onUpdateName(UpdateName event, Emitter<ProfileState> emit) {
    emit(state.copyWith(name: event.name));
  }

  void _onUpdateSurname(UpdateSurname event, Emitter<ProfileState> emit) {
    emit(state.copyWith(surname: event.surname));
  }
}
