import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/notifications/notification_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

final splashController =
    ChangeNotifierProvider<SplashProvider>((ref) => SplashProvider());

class SplashProvider extends ChangeNotifier {
  late Timer timer;

  checkAppVersion(BuildContext context, WidgetRef ref) {
    Timer(const Duration(milliseconds: 4000), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token") ?? '';
      String? gatewayDetails = prefs.getString("gatewayDetails") ?? '';
      String? userDetails = prefs.getString("userDetails") ?? '';
      String? userType = prefs.getString("userType") ?? '';
      log('token $token');
      log('gatewayDetails --> $gatewayDetails');
      log('userDetails --> $userDetails');
      log('userType --> $userType');
      if (userDetails.isNotEmpty && token.isNotEmpty) {
        log('note here -> ${jsonDecode(userDetails)["userId"]}');
        ref
            .read(loginController)
            .setCurrentUserDetails(jsonDecode(userDetails), userType);
        if (userType == 'primaryUserLogin') {
          await ref.read(loginController).login(ref).then((value) async {
            await ref.read(deviceController).addDevice(gatewayDetails).then(
                (value) => ref.read(deviceController).initialize(context, ref));
            if (context.mounted) {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(homeRoute, (route) => false);
            }
          });
        } else if (userType == 'secondaryUserLogin') {
          ref.read(notificationController).setCurrentTab(1);
          if (context.mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(notificationsRoute, (route) => false);
          }
        }
      } else {
        if (context.mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(otpRoute, (route) => false);
        }
      }
    });
  }
}
