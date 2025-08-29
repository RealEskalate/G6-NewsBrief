import 'package:dio/dio.dart';
import 'package:newsbrief/core/storage/token_secure_storage.dart';
import 'package:newsbrief/core/storage/token_storage.dart';

class ApiService {
  final Dio dio;
  final TokenStorage tokenStorage;

  ApiService({required String baseUrl, required this.tokenStorage})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'content-Type': 'application/json'},
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final access = await tokenStorage.readAccessToken();
          if (access != null && access.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $access';
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          //auto refresh on 401 if we have a refresh token
          if (e.response?.statusCode == 401) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              //retry the original request with fresh access token
              final access = await tokenStorage.readAccessToken();
              final reqOptions = e.requestOptions;
              reqOptions.headers['Authorization'] = 'Bearer$access';
              try {
                final cloneResponse = await dio.fetch(reqOptions);
                return handler.resolve(cloneResponse);
              } on DioException catch (err) {
                return handler.reject(err);
              }
            }
          }
          handler.next(e);
        },
      ),
    );
  }
  Future<bool> _tryRefreshToken() async {
    final tokenStorage = TokenSecureStorage();
    final refresh = await tokenStorage.readRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final res = await Dio(
        BaseOptions(baseUrl: dio.options.baseUrl),
      ).post('/auth/refresh_token', data: {'refresh_token': refresh});
      final access = res.data['access_token'] as String?;
      final newRefresh = res.data['refresh_token'] as String?;
      if (access != null) {
        await tokenStorage.writeAccessToken(access);
      }
      if (newRefresh != null) {
        await tokenStorage.writeRefreshToken(newRefresh);
      }
      return access != null;
    } catch (_) {
      await tokenStorage.clear(); //refresh failed + clear tokens
      return false;
    }
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) {
    return dio.get<T>(path, queryParameters: query);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) {
    return dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path, {dynamic data}) {
    return dio.delete<T>(path, data: data);
  }
}
