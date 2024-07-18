class ProfileState {
  final String name;
  final String surname;
  final String email;
  final String imageUrl;
  final bool loading;

  ProfileState({
    required this.name,
    required this.surname,
    required this.email,
    required this.imageUrl,
    this.loading = false,
  });

  ProfileState copyWith({
    String? name,
    String? surname,
    String? email,
    String? imageUrl,
    bool? loading,
  }) {
    return ProfileState(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      loading: loading ?? this.loading,
    );
  }
}
