import 'dart:developer';

import 'package:dio/dio.dart';

class ThingsManager {
  static final Dio dio = Dio();
  static const String baseUrl = "YOUR_BASE_URL";
  static String accessToken = "YOUR_ACCESS_TOKEN";

  Future<Response> _sendRequest(
    String url,
    String method, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await dio.request(
        url,
        data: data,
        options: Options(
          method: method,
          headers: {
            "X-Authorization": "Bearer $accessToken",
          },
        ),
        queryParameters: data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/auth/login',
        'POST',
        data: {
          "username": username,
          "password": password,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  Future<bool> logout(String deviceName) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/auth/logout',
        'POST',
        data: {},
      );

      return response.statusCode == 200;
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  Future<bool> refreshToken(String refreshToken) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/auth/token',
        'POST',
        data: {
          "refreshToken": refreshToken,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  Future<Response> getDeviceAvailability(String deviceName) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/tenant/devices',
        'GET',
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getUserToken(String userId, String deviceName) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/user/$userId/token',
        'GET',
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getDevice(String deviceId, String deviceName) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/device/$deviceId',
        'GET',
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteDevice(String deviceId, String deviceName) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/device/$deviceId',
        'DELETE',
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> telemetryHistory(
    String entityId,
    String keys,
    String fromDate,
    String toDate,
    String deviceName,
  ) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/plugins/telemetry/DEVICE/$entityId/values/timeseries',
        'GET',
        data: {
          "pageSize": 100,
          "page": 0,
          "agg": "NONE",
          "keys": keys,
          "startTs": fromDate,
          "endTs": toDate,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getDeviceIndex(String deviceId, String deviceName) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/plugins/telemetry/DEVICE/$deviceId/values/attributes',
        'GET',
        data: {
          "keys": "devIndex,devLabel,deviceuid,devEditLabel,type",
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getDeviceCurrentState(
      String deviceId, String deviceName) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/plugins/telemetry/DEVICE/$deviceId/values/attributes',
        'GET',
        data: {
          "keys": "state",
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getRelations(
      String fromId, String fromType, String origin) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/relations?fromId=$fromId&fromType=$fromType',
        'GET',
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getRelationsTo(
      String toId, String toType, String origin) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/relations?toId=$toId&toType=$toType',
        'GET',
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> saveDevice(
    String entityGroupId,
    Map<String, dynamic> device,
    String extraOutput,
    String deviceName,
  ) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/device/?entityGroupId=$entityGroupId',
        'POST',
        data: device,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> saveRelation(String gatewayDeviceId,
      Map<String, dynamic> device, String deviceName) async {
    try {
      final fromObject = {
        "entityType": "DEVICE",
        "id": gatewayDeviceId,
      };

      final toObject = {
        "type": "Contains",
        "typeGroup": "COMMON",
        "from": fromObject,
        "to": device,
      };

      final response = await _sendRequest(
        '$baseUrl/api/relation',
        'POST',
        data: toObject,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getDeviceCredentialsByDeviceId(
      String deviceId, String deviceName) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/device/$deviceId/credentials',
        'GET',
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> saveDeviceCredential(
      Map<String, dynamic> deviceCredential, String deviceName) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/device/credentials',
        'POST',
        data: deviceCredential,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> callRPCTwoWay(
    String deviceId,
    Map<String, dynamic> jsonObject,
    String deviceName,
  ) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/rpc/twoway/$deviceId',
        'POST',
        data: jsonObject,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> callRPCTwoWayGetState(
    String deviceId,
    Map<String, dynamic> jsonObject,
    String deviceName,
  ) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/rpc/twoway/$deviceId',
        'POST',
        data: jsonObject,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addMessagingToken(String deviceId, String deviceName) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/plugins/telemetry/DEVICE/$deviceId/values/attributes',
        'POST',
        data: {
          "fcmid": "YOUR_FCM_TOKEN",
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addAttributeDeviceIndex(
      String deviceId, String deviceIndex, String deviceName) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/plugins/telemetry/DEVICE/$deviceId/values/attributes',
        'POST',
        data: {
          "devIndex": deviceIndex,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addAttributeDeviceName(
      String deviceId, String devLabel, String deviceName) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/plugins/telemetry/DEVICE/$deviceId/values/attributes',
        'POST',
        data: {
          "devLabel": devLabel,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addAttributeEditDeviceName(
      String deviceId, String devLabel, String deviceName) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/plugins/telemetry/DEVICE/$deviceId/values/attributes',
        'POST',
        data: {
          "devEditLabel": devLabel,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addAttributeDeviceUID(
      String deviceId, String deviceUID, String deviceName) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/plugins/telemetry/DEVICE/$deviceId/values/attributes',
        'POST',
        data: {
          "deviceuid": deviceUID,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addDeviceState(String deviceId, String deviceName) async {
    try {
      final response = await _sendRequest(
        '$baseUrl/api/plugins/telemetry/DEVICE/$deviceId/values/attributes',
        'POST',
        data: {
          "state": "DISARM",
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
