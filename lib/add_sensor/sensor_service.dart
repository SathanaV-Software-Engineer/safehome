import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:safehome/home/sensor_model.dart';
import 'package:safehome/utils/app_config.dart';

class SensorService {
  Future<Response> addSensorService(
      gatewayId, customerId, SensorDetails sensor) async {
    log('**** inside getDeviceHistory service');
    try {
      Response response = await Dio().post(
        AppConfig.api.addSensor,
        data: {
          "gwId": gatewayId,
          "customerId": customerId,
          "sensors": [
            {"name": sensor.name}
          ]
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {}
      return response;
    } catch (error) {
      log(error.toString());
      rethrow;
    }
  }
}
