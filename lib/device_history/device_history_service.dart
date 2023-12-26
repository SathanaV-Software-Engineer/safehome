import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/login/user_model.dart';
import 'package:safehome/utils/constants.dart';

import 'package:shared_preferences/shared_preferences.dart';

final Dio dio = Dio();

class DeviceHistoryService {
  final WidgetRef ref;
  final BuildContext context;
  DeviceHistoryService(this.context, this.ref) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String accessToken = prefs.getString('token') ?? '';
        options.headers['Authorization'] = 'Bearer $accessToken';
        return handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        log('unauth');
        if (error.response?.statusCode == 401) {
          try {
            ref.read(deviceController).closeChannel();
            UserModel loggedInUser = await ref.read(loginController).login(ref);
            if (loggedInUser.token != null) {
              if (context.mounted) {
                ref.read(deviceController).initialize(context, ref);
              }
              Options options = Options(
                method: error.requestOptions.method,
                headers: {'Authorization': 'Bearer ${loggedInUser.token}'},
              );
              Response response = await dio.request(
                error.requestOptions.path,
                options: options,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
                cancelToken: error.requestOptions.cancelToken,
                onReceiveProgress: error.requestOptions.onReceiveProgress,
                onSendProgress: error.requestOptions.onSendProgress,
              );
              return handler.resolve(response);
            } else {
              return handler.next(error);
            }
          } catch (e) {
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<Response> getDeviceHistory(fromDate, toDate, selectedDeviceId) async {
    try {
      Response response = await dio.get(
        '$tbURL/api/plugins/telemetry/DEVICE/$selectedDeviceId/values/timeseries?startTs=$fromDate&endTs=$toDate&keys=alert',
      );

      return response;
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }
}
