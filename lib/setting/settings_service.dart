import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:safehome/login/user_model.dart';
import 'package:safehome/utils/app_config.dart';

class SettingsService {
  Future<dynamic> callRecoveryMode(
      String? gatewayId, String? customerId) async {
    try {
      Response response = await Dio().post(AppConfig.api.recovery, data: {
        "gwId": gatewayId,
        "customerId": customerId,
      });
      return response;
    } catch (error) {
      log("Exception: $error");
      rethrow;
    }
  }

  Future<dynamic> callFactoryReset(
      String? gatewayId, String? customerId) async {
    try {
      Response response = await Dio().post(AppConfig.api.factoryReset,
          data: {"gwId": gatewayId, "customerId": customerId});
      return response;
    } catch (error) {
      log("Exception: $error");
      rethrow;
    }
  }

  Future<dynamic> callUpdateUser(
      UserModel loggedUser, String? name, String? phone, String? email) async {
    Map data = {
      "userId": loggedUser.userId,
      "customerId": loggedUser.customerId,
      "name": name,
      "phone": phone,
    };
    if (email!.isNotEmpty) {
      data['email'] = email;
    }
    try {
      Response response =
          await Dio().post(AppConfig.api.updateUser, data: data);
      return response;
    } catch (error) {
      log("Exception: $error");
      rethrow;
    }
  }
}
