import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:safehome/utils/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  Future<Response> loginService(userId, customerId, fcmId) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> data = {
      "username": "sathana@hgss.salzer.com",
      "password": "salzer"
    };
    Map<String, String> data2 = {
      "userId": userId,
      "customerId": customerId,
      "fcmId": fcmId
    };
    try {
      Response response;
      Response response2 = await Dio()
          .post(
        AppConfig.api.login,
        data: data2,
      )
          .then((value) async {
        response = await Dio().post(
          'https://salzerelectronics.in/api/auth/login',
          data: data,
        );
        if (response.statusCode == 200 && response.data['token'] != null) {
          prefs.setString('token', response.data['token']);
          log("token ${response.data['token']}");
          prefs.setString('refreshToken', response.data['refreshToken']);
        }
        return response;
      });
      return response2;
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }

  Future<dynamic> callLogoutService(fcmId, customerId) async {
    try {
      Response response = await Dio().post(AppConfig.api.logout, data: {
        "fcmId": fcmId,
        "customerId": customerId,
      });
      return response;
    } catch (error) {
      log("Exception: $error");
      rethrow;
    }
  }
}
