import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/login/user_model.dart';
import 'package:safehome/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_config.dart';
import 'gw_scan_response.dart';

final Dio dio = Dio();

class HomeService {
  final WidgetRef ref;
  final BuildContext context;
  HomeService(this.context, this.ref) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String accessToken = prefs.getString('token') ?? '';
        options.headers['Authorization'] = 'Bearer $accessToken';
        return handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
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
  Future<dynamic> getServerScopedAttributes(String gatewayId) async {
    try {
      Response response = await dio.get(
          '$tbURL/api/plugins/telemetry/DEVICE/$gatewayId/values/attributes/SERVER_SCOPE');
      if (response.statusCode == 200) {
        log('success');
        return response;
      } else {
        log('error');
        return response.statusCode;
      }
    } catch (error) {
      log('error ex $error');
      rethrow;
    }
  }

  Future<dynamic> getSharedScopedAttributes(
      String gatewayId, Map<String, dynamic>? data) async {
    try {
      Response response = await dio.get(
          '$tbURL/api/plugins/telemetry/DEVICE/$gatewayId/values/attributes/SHARED_SCOPE',
          queryParameters: data);
      if (response.statusCode == 200) {
        log('success');
        return response;
      } else {
        log('error');
        return response.statusCode;
      }
    } catch (error) {
      log('error ex $error');
      rethrow;
    }
  }

  Future<Response> getSystemDetails(String customerId) async {
    Map<String, String> data = {"customerId": customerId};
    try {
      Response response = await Dio().post(AppConfig.api.getSystemDetails,
          data: data,
          options: Options(
            contentType: 'application/json',
          ));
      log(response.toString());
      return response;
    } catch (error) {
      log("Exception: $error");
      rethrow;
    }
  }

  //unused
  Future<Response> updateGWlable(
      GatewayQRResponse device, String newLable) async {
    Map<String, dynamic> data = {
      "id": {"id": device.uid, "entityType": "DEVICE"},
      "label": newLable,
    };
    try {
      Response response = await Dio().post(
          'https://salzerelectronics.in/swagger-ui/#/device-controller/saveDeviceUsingPOST',
          data: data,
          options: Options(
            contentType: 'application/json',
          ));
      log(response.toString());
      return response;
    } catch (error) {
      log("Exception: $error");
      rethrow;
    }
  }

  Future<dynamic> getDeviceInfo(String deviceId) async {
    try {
      Response response = await dio.get('$tbURL/api/device/info/$deviceId');
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> callEditDevice(
      String deviceId, String name, String label, String type) async {
    try {
      Response mainResponse = await getDeviceInfo(deviceId);
      dynamic data = mainResponse.data;
      data['label'] = label;
      Response response = await dio.post('$tbURL/api/device', data: data);
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> callRemoveDevice(String? gatewayId, String deviceId) async {
    try {
      Response response = await dio.post(AppConfig.api.removeSensor,
          data: {"sensorId": deviceId, "gwId": gatewayId});
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> callRpcTwoWay(
      String gatewayId, Map<String, dynamic> data) async {
    try {
      Response response =
          await dio.post('$tbURL/api/rpc/twoway/$gatewayId', data: data);
      return response;
    } catch (error) {
      rethrow;
    }
  }

  //unused
  Future<dynamic> getRelations(String gatewayId) async {
    try {
      Response response = await dio.get(
        '$tbURL/api/relations/info?fromId=$gatewayId&fromType=DEVICE',
      );
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> findRelatedDevices(String gatewayId) async {
    Map data = {
      "entityFilter": {
        "type": "relationsQuery",
        "rootEntity": {"entityType": "DEVICE", "id": gatewayId},
        "direction": "FROM",
        "maxLevel": 1,
        "fetchLastLevelOnly": false,
        "filters": [
          {
            "relationType": "Manages",
            "entityTypes": ["DEVICE"]
          }
        ]
      },
      "entityFields": [
        {"type": "ENTITY_FIELD", "key": "name"},
        {"type": "ENTITY_FIELD", "key": "label"}
      ],
      "latestValues": [
        {"type": "ATTRIBUTE", "key": "state"},
        {"type": "ATTRIBUTE", "key": "deviceuid"},
        {"type": "ATTRIBUTE", "key": "type"},
        {"type": "ATTRIBUTE", "key": "devIndex"},
        {"type": "TIME_SERIES", "key": "alert"}
      ],
      "pageLink": {
        "dynamic": true,
        "page": 0,
        "pageSize": 20,
        "sortOrder": {
          "key": {"key": "name", "type": "ENTITY_FIELD"},
          "direction": "ASC"
        }
      }
    };
    try {
      Response response =
          await dio.post('$tbURL/api/entitiesQuery/find', data: data);
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> getDeviceAttributes(String deviceId) async {
    try {
      Response response = await dio.get(
        '$tbURL/api/plugins/telemetry/DEVICE/$deviceId/values/attributes',
      );
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> addDataToServerAttribute(String deviceId, data) async {
    try {
      Response response = await dio.post(
        '$tbURL/api/plugins/telemetry/DEVICE/$deviceId/SERVER_SCOPE',
        data: data,
      );
      return response;
    } catch (error) {
      rethrow;
    }
  }
}
