import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../otp/otp_model.dart';
import '../utils/constants.dart';

class ApiHelper {
  static final Dio dio = Dio();

  static Future<bool> registerUser(
      String phoneNo, String gatewayId, String fcmId, String refererNo) async {
    try {
      Response response = await dio.post(
        '$auditMailServer/usr/create/',
        data: {
          "phone_no": phoneNo,
          "gateway_id": gatewayId,
          "fcm_id": fcmId,
          "referer_no": refererNo,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  static Future<OtpModel> getOTP(String phoneNo) async {
    final data = {
      'phone_no': phoneNo,
    };
    OtpModel result = OtpModel();
    try {
      final response = await dio.post(
        '$auditMailServer/otp/',
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );
      if (response.statusCode == 200) {
        result = OtpModel.fromJson(response.data);
        return result;
      }
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          Fluttertoast.showToast(
            msg: 'Network timeout. Please try again later.',
            toastLength: Toast.LENGTH_SHORT,
          );
          break;
        case DioExceptionType.connectionError:
          Fluttertoast.showToast(
            msg: 'Please check your Internet connection and try again later.',
            toastLength: Toast.LENGTH_SHORT,
          );
          break;
        case DioExceptionType.badCertificate:
          Fluttertoast.showToast(
            msg:
                'Invalid SSL certificate. Please check your network connection.',
            toastLength: Toast.LENGTH_SHORT,
          );
          break;
        case DioExceptionType.unknown:
          Fluttertoast.showToast(
            msg: 'Something went wrong. Please try again later.',
            toastLength: Toast.LENGTH_SHORT,
          );
          break;
        default:
          Fluttertoast.showToast(
            msg: 'Unknown error. Please try again later.',
            toastLength: Toast.LENGTH_SHORT,
          );
          break;
      }
    } catch (e) {
      log('error: $e');
    }
    return result;
  }

  static Future<bool> getSecondaryUsers(String gatewayId) async {
    try {
      Response response = await dio.post(
        '$auditMailServer/get/secondary/phoneno/',
        data: {"gateway_id": gatewayId},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  static Future<bool> updateUser(
      String oldNumber, String newNumber, String gatewayId) async {
    try {
      Response response = await dio.post(
        '$auditMailServer/update/secondary/phoneno/',
        data: {
          "old_phone_no": oldNumber,
          "new_phone_no": newNumber,
          "gateway_id": gatewayId,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  static Future<bool> factoryReset(String gatewayId) async {
    try {
      Response response = await dio.post(
        '$auditMailServer/factoryreset/',
        data: {"gateway_id": gatewayId},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  static Future<bool> saveUser(dynamic saveUserDetails, String phNumber) async {
    try {
      Response response = await dio.post(
        '$auditMailServer/add/usr/',
        data: {
          "secondary_usr": saveUserDetails.getSuser().toString(),
          "gateway_id": saveUserDetails.getGatewayid(),
          "phone_number": phNumber,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  static Future<bool> getUserDataSheet(String phoneNo) async {
    try {
      Response response = await dio.post(
        '$auditMailServer/usr/list/',
        data: {"phone_no": phoneNo},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  static Future<bool> clearUserDetails(String phoneNo) async {
    try {
      Response response = await dio.post(
        '$auditMailServer/delete/usr/',
        data: {"phone_no": phoneNo},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  static Future<bool> registerSecondaryUser(
      String phoneNo, String refererNo, String fcmId) async {
    try {
      Response response = await dio.post(
        '$auditMailServer/add/secondary/usr/',
        data: {
          "phone_no": phoneNo,
          "referer_no": refererNo,
          if (fcmId.isNotEmpty) "fcm_id": fcmId,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  static Future<bool> existingUserLogin(String phoneNo) async {
    try {
      Response response = await dio.post(
        '$auditMailServer/existing/usr/',
        data: {"phone_no": phoneNo},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  static Future<bool> userFactoryReset(String gatewayId) async {
    try {
      Response response = await dio.post(
        '$auditMailServer/factoryreset/',
        data: {"gateway_id": gatewayId},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  static Future<bool> changeSim(String oldNumber, String newNumber) async {
    try {
      Response response = await dio.post(
        '$auditMailServer/update/phoneno/',
        data: {
          "old_phone_no": oldNumber,
          "new_phone_no": newNumber,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  static Future<bool> updateFcm(
      String phNumber, String refererNumber, String fcmId) async {
    try {
      Response response = await dio.post(
        '$auditMailServer/update/fcmid/',
        data: {
          "phone_no": phNumber,
          "referer_no": refererNumber,
          "fcm_id": fcmId,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  static Future<bool> deleteSecondaryUser(
      String secondaryPhoneNo, String gatewayId) async {
    try {
      Response response = await dio.post(
        '$auditMailServer/delete/secondary/phoneno/',
        data: {
          "secondary_phone_no": secondaryPhoneNo,
          "gateway_id": gatewayId,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  static Future<bool> addDeviceRuleChain(
      String deviceName, String deviceAccessNumber, String customerName) async {
    try {
      Response response = await dio.post(
        '$auditMailServer/change/customer/',
        data: {
          "deviceName": deviceName,
          "access": deviceAccessNumber,
          "customerName": customerName,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  static Future<bool> deleteDeviceRuleChain(
      String deviceName, String deviceAccessNumber, String customerName) async {
    try {
      Response response = await dio.post(
        '$auditMailServer/change/tenant/',
        data: {
          "deviceName": deviceName,
          "access": deviceAccessNumber,
          "customerName": customerName,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('error: $e');
      return false;
    }
  }

  static Map<String, dynamic> getCommonParams() {
    Map<String, dynamic> params = {};
    return params;
  }
}
