class User {
  String email;
  String password;
  List<String> interests;

  User({
    required this.email,
    required this.password,
    List<String>? interests,
  }) : interests = interests ?? [];
}
