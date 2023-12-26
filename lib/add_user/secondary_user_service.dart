import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/login/user_model.dart';
import 'package:safehome/utils/app_config.dart';
import 'package:safehome/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Dio dio = Dio();

class SecondaryUserService {
  final WidgetRef ref;
  final BuildContext context;
  SecondaryUserService(this.context, this.ref) {
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
            log('hey ${loggedInUser.token}');
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
  Future<dynamic> updateSecondaryUsers(String? gatewayId, List data) async {
    try {
      Response response = await dio.post(AppConfig.api.updateWatchers,
          data: {"gwId": gatewayId, "watchers": data});
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> removeCustomerRelation(
      String? gatewayId, String customerId) async {
    try {
      Response response = await dio.delete(
          "$tbURL/api/relation?fromId=$customerId&fromType=CUSTOMER&relationType=Watches&toId=$gatewayId&toType=DEVICE");
      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<dynamic> getSecondaryUsers(String? gatewayId) async {
    try {
      Response response =
          await dio.post('$tbURL/api/entitiesQuery/find', data: {
        "entityFilter": {
          "type": "relationsQuery",
          "rootEntity": {"entityType": "DEVICE", "id": gatewayId},
          "direction": "TO",
          "filters": [
            {
              "relationType": "Watches",
              "entityTypes": ["CUSTOMER"]
            }
          ]
        },
        "entityFields": [
          {"type": "ENTITY_FIELD", "key": "name"},
          {"type": "ENTITY_FIELD", "key": "label"}
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
      });
      return response;
    } catch (error) {
      log('error in API $error');
      rethrow;
    }
  }
}
