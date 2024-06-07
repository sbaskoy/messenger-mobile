import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../controllers/auth_controller.dart';

import 'base_service.dart';

class MessengerService extends IBaseService {
  //final AuthController authController;
  MessengerService(AuthController authController) : super(url: AppConstants.baseApiUrl) {
    _setOptions(authController);
  }

  void _setOptions(AuthController authController) {
    // dio.options.validateStatus = (status) => (status ?? 0) > 100 && (status ?? 0) < 501;
    //dio.options.sendTimeout = const Duration(seconds: 2);
    dio.options.connectTimeout = const Duration(seconds: 2);

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        var token = authController.accessToken();
        if (token?.isNotEmpty ?? false) {
          options.headers['Authorization'] = "Bearer $token";
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          var refreshToken = authController.refreshToken();

          if (refreshToken != null) {
            var tokenResponse = await dio.post('/auth/refresh-token', data: {'refresh_token': refreshToken});
            if (tokenResponse.statusCode == 200) {
              //   var jsonResponse = jsonDecode(tokenResponse.data);
              String newAccessToken = tokenResponse.data['access_token'];
              String newRefreshToken = tokenResponse.data['refresh_token'];
              authController.setAccessToken(newAccessToken);
              authController.setRefreshToken(newRefreshToken);
              authController.saveToPreferences();
              error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              final opts = Options(method: error.requestOptions.method);
              final cloneReq = await dio.request(
                error.requestOptions.path,
                options: opts,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              return handler.resolve(cloneReq);
            }
          }
        }

        if (error.response?.statusCode != 200) {
          var jsonResponseData = error.response?.data;

          var message = jsonResponseData["message"] ?? "Unknown error";
          return handler.reject(DioException(requestOptions: error.requestOptions, error: message));
        }

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
