import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/no_internet_pages/no_internet_page.dart';
import 'package:safehome/otp/otp_controller.dart';
import 'package:safehome/utils/constants.dart';
import 'package:safehome/utils/dialog_boxes.dart';
import '../home/gw_scan_response.dart';
import '../login/login_controller.dart';
import '../login/user_model.dart';

class OTPPage extends ConsumerWidget {
  static final GlobalKey<FormState> _key = GlobalKey();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  OTPPage({Key? key}) : super(key: key);
  final Color primaryColor = const Color.fromARGB(255, 5, 77, 67);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel loginUser = ref.watch(loginController).loggedUser;
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Scaffold(
            key: scaffoldKey,
            body: Form(key: _key, child: _body(context, ref, loginUser)),
          ),
        ),
      ),
    );
  }

  _body(
    BuildContext context,
    WidgetRef ref,
    UserModel loginUser,
  ) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    bool isRegister = ref.watch(otpController).isRegisterScreen;
    GatewayQRResponse currentGwDevice =
        ref.watch(deviceController).currentGwDevice;
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
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isRegister)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(40, 50, 20, 0),
                            child: Text(
                              "We will send you a One Time Password on your Phone Number",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 30.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _mobileNumber(context, ref, loginUser),
                      ),
                      if (isRegister) const SizedBox(height: 15.0),
                      if (isRegister)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _profileName(context, ref, loginUser),
                        ),
                      if (isRegister)
                        Column(
                          children: [
                            const SizedBox(height: 15.0),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _emailfield(context, ref, loginUser),
                            ),
                          ],
                        ),
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (_key.currentState!.validate()) {
                            _key.currentState!.save();
                            if (isRegister) {
                              ref.read(otpController).getOtpForNewUSer(
                                  context, ref, loginUser, currentGwDevice);
                            } else {
                              ref
                                  .read(otpController)
                                  .getOtpForOldUser(context, ref, loginUser);
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
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
                                        'Send OTP',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.verified_user_sharp,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                ],
                              )),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isRegister)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text("Already own a space ?"),
                        ),
                      if (!isRegister)
                        const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text("Don't have a space yet? ")),
                      if (isRegister)
                        GestureDetector(
                          onTap: () async {
                            ref.read(loginController).cleanData();
                            ref.read(deviceController).removeGatewayFromStore();
                            ref.read(otpController).updateisRegister(false);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
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
                                          'Login',
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
                      if (!isRegister)
                        GestureDetector(
                          onTap: () {
                            ref.read(loginController).cleanData();
                            ref.read(deviceController).removeGatewayFromStore();
                            ref
                                .read(loginController)
                                .textFieldUpdate('mobileNumber', '');
                            isOnline
                                ? ref
                                    .read(loginController)
                                    .gatewayScan(ref, context)
                                : {};
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
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
                                          'Register',
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
                    ],
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }

  _mobileNumber(BuildContext context, WidgetRef ref, UserModel loginUser) {
    TextEditingController controller = TextEditingController();
    controller.text = ref.watch(loginController).loggedUser.mobileNumber ?? '';
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
    return TextFormField(
      maxLength: 13,
      cursorColor: Theme.of(context).primaryColor,
      onChanged: (value) {
        ref.read(loginController).textFieldUpdate('mobileNumber', value);
      },
      controller: controller,
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          hintText: 'Mobile Number',
          counterText: "",
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(
              Icons.call,
              size: 25,
              color: primaryColor,
            ),
          ),
          hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 15.0, color: const Color.fromARGB(248, 183, 184, 185)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: primaryColor)),
          filled: true,
          fillColor: Colors.white),
      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16.0),
      keyboardType: TextInputType.number,
    );
  }

  _emailfield(BuildContext context, WidgetRef ref, UserModel loginUser) {
    TextEditingController controller = TextEditingController();
    controller.text = ref.watch(loginController).loggedUser.email ?? '';
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
    return TextFormField(
      maxLength: 50,
      controller: controller,
      cursorColor: Theme.of(context).primaryColor,
      onChanged: (value) {
        ref.read(loginController).textFieldUpdate('email', value);
      },
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          hintText: 'Email (Optional)',
          counterText: "",
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(
              Icons.email_sharp,
              size: 25,
              color: primaryColor,
            ),
          ),
          hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 15.0, color: const Color.fromARGB(248, 183, 184, 185)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: primaryColor)),
          filled: true,
          fillColor: Colors.white),
      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16.0),
      keyboardType: TextInputType.emailAddress,
    );
  }

  _profileName(BuildContext context, WidgetRef ref, UserModel loggedInUser) {
    TextEditingController controller = TextEditingController();
    controller.text = ref.watch(loginController).loggedUser.profileName ?? '';
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
    return TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      onChanged: (value) {
        ref.read(loginController).textFieldUpdate('profileName', value);
      },
      controller: controller,
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          hintText: 'Profile Name',
          counterText: "",
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(
              Icons.person_2_rounded,
              size: 25,
              color: primaryColor,
            ),
          ),
          hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 15.0, color: const Color.fromARGB(248, 183, 184, 185)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: primaryColor)),
          filled: true,
          fillColor: Colors.white),
    );
  }
}
