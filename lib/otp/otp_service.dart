import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:safehome/login/user_model.dart';
import '../home/gw_scan_response.dart';
import '../utils/app_config.dart';

class OTPService {
  Future<dynamic> findUser(phoneNo) async {
    try {
      Response response = await Dio().get(AppConfig.api.findUser + phoneNo,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
          ));
      return response;
    } catch (error) {
      log("Exception: $error");
      rethrow;
    }
  }

  Future<Response> registerGwService(
      UserModel user, GatewayQRResponse gw) async {
    Map<String, String> data = {
      "gwId": gw.uid!,
      "phone": user.mobileNumber!,
      "name": user.profileName ?? '',
    };
    if (user.email!.isNotEmpty) {
      data["email"] = user.email!;
    }
    try {
      Response response = await Dio().post(AppConfig.api.register,
          data: data,
          options: Options(
            contentType: 'application/json',
          ));
      log(response.toString());
      return response;
    } catch (e) {
      log("Exception: $e");

      rethrow;
    }
  }
}

class MyCustomException implements Exception {
  final Map<String, dynamic> response;

  MyCustomException(this.response);
}
