import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/login/user_model.dart';

final editProfileController =
    ChangeNotifierProvider<EditProfileProvider>((ref) => EditProfileProvider());

class EditProfileProvider extends ChangeNotifier {
  final UserModel _userDetails =
      UserModel(profileName: '', mobileNumber: '', email: '');
  bool _enableButton = false;
  textFieldUpdate(UserModel loggedUser, field, value) {
    if (field == 'mobileNumber') {
      _userDetails.mobileNumber = value;
    } else if (field == 'email') {
      _userDetails.email = value;
    } else if (field == 'profileName') {
      _userDetails.profileName = value;
    }
    if (_userDetails.profileName != loggedUser.profileName ||
        _userDetails.email != loggedUser.email ||
        _userDetails.mobileNumber != loggedUser.mobileNumber) {
      _enableButton = true;
    } else {
      _enableButton = false;
    }
    notifyListeners();
  }

  setEnableButton(value) {
    _enableButton = false;
    notifyListeners();
  }

  setInitialUserDetails(UserModel loggedUser) {
    _userDetails.profileName = loggedUser.profileName ?? '';
    _userDetails.email = loggedUser.email ?? '';
    _userDetails.mobileNumber = loggedUser.mobileNumber ?? '';
    _enableButton = false;
  }

  UserModel get userDetails => _userDetails;
  bool get enableButton => _enableButton;
}
