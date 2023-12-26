String? validateMobile(String? value) {
  if (value!.isEmpty) {
    return 'Please enter mobile number';
  } else if (!isValidNumber(value)) {
    return 'Please enter valid mobile number';
  }
  return null;
}

bool convertStringToBool(String value) {
  return value.toLowerCase() == 'true';
}

bool isValidNumber(String mobileNumber) {
  String numericOnly = mobileNumber.replaceAll(RegExp(r'[^0-9]'), '');
  if (numericOnly.length == 10) {
    return !RegExp(r'^0+$').hasMatch(numericOnly);
  }
  return false;
}

bool isEmailValid(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

String removeCountryCode(String phoneNumber) {
  RegExp regex = RegExp(r'^\+(\d+)\s');
  return phoneNumber.replaceAll(regex, '');
}

String removeSpaces(String value) {
  return value.replaceAll(' ', '');
}

String? getFirstLetter(String input) {
  RegExp regex = RegExp(r'[a-zA-Z]');
  Match? match = regex.firstMatch(input);
  if (match != null) {
    return match.group(0);
  } else {
    return null;
  }
}
