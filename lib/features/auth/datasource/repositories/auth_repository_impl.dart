import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final List<User> _users = [];

  final List<User> _predefinedUsers = [
    User(
      fullName: "Test User",
      email: "test@example.com",
      password: "password123",
      interests: ['Technology', 'Sports'],
    ),
    User(
      fullName: "Demo User",
      email: "demo@example.com",
      password: "demo123",
      interests: ['Business', 'Health'],
    ),
  ];
  final List<String> _dummyInterests = [
    'Technology',
    'Business',
    'Politics',
    'Health',
    'Entertainment',
    'Sports',
    'Science',
    'Travel',
    'Food',
    'Art',
    'Fashion',
    'Education',
    'Music',
    'Movies',
    'Gaming',
    'Lifestyle',
    'Environment',
    'History',
    'Finance',
    'Photography',
    'Culture',
    'Wellness',
    'DIY',
    'Politics & Law',
    'Automotive',
    'Relationships',
    'Spirituality',
    'Fitness',
    'Animals',
    'Comics & Animation',
    'Technology Startups',
  ];

  @override
  Future<void> signUp(User user) async {
    try {
      if (user.fullName.isEmpty ||
          user.email.isEmpty ||
          user.password.isEmpty) {
        throw Exception('Full Name, Email, and Password cannot be empty');
      }
      _users.add(user);
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

@override
Future<User> login(String email, String password) async {
  try {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password can not be empty');
    }

    await Future.delayed(const Duration(seconds: 1));

    // Check in predefined users first
    try {
      final predefinedUser = _predefinedUsers.firstWhere(
        (user) => user.email == email && user.password == password,
      );
      return predefinedUser;
    } catch (e) {
      // If not found in predefined users, check in registered users
      try {
        final registeredUser = _users.firstWhere(
          (user) => user.email == email && user.password == password,
        );
        return registeredUser;
      } catch (e) {
        throw Exception('Invalid email or password');
      }
    }
  } catch (e) {
    throw ServerException(e.toString());
  }
}

  @override
  Future<List<String>> getAvailableInterests() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return _dummyInterests;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  User? get lastUser => _users.isNotEmpty ? _users.last : null;

  @override
  void updateLastUser(User user) {
    if (_users.isNotEmpty)
      _users[_users.length - 1] = user;
    else
      _users.add(user);
  }

  @override
  Future<User> signUpWithGoogle() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final user = User(
        fullName: "Google User",
        email: "dummy.google.user@gmail.com",
        password: "google_dummy_password", // not real, just placeholder
      );
      _users.add(user);
      return user;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<User> loginWithGoogle() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final user = User(
        fullName: "Google User",
        email: "google.user@gmail.com",
        password: "google_auth_token", // placeholder
        interests: ['Technology', 'Gaming'],
      );

      if (!_users.any((u) => u.email == user.email)) {
        _users.add(user);
      }
      return user;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
