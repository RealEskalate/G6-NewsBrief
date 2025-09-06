import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:newsbrief/core/storage/token_storage.dart';

class TokenSecureStorage implements TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  @override
  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }

  @override
  Future<String?> readAccessToken() => _storage.read(key: _kAccess);
  @override
  Future<String?> readRefreshToken() => _storage.read(key: _kRefresh);

  @override
  Future<void> writeAccessToken(String token) =>
      _storage.write(key: _kAccess, value: token);
  @override
  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: _kRefresh, value: token);
}
