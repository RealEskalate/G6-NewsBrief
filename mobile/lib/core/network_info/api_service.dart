import 'package:dio/dio.dart';
import 'package:newsbrief/core/storage/token_secure_storage.dart';
import 'package:newsbrief/core/storage/token_storage.dart';

// Custom exception for already registered email
class EmailAlreadyRegisteredException implements Exception {
  final String message;
  EmailAlreadyRegisteredException([this.message = "Email already registered."]);
  @override
  String toString() => message;
}

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
          if (e.response?.statusCode == 401) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              final access = await tokenStorage.readAccessToken();
              final reqOptions = e.requestOptions;
              reqOptions.headers['Authorization'] = 'Bearer $access';
              try {
                final cloneResponse = await dio.fetch(reqOptions);
                return handler.resolve(cloneResponse);
              } catch (err) {
                return handler.reject(
                  _toDioException(_mapError(err), e.requestOptions),
                );
              }
            }
          }
          handler.reject(_toDioException(_mapError(e), e.requestOptions));
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
      await tokenStorage.clear();
      return false;
    }
  }

  // ✅ Safe request wrappers
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) async {
    try {
      return await dio.get<T>(path, queryParameters: query);
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    try {
      return await dio.post<T>(path, data: data);
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    try {
      return await dio.put<T>(path, data: data);
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response<T>> delete<T>(String path, {dynamic data}) async {
    try {
      return await dio.delete<T>(path, data: data);
    } catch (e) {
      throw _mapError(e);
    }
  }

  // ✅ Centralized error mapper
  Exception _mapError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return Exception("Connection timed out. Please try again.");
      }

      if (error.type == DioExceptionType.badResponse) {
        final status = error.response?.statusCode;
        final data = error.response?.data;

        // Handle already registered email from server
        if (data is Map<String, dynamic> &&
            data['message']?.toString().toLowerCase().contains('already registered') == true) {
          return EmailAlreadyRegisteredException();
        }

        String message = "Server error";
        if (data is Map<String, dynamic>) {
          message = data['message']?.toString() ?? message;
        }
        return Exception("[$status] $message");
      }

      return Exception("Please check your connection or incorrect credential.");
    }

    // Wrap anything else into Exception
    if (error is Exception) return error;
    return Exception("Unexpected error occurred.");
  }

  // ✅ Wraps Exception into DioException so handler.reject works
  DioException _toDioException(Exception error, RequestOptions requestOptions) {
    return DioException(
      requestOptions: requestOptions,
      error: error,
      type: DioExceptionType.unknown,
    );
  }
}
