import 'package:flutter/material.dart';
import 'package:safehome/edit_profile_info/edit_profile_information.dart';
import 'package:safehome/notifications/primary_user_notification_page.dart';

import 'add_sensor/add_sensor_page.dart';
import 'add_user/secondary_user_page.dart';
import 'device_history/device_history_page.dart';
import 'edit_device_info/edit_space_information.dart';
import 'home/home_page.dart';
import 'otp/otp_page.dart';
import 'login/login_page.dart';
import 'otp/otp_verification_page.dart';
import 'setting/settings.dart';
import 'splash/splash_page.dart';
import 'utils/constants.dart';

class HgssApp extends StatelessWidget {
  HgssApp({Key? key}) : super(key: key);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'HGSS App',
      theme: lightTheme(context),
      initialRoute: splashRoute,
      routes: {
        splashRoute: (context) => const SplashPage(),
        loginRoute: (context) => const LoginPage(),
        otpRoute: (context) => OTPPage(),
        homeRoute: (context) => const HomePage(),
        otpVerificationRoute: (context) => OtpPageVerification(),
        addUserRoute: (context) => AddUserPage(),
        notificationsRoute: (context) => SecondaryUserNotification(),
        primaryNotificationsRoute: (context) => PrimaryUserNotification(),
        settingsRoute: (context) => Settings(),
        deviceHistoryRoute: (context) => DeviceHistory(),
        editInformationRoute: (context) => EditSpaceInformation(),
        editProfileRoute: (context) => EditProfileInformation(),
        addSensorRoute: (context) => AddSensor(),
      },
    );
  }
}
