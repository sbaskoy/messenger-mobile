import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../controllers/auth_controller.dart';

import 'base_service.dart';

class MessengerService extends IBaseService {
  final AuthController authController;
  MessengerService._internal({required this.authController}) : super(url: AppConstants.baseApiUrl) {
    _setOptions();
  }

  static MessengerService? _singleton;

  factory MessengerService(AuthController authController) {
    _singleton ??= MessengerService._internal(authController: authController);
    return _singleton!;
  }

  void _setOptions() {
    dio.options.validateStatus = (status) => (status ?? 0) > 100 && (status ?? 0) < 501;
    //dio.options.sendTimeout = const Duration(seconds: 2);
    dio.options.connectTimeout = const Duration(seconds: 2);
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        var token = authController.accessToken;
        if (token?.isNotEmpty ?? false) {
          options.headers['Authorization'] = "Bearer $token";
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.statusCode != 200) {
          var jsonResponseData = response.data;
          var message = jsonResponseData["message"] ?? "Unknown error";
          return handler.reject(DioException(requestOptions: response.requestOptions, error: message));
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        if (error.type == DioExceptionType.connectionTimeout) {
          return handler.next(
              DioException(requestOptions: error.requestOptions, error: "Can not connect planner messenger service"));
        }
        if (error.type == DioExceptionType.connectionError) {
          return handler.next(DioException(
              requestOptions: error.requestOptions,
              error: "Can not connect planner messenger service. Please try again later"));
        }
        return handler.next(error);
      },
    ));
  }

  @override
  void dispose() {}
}
