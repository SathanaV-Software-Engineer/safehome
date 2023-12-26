import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/no_internet_pages/no_internet_page.dart';
import 'package:safehome/otp/otp_controller.dart';
import '../utils/constants.dart';
import '../utils/dialog_boxes.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: SafeArea(
        child: Scaffold(
          body: ConnectivityWidget(
            offlineBanner: const NoInternetConnectivityToast(),
            builder: (BuildContext context, bool isOnline) {
              return SizedBox(
                height: height,
                child: Column(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        ref.read(otpController).updateisRegister(true);
                        isOnline
                            ? ref
                                .read(loginController)
                                .gatewayScan(ref, context)
                            : {};
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20)),
                            height: height / 17,
                            width: width,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: width / 1.3,
                                  child: const Center(
                                    child: Text(
                                      'Scan QR Code',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.qr_code_scanner_sharp,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                              ],
                            )),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                            decoration: BoxDecoration(
                                color: isOnline
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(20)),
                            height: height / 17,
                            width: width,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: width / 1.3,
                                  child: const Center(
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.person_2_sharp,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                              ],
                            )),
                      ),
                      onTap: () {
                        ref.read(otpController).updateisRegister(false);
                        //find user api call is in otpcontroller file
                        isOnline
                            ? Navigator.of(context).pushNamed(otpRoute)
                            : {};
                      },
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              );
              // : ScanOrLoginPageWithNoInternet(height: height, width: width);
            },
          ),
        ),
      ),
    );
  }
}
