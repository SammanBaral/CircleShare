import 'package:circle_share/app/constants/api_endpoints.dart';
import 'package:circle_share/app/shared_prefs/token_shared_prefs.dart';
import 'package:circle_share/core/network/dio_error_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  final Dio _dio;
  final TokenSharedPrefs? tokenPrefs; // Add token provider

  Dio get dio => _dio;

  ApiService(this._dio, {this.tokenPrefs}) {
    _dio
      ..options.baseUrl = ApiEndpoints.baseUrl
      ..options.connectTimeout = ApiEndpoints.connectionTimeout
      ..options.receiveTimeout = ApiEndpoints.recieveTimeout
      ..interceptors.add(DioErrorInterceptor())
      ..interceptors.add(PrettyDioLogger(
          requestHeader: true, requestBody: true, responseHeader: true))
      ..options.headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

    // Add token interceptor if token provider is available
    if (tokenPrefs != null) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Try to get token
            final tokenResult = await tokenPrefs!.getToken();
            
            // Add token to headers if available
            tokenResult.fold(
              (failure) {
                print('Failed to get token: ${failure.message}');
              },
              (token) {
                if (token.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $token';
                  print('Adding token to request: ${options.uri}');
                }
              },
            );
            return handler.next(options);
          },
        ),
      );
    }
  }
}