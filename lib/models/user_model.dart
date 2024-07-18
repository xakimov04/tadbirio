class UserModel {
  final String id;
  final String name;
  final String surname;
  final String imageUrl;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.imageUrl,
    required this.email,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      email: data['email'] ?? '',
      imageUrl: data['image_url'] ?? '',
    );
  }
}
