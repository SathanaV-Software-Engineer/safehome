import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/add_user/secondary_user_modal.dart';
import 'package:safehome/add_user/secondary_user_service.dart';
import 'package:safehome/home/loader_contoller.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/utils/api_handler.dart';
import 'package:safehome/utils/common_utils.dart';
import 'package:safehome/utils/constants.dart';

final secondaryUserController = ChangeNotifierProvider<SecondaryUserController>(
    (ref) => SecondaryUserController());

class SecondaryUserController extends ChangeNotifier {
  List<MobileNumberModal> _mobileList = [];
  String? _gatewayId = '';
  Timer? timer;
  fetchSecondaryUsers(
      BuildContext context, WidgetRef ref, String? gatewayId) async {
    SecondaryUserService secondaryUserService =
        SecondaryUserService(context, ref);
    _mobileList = [];
    _gatewayId = gatewayId;
    setLoaderMessage(context, ref, fetchingSecondaryUsers);
    try {
      dynamic response =
          await secondaryUserService.getSecondaryUsers(gatewayId);
      if (response.statusCode == 200) {
        List data = response.data['data'];
        _mobileList.clear();
        String number = '';
        String customerId = '';
        for (var item in data) {
          number = item["latest"]["ENTITY_FIELD"]["label"]["value"];
          customerId = item["entityId"]["id"];
          _mobileList.add(
            MobileNumberModal(
                mobileNumber: number,
                isValid: true,
                showError: false,
                isSaved: true,
                customerId: customerId),
          );
        }

        for (int i = data.length; i < maxSecondaryUsers; i++) {
          _mobileList.add(
            MobileNumberModal(
                mobileNumber: '',
                isValid: false,
                showError: false,
                isSaved: false,
                customerId: ''),
          );
        }
        notifyListeners();
        return _mobileList;
      }
    } catch (error) {
      getErrorMessageFromException(error);
    } finally {
      if (context.mounted) cleanLoaderMessage(context, ref);
    }
  }

  void saveMobileNumber(BuildContext context, WidgetRef ref, int index) async {
    setLoaderMessage(context, ref, updateSecodaryUser);
    SecondaryUserService secondaryUserService =
        SecondaryUserService(context, ref);
    String mobileNumber = _mobileList[index].mobileNumber;
    String? primaryNumber = ref.read(loginController).loggedUser.mobileNumber;
    if (mobileNumber == primaryNumber) {
      showToast(provideValidNumber);
      return;
    }

    if (_mobileList.any((element) =>
        _mobileList.indexOf(element) != index &&
        element.mobileNumber == mobileNumber)) {
      showToast(provideValidNumber);
      return;
    }
    try {
      dynamic response = await secondaryUserService
          .updateSecondaryUsers(_gatewayId, [mobileNumber]);
      if (response.statusCode == 200) {
        // if (response.data['failure'].length > 0) {
        //   showToast('Error while updating numbers');
        // } else {
        showToast('Added Successfully', 'success');
        if (context.mounted) fetchSecondaryUsers(context, ref, _gatewayId);
        // }
      }
    } catch (error) {
      showToast(getErrorMessageFromException(error));
    }
  }

  void deleteMobileNumber(
      BuildContext context, WidgetRef ref, String customerId) async {
    SecondaryUserService secondaryUserService =
        SecondaryUserService(context, ref);
    setLoaderMessage(context, ref, updateSecodaryUser);

    try {
      dynamic response = await secondaryUserService.removeCustomerRelation(
          _gatewayId, customerId);
      if (response.statusCode == 200) {
        showToast(deletedSecondaryUser, 'success');
        if (context.mounted) fetchSecondaryUsers(context, ref, _gatewayId);
      }
    } catch (error) {
      showToast(getErrorMessageFromException(error));
    } finally {
      if (context.mounted) {
        cleanLoaderMessage(context, ref);
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  void updateMobileList(int index, String value) {
    _mobileList[index].mobileNumber = value;
    _mobileList[index].showError = false;
    _mobileList[index].isValid = false;
    notifyListeners();
    timer?.cancel();
    if (value == '') {
      _mobileList[index].isValid = false;
      _mobileList[index].showError = false;
    } else {
      timer = Timer(const Duration(seconds: 1), () {
        _mobileList[index].showError = false;
        if (isValidNumber(value)) {
          _mobileList[index].isValid = true;
          _mobileList[index].showError = false;
        } else {
          _mobileList[index].isValid = false;
          _mobileList[index].showError = true;
        }

        notifyListeners();
      });
    }
  }

  List get mobileList => _mobileList;
}
