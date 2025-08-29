class User {
  final String id;
  final String fullName;
  final String email;
  final String password;
  List<String>? interests;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.interests,
  });
}
