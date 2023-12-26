import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safehome/home/loader_contoller.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/otp/otp_service.dart';
import 'package:safehome/utils/common_utils.dart';
import 'package:safehome/utils/constants.dart';

import '../home/gw_scan_response.dart';
import '../login/user_model.dart';
import '../utils/api_handler.dart';

final otpController =
    ChangeNotifierProvider<OtpProvider>((ref) => OtpProvider());

class OtpProvider extends ChangeNotifier {
  final OTPService _otpService = OTPService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String verifyId = "";
  String _enteredOtp = '';
  String phoneNumber = '';
  int token = 0;
  bool showResendOtp = true;
  int secondsLeft = 0;
  late Timer timerInstance;
  bool _isRegisterScreen = false;

  void otpFieldUpdate(otp) {
    _enteredOtp = otp;
    notifyListeners();
  }

  void cleanOtpData() {
    verifyId = "";
    _enteredOtp = '';
    phoneNumber = '';
    token = 0;
    showResendOtp = true;
    secondsLeft = 0;
    _isRegisterScreen = false;
    notifyListeners();
  }

  void updateisRegister(bool value) {
    _isRegisterScreen = value;
    notifyListeners();
  }

  startResendOtpTimer() {
    showResendOtp = true;
    startTimer(30);
    notifyListeners();
  }

  startTimer(int seconds) {
    secondsLeft = seconds;
    timerInstance = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (secondsLeft == 0) {
        showResendOtp = false;
        timer.cancel();
      } else {
        secondsLeft--;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    showResendOtp = false;
    timerInstance.cancel();
    super.dispose();
  }

  Future findUser(
      {required BuildContext context,
      required WidgetRef ref,
      required String phone}) async {
    try {
      Response response = await _otpService.findUser(phone);
      if (response.statusCode == 200) {
        await ref.read(loginController).updateCurrentUser(response.data);
        log("data ${response.data['body']}");
        // dynamic gatewayDetails = response.data['body']['spaces'][0];
        // String device =
        //     '{"uid":"${gatewayDetails.id}","name":"${gatewayDetails.name}","type":"gw", "label": "${gatewayDetails.label}"}';
        // await ref.read(deviceController).addDevice(device);
        return 200;
      } else {
        if (context.mounted) cleanLoaderMessage(context, ref);

        showToast(getErrorMessageFromThingsBoard(response.statusCode));
      }
    } catch (e) {
      log('error $e');
      if (context.mounted) cleanLoaderMessage(context, ref);
      showToast(getErrorMessageFromException(e));
    }
  }

  Future registerGW(
      {required BuildContext context,
      required WidgetRef ref,
      required UserModel user,
      required GatewayQRResponse gw}) async {
    try {
      Response response = await _otpService.registerGwService(user, gw);
      if (response.statusCode == 200) {
        Map data = {
          "customerId": response.data["customerId"],
          "userId": response.data["userId"],
          "name": user.profileName,
          "email": user.email
        };
        ref.read(loginController).updateCurrentUser(data);
        return 200;
      }
    } catch (e) {
      if (context.mounted) cleanLoaderMessage(context, ref);
      showToast(getErrorMessageFromException(e));
    }
  }

  getOtpForNewUSer(BuildContext context, WidgetRef ref, UserModel loginUser,
      GatewayQRResponse currentGwDevice) {
    if (!isValidNumber(
        ref.read(loginController).loggedUser.mobileNumber ?? '')) {
      showToast(provideValidNumber);
      return;
    }
    if (loginUser.profileName!.isEmpty) {
      showToast('Profile Name should not be empty');
      return;
    }
    if (loginUser.email!.isNotEmpty && !isEmailValid(loginUser.email ?? '')) {
      showToast('Please enter a valid email');
      return;
    }
    if (!isValidNumber(
        ref.read(loginController).loggedUser.mobileNumber ?? '')) {
      showToast(provideValidNumber);
      return;
    }
    setLoaderMessage(context, ref, registerProcess);
    ref
        .read(otpController)
        .registerGW(
            context: context, ref: ref, user: loginUser, gw: currentGwDevice)
        .then((value) {
      if (value == 200) {
        ref.read(otpController).getOTP(context, ref, loginUser.mobileNumber!);
      }
    });
  }

  getOtpForOldUser(BuildContext context, WidgetRef ref, UserModel loginUser) {
    if (!isValidNumber(
        ref.read(loginController).loggedUser.mobileNumber ?? '')) {
      showToast(provideValidNumber);
      return;
    }
    setLoaderMessage(context, ref, sendingOtp);
    ref
        .read(otpController)
        .findUser(context: context, ref: ref, phone: loginUser.mobileNumber!)
        .then((value) {
      if (value == 200) {
        ref.read(otpController).getOTP(context, ref, loginUser.mobileNumber!);
      }
    });
  }

  Future getOTP(BuildContext context, WidgetRef ref, String phone) async {
    phoneNumber = phone;
    await _firebaseAuth
        .verifyPhoneNumber(
      timeout: const Duration(seconds: 30),
      phoneNumber: "+91$phoneNumber",
      verificationCompleted: (phoneAuthCredential) async {
        return;
      },
      verificationFailed: (error) async {
        if (error.code == 'invalid-phone-number') {
          cleanLoaderMessage(context, ref);
          Fluttertoast.showToast(
            msg: 'Invalid Phone Number',
            toastLength: Toast.LENGTH_SHORT,
          );
        } else {
          cleanLoaderMessage(context, ref);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Error in sending OTP",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ));
        }
        return;
      },
      codeSent: (verificationId, forceResendingToken) async {
        verifyId = verificationId;
        token = forceResendingToken!;
        startResendOtpTimer();
        log('**** code send');
        cleanLoaderMessage(context, ref);
        //We need to remove the below once the login API was completed
        //_loginService.loginService('');
        Navigator.of(context).pushNamed(otpVerificationRoute);
      },
      codeAutoRetrievalTimeout: (verificationId) async {
        return;
      },
    )
        .onError((error, stackTrace) {
      cleanLoaderMessage(context, ref);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Error in sending OTP",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    });
  }

  Future<void> resendSMS(BuildContext context) async {
    startResendOtpTimer();
    await FirebaseAuth.instance
        .verifyPhoneNumber(
      phoneNumber: "+91$phoneNumber",
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Error in sending OTP",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ));
      },
      codeSent: (String verificationId, int? forceResendingToken) {},
      codeAutoRetrievalTimeout: (String verificationId) {},
      forceResendingToken: token,
    )
        .onError((error, stackTrace) {
      log('error on ->  $error');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Error in sending OTP",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    });
  }

  Future loginWithOtp() async {
    final cred = PhoneAuthProvider.credential(
        verificationId: verifyId, smsCode: _enteredOtp);

    try {
      final user = await _firebaseAuth.signInWithCredential(cred);
      if (user.user != null) {
        return 200;
      } else {
        return "Error in Otp login";
      }
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  Future logoutFirebase(BuildContext context) async {
    await _firebaseAuth.signOut().then((value) => Navigator.of(context)
        .pushNamedAndRemoveUntil(otpRoute, (route) => false));
  }

  Future<bool> isLoggedIn() async {
    var user = _firebaseAuth.currentUser;
    return user != null;
  }

  String get enteredOtp => _enteredOtp;
  bool get isRegisterScreen => _isRegisterScreen;
}
