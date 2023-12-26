import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/add_user/secondary_user_controller.dart';
import 'package:safehome/add_user/secondary_user_modal.dart';
import 'package:safehome/edit_profile_info/edit_profile_controller.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/home/gw_scan_response.dart';
import 'package:safehome/home/loader_contoller.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/login/user_model.dart';
import 'package:safehome/setting/settings_service.dart';
import 'package:safehome/utils/api_handler.dart';
import 'package:safehome/utils/common_utils.dart';
import 'package:safehome/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsController =
    ChangeNotifierProvider<SettingsProvider>((ref) => SettingsProvider());
final _settingsService = SettingsService();

class SettingsProvider extends ChangeNotifier {
  String _newMobileNumber = '';
  void updateMobileNumber(value) {
    _newMobileNumber = value;
    notifyListeners();
  }

  void startDeviceRecoveryMode(BuildContext context, WidgetRef ref,
      String? gatewayId, String? customerId) async {
    setLoaderMessage(context, ref, recoveryMode);
    try {
      Response response =
          await _settingsService.callRecoveryMode(gatewayId, customerId);
      if (response.statusCode == 200) {
        showToast('Recovery mode is done', 'success');
      }
    } catch (e) {
      log('error $e');
      showToast(getErrorMessageFromException(e));
    } finally {
      if (context.mounted) cleanLoaderMessage(context, ref);
    }
  }

  void startFactoryReset(
    BuildContext context,
    WidgetRef ref,
    String? gatewayId,
  ) async {
    setLoaderMessage(context, ref, deviceReset);
    String customerId = ref.read(loginController).loggedUser.customerId ?? '';
    try {
      Response response =
          await _settingsService.callFactoryReset(gatewayId, customerId);
      if (response.statusCode == 200) {
        showToast('Factory Reset is done', 'success');
        if (context.mounted) {
          ref.read(loginController).logout(context, ref, gatewayId);
        }
      }
    } catch (e) {
      showToast(getErrorMessageFromException(e));
    } finally {
      if (context.mounted) {
        cleanLoaderMessage(context, ref);
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  isValidNewSimNumber(UserModel loggedUser) {
    if (!isValidNumber(_newMobileNumber)) {
      showToast(provideValidNumber);
      return false;
    }
    if (_newMobileNumber == loggedUser.mobileNumber) {
      showToast(numberAlreadyUsed);
      return false;
    }
    return true;
  }

  updateUser(BuildContext context, WidgetRef ref, UserModel loggedUser,
      String updateIsFor, String value) async {
    String? name = loggedUser.profileName;
    String? email = loggedUser.email;
    String? mobileNumber = loggedUser.mobileNumber;
    if (updateIsFor == 'mobileNumber') {
      mobileNumber = _newMobileNumber;
      value = _newMobileNumber;
      if (!isValidNewSimNumber(loggedUser)) {
        return;
      }
    } else if (updateIsFor == 'name') {
      name = value;
    } else if (updateIsFor == 'email') {
      email = value;
    }
    setLoaderMessage(context, ref, changeSimNumber);
    try {
      Response response = await _settingsService.callUpdateUser(
          loggedUser, name, mobileNumber, email);
      if (response.statusCode == 200) {
        ref.read(loginController).textFieldUpdate(updateIsFor, value);
        showToast('Profile updated Successfully', 'success');
      }
    } catch (e) {
      showToast(getErrorMessageFromException(e));
    } finally {
      if (context.mounted) cleanLoaderMessage(context, ref);
      _newMobileNumber = '';
    }
  }

  updateUserInformation(BuildContext context, WidgetRef ref,
      UserModel userDetails, isFromPopUp) async {
    GatewayQRResponse currentGwDevice =
        ref.read(deviceController).currentGwDevice;
    if (userDetails.mobileNumber!.isEmpty ||
        !isValidNumber(userDetails.mobileNumber!)) {
      showToast(provideValidNumber);
      return;
    }
    if (isFromPopUp) {
      List<MobileNumberModal> seondaryUsers = await ref
          .read(secondaryUserController)
          .fetchSecondaryUsers(context, ref, currentGwDevice.uid);
      List mobileNumbers = seondaryUsers.map((e) => e.mobileNumber).toList();
      if (mobileNumbers.contains(userDetails.mobileNumber)) {
        showToast(
            'Number is already added as secondary user. Try removing and adding');
        return;
      }
    }
    if (userDetails.profileName!.isEmpty) {
      showToast('Invalid name');
      return;
    }
    if (userDetails.email!.isNotEmpty && !isEmailValid(userDetails.email!)) {
      showToast('Invalid email');
      return;
    }
    setLoaderMessage(context, ref, 'Updating user details');
    try {
      Response response = await _settingsService.callUpdateUser(
          ref.read(loginController).loggedUser,
          userDetails.profileName,
          userDetails.mobileNumber,
          userDetails.email);
      if (response.statusCode == 200) {
        UserModel loggedUser = ref.read(loginController).loggedUser;
        ref
            .read(loginController)
            .textFieldUpdate('mobileNumber', userDetails.mobileNumber);
        ref.read(loginController).textFieldUpdate('email', userDetails.email);
        ref
            .read(loginController)
            .textFieldUpdate('profileName', userDetails.profileName);
        ref.read(editProfileController).setEnableButton(false);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'userDetails',
            jsonEncode({
              'userId': loggedUser.userId,
              'customerId': loggedUser.customerId,
              'name': userDetails.profileName,
              'email': userDetails.email,
              'mobileNumber': userDetails.mobileNumber
            }));
        showToast('Profile updated Successfully', 'success');
        return 200;
      }
    } catch (e) {
      showToast(getErrorMessageFromException(e));
      return 500;
    } finally {
      if (context.mounted) {
        cleanLoaderMessage(context, ref);
        if (isFromPopUp) Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  String get newMobileNumber => _newMobileNumber;
}
