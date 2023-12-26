import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safehome/add_user/secondary_user_controller.dart';
import 'package:safehome/edit_profile_info/edit_profile_controller.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/setting/settings_controller.dart';

import 'constants.dart';

ValueNotifier<String> _nameNotifier = ValueNotifier<String>('');

showExitPopup(context) async {
  return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24.0))),
          insetPadding: const EdgeInsets.all(8.0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.80,
            height: MediaQuery.of(context).size.height / 11,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 200),
                const FittedBox(
                  child: Text(
                    softWrap: true,
                    'Do want exit the Home Guard Application?',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        exit(0);
                      },
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Text(
                        'No',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      });
}

showLoaderWithMessage(BuildContext context, String message) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24.0))),
            insetPadding: const EdgeInsets.all(8.0),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.80,
              height: MediaQuery.of(context).size.height / 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SpinKitRing(
                    lineWidth: 3,
                    color: Theme.of(context).primaryColor,
                    size: 35.0,
                  ),
                  const SizedBox(width: 20),
                  Wrap(children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 140,
                      child: Text(
                        message,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14),
                      ),
                    ),
                  ])
                ],
              ),
            ));
      });
}

getContent(BuildContext context, String value) {
  switch (value) {
    case 'factoryReset':
      return {
        "message": factoryReset,
        "action": (BuildContext context, WidgetRef ref, String gatewayId,
            sensorList) {
          ref
              .read(settingsController)
              .startFactoryReset(context, ref, gatewayId);
        }
      };
    case 'deleteDevice':
      return {
        "message": deleteDevice,
        "action": (BuildContext context, WidgetRef ref, String deviceId,
            String sensorName) {
          ref
              .read(deviceController)
              .removeDevice(context, ref, deviceId, sensorName);
        }
      };
    case 'changeSim':
      return {
        "message": changeSim,
        "action": (BuildContext context, WidgetRef ref, String deviceId,
            String sensorName) {
          ref.read(settingsController).updateUserInformation(
              context, ref, ref.read(editProfileController).userDetails, true);
        }
      };
    case 'logout':
      return {
        "message": logoutMessage,
        "action": (BuildContext context, WidgetRef ref, String? gatewayId,
            String? data) {
          ref.read(loginController).logout(context, ref, gatewayId ?? '');
        }
      };
    case 'deleteSecondaryUser':
      return {
        "message": deleteUserPopup,
        "action": (BuildContext context, WidgetRef ref, String customerId,
            String data) {
          ref
              .read(secondaryUserController)
              .deleteMobileNumber(context, ref, customerId);
        }
      };
    case 'armDevices':
      return {
        "message": armDevices,
        "action": (BuildContext context, WidgetRef ref, String customerId,
            String data) {
          ref.read(deviceController).changeProfile(context, ref, 'ARM').then(
              (value) => Navigator.of(context, rootNavigator: true).pop());
        }
      };
    case 'disarmDevices':
      return {
        "message": disarmDevices,
        "action": (BuildContext context, WidgetRef ref, String customerId,
            String data) {
          ref.read(deviceController).changeProfile(context, ref, 'DISARM').then(
              (value) => Navigator.of(context, rootNavigator: true).pop());
        }
      };
    default:
      return {"message": "", "action": () {}};
  }
}

scanQrExitPopup(context, ref) async {
  return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24.0))),
          insetPadding: const EdgeInsets.all(8.0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.80,
            height: MediaQuery.of(context).size.height / 7,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 200),
                const Text(
                  softWrap: true,
                  'You are about to go back without scanning a QR code. Are you sure you want to leave this page?',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        ref.read(loginController).gatewayScan(ref, context);
                      },
                      child: const Text(
                        'Stay',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Text(
                        'Leave',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      });
}

showCustomDialog(WidgetRef ref, BuildContext context, String value,
    dynamic deviceInfo, dynamic data) {
  dynamic content = getContent(context, value);
  dynamic action = content['action'];
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24.0))),
          insetPadding: const EdgeInsets.all(8.0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.80,
            height: MediaQuery.of(context).size.height / 11,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  content['message'],
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 170),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        action(context, ref, deviceInfo, data);
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      });
}

void showToastmsg(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

void showDeviceEditDialog(ref, context, device) {
  _nameNotifier.value = device.label;
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24.0))),
          insetPadding: const EdgeInsets.all(8.0),
          backgroundColor: Colors.white,
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.80,
            height: MediaQuery.of(context).size.height / 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: Text(
                    "Edit Device Information",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 30.0, right: 30, top: 5, bottom: 5),
                  child: Text(
                    textAlign: TextAlign.start,
                    'Device Label :',
                    style: TextStyle(
                        fontSize: 14, color: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _sensorName(context, device),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _sensorUid(context, device),
                ),
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _sensorType(context, device),
                ),
                const SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ValueListenableBuilder<String>(
                      valueListenable: _nameNotifier,
                      builder: (context, value, _) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height / 17,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  _nameNotifier.value != device.label
                                      ? MaterialStateProperty.all(
                                          Theme.of(context).primaryColor)
                                      : MaterialStateProperty.all(Colors.grey),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0))),
                            ),
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () {
                              if (_nameNotifier.value != device.label) {
                                ref
                                    .read(deviceController)
                                    .updateDeviceInformation(context, ref,
                                        device, _nameNotifier.value);
                              }
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        );
      });
}

_sensorName(
  context,
  device,
) {
  return TextFormField(
    initialValue: device.label.toString(),
    cursorColor: Theme.of(context).primaryColor,
    onChanged: (value) => _nameNotifier.value = value,
    decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
        contentPadding: const EdgeInsets.all(16.0),
        hintText: '',
        counterText: "",
        hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 15.0, color: const Color.fromARGB(248, 183, 184, 185)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor)),
        filled: true,
        fillColor: Colors.white),
    style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16.0),
    keyboardType: TextInputType.text,
  );
}

_sensorUid(
  context,
  device,
) {
  return TextFormField(
    enabled: false,
    initialValue: ' UID : ${device.uid.toString()}',
    cursorColor: Theme.of(context).primaryColor,
    decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
        contentPadding: const EdgeInsets.all(16.0),
        hintText: '',
        counterText: "",
        hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 15.0, color: const Color.fromARGB(248, 183, 184, 185)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor)),
        filled: true,
        fillColor: Colors.white),
    style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16.0),
    keyboardType: TextInputType.text,
  );
}

_sensorType(
  context,
  device,
) {
  String iconPath = doorOpen;
  String deviceType = doorOpen;
  if (device.type == 'ds') {
    deviceType = 'Door Sensor';
    iconPath = doorOpen;
  } else if (device.type == 'rm') {
    deviceType = 'Remote Sensor';
    iconPath = remote;
  } else if (device.type == 'ms') {
    deviceType = 'Movement Sensor';
    iconPath = voice;
  }
  return TextFormField(
    enabled: false,
    initialValue: deviceType.toString(),
    cursorColor: Theme.of(context).primaryColor,
    decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
        contentPadding: const EdgeInsets.all(16.0),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Image.asset(
            iconPath,
            color: Theme.of(context).primaryColor,
            width: 16,
            height: 16,
          ),
        ),
        hintText: '',
        counterText: "",
        hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 15.0, color: const Color.fromARGB(248, 183, 184, 185)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor)),
        filled: true,
        fillColor: Colors.white),
    style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16.0),
    keyboardType: TextInputType.text,
  );
}
