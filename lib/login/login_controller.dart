import 'dart:convert';
import 'dart:developer';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/home/loader_contoller.dart';
import 'package:safehome/login/login_service.dart';
import 'package:safehome/otp/otp_controller.dart';
import 'package:safehome/utils/constants.dart';
import 'package:safehome/utils/dialog_boxes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_helper/api_helper.dart';
import '../notifications/firebase_notification_api.dart';
import '../utils/api_handler.dart';
import 'user_model.dart';

final loginController =
    ChangeNotifierProvider<LoginProvider>((ref) => LoginProvider());

class LoginProvider extends ChangeNotifier {
  final LoginService _loginService = LoginService();
  final UserModel _loggedUser = UserModel(
      profileName: '',
      password: '',
      mobileNumber: '',
      customerId: '',
      label: '',
      userId: '',
      email: '');
  int _otp = 0;

  textFieldUpdate(field, value) {
    if (field == 'mobileNumber') {
      _loggedUser.mobileNumber = value;
    } else if (field == 'email') {
      _loggedUser.email = value;
    } else if (field == 'profileName') {
      _loggedUser.profileName = value;
    }
    notifyListeners();
  }

  updateCurrentUser(userjson) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = userjson['userId'].toString();
    String customerId = userjson['customerId'].toString();
    String? profileName = userjson['name'] != null
        ? userjson['name'].toString()
        : _loggedUser.mobileNumber;
    String? email = userjson['email'] != null
        ? userjson['email'].toString()
        : _loggedUser.email;
    //final userjson = jsonDecode(user['body']);
    await prefs.setString(
        'userDetails',
        jsonEncode({
          'userId': userId,
          'customerId': customerId,
          'name': profileName,
          'email': email,
          'mobileNumber': _loggedUser.mobileNumber
        }));
    _loggedUser.userId = userId;
    _loggedUser.customerId = customerId;
    _loggedUser.profileName = profileName;
    notifyListeners();
  }

  setCurrentUserDetails(userjson, type) {
    _loggedUser.userId = userjson['userId'];
    _loggedUser.customerId = userjson['customerId'];
    _loggedUser.profileName = userjson['name'];
    _loggedUser.mobileNumber = userjson['mobileNumber'];
    _loggedUser.email = userjson['email'];
    _loggedUser.userType = type;
    log('loggedUSer $_loggedUser');
    notifyListeners();
  }

  Future<void> validateLogin(
      BuildContext context, WidgetRef ref, mobileNumber) async {
    try {
      await ApiHelper.getOTP(
        _loggedUser.mobileNumber!,
      ).then((value) {
        if (value.errorCode == 0 && value.otp != 0) {
          _otp = value.otp!;
          Navigator.of(context).pushNamed(otpVerificationRoute);
        }
      });
    } catch (e) {
      log('error: $e');
    }
  }

  bool isValidGateway(String jsonString) {
    return jsonString.contains('"uid"') &&
        jsonString.contains('"name"') &&
        jsonString.contains('"type"');
  }

  Future<void> gatewayScan(WidgetRef ref, BuildContext context) async {
    final result = await BarcodeScanner.scan();
    if (result.rawContent.isNotEmpty) {
      if (isValidGateway(result.rawContent)) {
        await ref
            .read(deviceController)
            .addDevice(result.rawContent)
            .then((value) => ref.read(otpController).updateisRegister(true));
      } else {
        showToast(scanValidDevice);
      }
      log(result.toString());
    } else {
      if (context.mounted) scanQrExitPopup(context, ref);
    }
  }

  void setToken(
      [token =
          'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJzYXRoYW5hQGhnc3Muc2FsemVyLmNvbSIsInVzZXJJZCI6IjdiMWZmNWEwLTg4NzQtMTFlZS1hNDA2LWVmYzI2YzdjYjAyNSIsInNjb3BlcyI6WyJURU5BTlRfQURNSU4iXSwic2Vzc2lvbklkIjoiNmJjODQ0ZGItZmEwNy00MmNkLWJlYTYtNjEyYTI1ZDE2ZTI4IiwiaXNzIjoidGhpbmdzYm9hcmQuaW8iLCJpYXQiOjE3MDMwNjMxNzEsImV4cCI6MTcwMzA3MjE3MSwiZmlyc3ROYW1lIjoiU2F0aGFuYSIsImxhc3ROYW1lIjoiViIsImVuYWJsZWQiOnRydWUsImlzUHVibGljIjpmYWxzZSwidGVuYW50SWQiOiI5NGU1ZDAzMC0xYTU3LTExZWUtYWI1My1lZjNkNGE5NTM1OTkiLCJjdXN0b21lcklkIjoiMTM4MTQwMDAtMWRkMi0xMWIyLTgwODAtODA4MDgwODA4MDgwIn0.ii00x7810X57-f_-6AAcdqmsN84X006ICbvKTxcyT0dsR0pMpe-jMyKPwxHFJouKKsPd4CBAnBpvUeqawCF5MQ']) async {
    final prefs = await SharedPreferences.getInstance();
    _loggedUser.token = token;
    prefs.setString('token', token);
    notifyListeners();
  }

  Future login(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final fcmId = prefs.getString('fcmId') ?? "";
    UserModel loggedInUser = ref.read(loginController).loggedUser;
    try {
      Response response = await _loginService.loginService(
          loggedInUser.userId, loggedInUser.customerId, fcmId);
      if (response.statusCode == 200) {
        _loggedUser.token = response.data['token'];
        _loggedUser.refreshToken = response.data['refreshToken'];
        return _loggedUser;
      } else {
        showToast(getErrorMessageFromThingsBoard(response.statusCode));
      }
    } catch (e) {
      showToast(getErrorMessageFromException(e));
    }
  }

  void cleanData() async {
    final prefs = await SharedPreferences.getInstance();
    cleanRemainderTasks();
    prefs.setString('token', '');
    prefs.setString('refreshToken', '');
    prefs.setString('userDetails', '');
    prefs.setString('userType', '');
    prefs.setString('gatewayDetails', '');
    _loggedUser.profileName = '';
    _loggedUser.mobileNumber = '';
    _loggedUser.email = '';
    _loggedUser.userId = null;
    _loggedUser.customerId = null;
    _loggedUser.label = null;
    _loggedUser.password = null;
    _loggedUser.userType = null;
    _loggedUser.active = null;
    _loggedUser.token = null;
    _loggedUser.refreshToken = null;
    _loggedUser.createdBy = null;
    _loggedUser.createdDate = null;
    _loggedUser.updatedBy = null;
    _loggedUser.updatedDate = null;
  }

  setUserType(value) async {
    _loggedUser.userType = value;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userType', value);
    notifyListeners();
  }

  cleanDatabase() {
    final notificationsDb = Hive.box('notifications');
    notificationsDb.put("FILTEREDNOTIFICATIONS", []);
    notificationsDb.put("NOTIFICATIONS", []);
  }

  Future logout(BuildContext context, WidgetRef ref, String? gwId) async {
    setLoaderMessage(context, ref, logingOut);
    final prefs = await SharedPreferences.getInstance();
    final fcmId = prefs.getString('fcmId') ?? "";
    // uncomment once login implementation is completed
    if (context.mounted) {
      try {
        Response response = await _loginService.callLogoutService(
            fcmId, _loggedUser.customerId);
        if (response.statusCode == 200) {
          if (_loggedUser.userType == 'primaryUserLogin') {
            ref.read(deviceController).closeChannel();
          }
          cleanData();
          cleanDatabase();
          ref.read(otpController).cleanOtpData();
          ref.read(deviceController).emptyDevice();
          if (context.mounted) ref.read(otpController).logoutFirebase(context);
          return 200;
        }
      } catch (e) {
        log('error $e');
        showToast(getErrorMessageFromException(e));
      } finally {
        if (context.mounted) cleanLoaderMessage(context, ref);
      }
    }
  }

  int get otp => _otp;
  UserModel get loggedUser => _loggedUser;
}
