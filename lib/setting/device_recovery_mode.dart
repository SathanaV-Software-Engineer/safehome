import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/login/user_model.dart';
import 'package:safehome/setting/settings_controller.dart';

import '../utils/constants.dart';

class DeviceRecoveryMode extends ConsumerWidget {
  static final GlobalKey<FormState> _key = GlobalKey();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  DeviceRecoveryMode({Key? key}) : super(key: key);
  final Color primaryColor = const Color.fromARGB(255, 5, 77, 67);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        body: Form(key: _key, child: _body(context, ref)),
      ),
    );
  }

  _body(
    BuildContext context,
    WidgetRef ref,
  ) {
    double height = MediaQuery.of(context).size.height;
    String? gatewayID = ref.watch(deviceController).currentGwDevice.uid;
    UserModel loggedInUser = ref.watch(loginController).loggedUser;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(
          height: 50,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Welcome to Device Recovery Mode",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        Padding(
          padding:
              const EdgeInsets.only(top: 10.0, bottom: 10, right: 20, left: 20),
          child: Text(
            step1,
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(top: 10.0, bottom: 10, right: 20, left: 20),
          child: Text(
            step2,
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(top: 10.0, bottom: 10, right: 20, left: 20),
          child: Text(
            step3,
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(top: 10.0, bottom: 10, right: 20, left: 20),
          child: Text(
            step4,
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(top: 10.0, bottom: 10, right: 20, left: 20),
          child: Text(
            step5,
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 14,
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
          child: SizedBox(
            height: height / 17,
            width: double.infinity,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(primaryColor),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0))),
              ),
              child: const Text(
                "Start Device Recovery Mode",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                ref.read(settingsController).startDeviceRecoveryMode(
                    context, ref, gatewayID, loggedInUser.customerId);
              },
            ),
          ),
        ),
      ],
    );
  }
}
