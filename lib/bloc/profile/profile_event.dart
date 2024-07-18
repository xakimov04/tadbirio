import 'package:image_picker/image_picker.dart';

sealed class ProfileEvent {}

class LoadingUserData extends ProfileEvent {}

class LoadUserData extends ProfileEvent {}

class SaveUserData extends ProfileEvent {
  final String name;
  final String surname;
  final String email;
  final String imageUrl;

  SaveUserData(this.name, this.surname, this.email, this.imageUrl);
}

class PickImage extends ProfileEvent {
  final ImageSource source;

  PickImage(this.source);
}

class UpdateName extends ProfileEvent {
  final String name;

  UpdateName(this.name);
}

class UpdateSurname extends ProfileEvent {
  final String surname;

  UpdateSurname(this.surname);
}
