abstract class TokenStorage {
  Future<void> writeAccessToken(String token);
  Future<void> writeRefreshToken(String token);
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> clear();
}
