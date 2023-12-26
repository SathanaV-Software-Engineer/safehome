import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/home/loader_contoller.dart';
import 'package:safehome/no_internet_pages/no_internet_page.dart';
import 'package:safehome/notifications/firebase_notification_api.dart';
import 'package:safehome/notifications/notification_controller.dart';
import 'package:safehome/otp/otp_controller.dart';
import 'package:safehome/utils/api_handler.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../login/login_controller.dart';
import '../login/user_model.dart';
import '../utils/constants.dart';

class OtpPageVerification extends ConsumerWidget {
  static final GlobalKey<FormState> _key = GlobalKey();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  OtpPageVerification({Key? key}) : super(key: key);
  final Color primaryColor = const Color.fromARGB(255, 5, 77, 67);

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    UserModel loggedInUser = ref.watch(loginController).loggedUser;
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          key: scaffoldKey,
          body: Form(key: _key, child: _body(context, ref, loggedInUser)),
        ),
      ),
    );
  }

  _body(
    BuildContext context,
    WidgetRef ref,
    UserModel loggedInUser,
  ) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String enteredOtp = ref.watch(otpController).enteredOtp;
    String mobileNumber =
        ref.watch(loginController).loggedUser.mobileNumber ?? '';

    String modifiedNumber = "X" * 5 + mobileNumber.substring(5);

    return ConnectivityWidget(
        offlineBanner: const NoInternetConnectivityToast(),
        builder: (BuildContext context, bool isOnline) {
          return SingleChildScrollView(
            child: Stack(children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  waveImage,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                height: height,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Container(
                                width: double.infinity,
                                height: height / 12,
                                color: const Color.fromARGB(255, 54, 160, 57),
                                child: Image.asset(
                                  salzerLogo,
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: SizedBox(
                                width: width / 4,
                                height: height / 14,
                                child: Image.asset(
                                  homeGuardLogo,
                                  fit: BoxFit.fill,
                                )),
                          ),
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 40, 20, 10),
                              child: Text(
                                "Enter OTP send to your number",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            modifiedNumber,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                              child: PinCodeTextField(
                                length: 6,
                                obscureText: false,
                                animationType: AnimationType.fade,
                                keyboardType: TextInputType.number,
                                pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.box,
                                    borderRadius: BorderRadius.circular(5),
                                    fieldHeight: 50,
                                    fieldWidth: 40,
                                    activeFillColor: Colors.grey[200],
                                    inActiveBoxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    activeColor: Colors.grey,
                                    selectedFillColor: const Color.fromARGB(
                                        127, 158, 158, 158),
                                    selectedColor: const Color.fromARGB(
                                        127, 158, 158, 158),
                                    inactiveFillColor: Colors.white,
                                    inactiveColor: Colors.grey),
                                animationDuration:
                                    const Duration(milliseconds: 300),
                                enableActiveFill: true,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                ],
                                autoDisposeControllers: false,
                                onChanged: (value) {
                                  ref.read(otpController).otpFieldUpdate(value);
                                },
                                beforeTextPaste: (text) {
                                  return true;
                                },
                                appContext: context,
                              )),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: SizedBox(
                              height: height / 17,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(primaryColor),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0))),
                                ),
                                child: const Text(
                                  "Verify",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                onPressed: () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  if (enteredOtp.isNotEmpty) {
                                    setLoaderMessage(
                                        context, ref, validatingOtp);
                                    ref
                                        .read(otpController)
                                        .loginWithOtp()
                                        .then((value) async {
                                      if (value == 200) {
                                        dynamic loginResponse = await ref
                                            .read(loginController)
                                            .login(ref);
                                        if (context.mounted &&
                                            loginResponse != null) {
                                          startRemainderTasks();
                                          dynamic deviceResponse = await ref
                                              .read(deviceController)
                                              .getSystemDetails(context, ref,
                                                  loggedInUser.customerId!);
                                          if (deviceResponse ==
                                              'primaryUserLogin') {
                                            if (context.mounted) {
                                              await ref
                                                  .read(deviceController)
                                                  .initialize(context, ref)
                                                  .then((value) => Navigator.of(
                                                          context)
                                                      .pushNamedAndRemoveUntil(
                                                          homeRoute,
                                                          (route) => false));
                                            }
                                          } else if (deviceResponse ==
                                              'secondaryUserLogin') {
                                            ref
                                                .read(deviceController)
                                                .toggleFab(false);
                                            if (context.mounted) {
                                              Navigator.of(context).pushNamed(
                                                  primaryNotificationsRoute);
                                            }
                                            ref
                                                .read(notificationController)
                                                .setCurrentTab(1);
                                            if (context.mounted) {
                                              Navigator.of(context)
                                                  .pushNamedAndRemoveUntil(
                                                      notificationsRoute,
                                                      (route) => false);
                                            }
                                          } else {
                                            if (context.mounted) {
                                              cleanLoaderMessage(context, ref);
                                            }
                                          }
                                        } else {
                                          if (context.mounted) {
                                            cleanLoaderMessage(context, ref);
                                          }
                                        }
                                      } else {
                                        if (context.mounted) {
                                          cleanLoaderMessage(context, ref);
                                        }
                                        showToast(invalidOtpMessage);
                                      }
                                    });
                                  } else {
                                    showToast(otpRequired);
                                  }
                                },
                              ),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (ref.watch(otpController).showResendOtp)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Text(
                                          "Resend OTP in 00:${ref.watch(otpController).secondsLeft} seconds"),
                                    ),
                                  if (!ref.watch(otpController).showResendOtp)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Text("Don't receive a OTP ?"),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: (!ref
                                            .watch(otpController)
                                            .showResendOtp)
                                        ? GestureDetector(
                                            onTap: () {
                                              ref
                                                  .read(otpController)
                                                  .resendSMS(context);
                                            },
                                            child: const Text(
                                              'Resend OTP',
                                              style: TextStyle(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ]),
              ),
            ]),
          );
        });
  }
}
