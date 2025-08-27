import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final List<User> _users = [];

  final List<String> _dummyInterests = [
    'Technology','Business','Politics','Health','Entertainment',
    'Sports','Science','Travel','Food','Art','Fashion','Education',
    'Music','Movies','Gaming','Lifestyle','Environment','History',
    'Finance','Photography','Culture','Wellness','DIY',
    'Politics & Law','Automotive','Relationships','Spirituality',
    'Fitness','Animals','Comics & Animation','Technology Startups',
  ];

  @override
  Future<void> signUp(User user) async {
    try {
      if (user.email.isEmpty || user.password.isEmpty) {
        throw Exception('Email and password cannot be empty');
      }
      _users.add(user);
      await Future.delayed(const Duration(seconds: 1));
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
    if (_users.isNotEmpty) _users[_users.length - 1] = user;
    else _users.add(user);
  }
}
