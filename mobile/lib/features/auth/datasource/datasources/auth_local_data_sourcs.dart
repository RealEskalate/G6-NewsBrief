
import 'package:newsbrief/core/storage/token_storage.dart';

class AuthLocalDataSource {
  final TokenStorage storage;
  AuthLocalDataSource(this.storage);

  Future<void> cacheTokens({required String access, required String refresh}) async {
    await storage.writeAccessToken(access);
    await storage.writeRefreshToken(refresh);
  }

  Future<String?> getAccessToken() => storage.readAccessToken();
  Future<String?> getRefreshToken() => storage.readRefreshToken();

  Future<void> clear() => storage.clear();
}
