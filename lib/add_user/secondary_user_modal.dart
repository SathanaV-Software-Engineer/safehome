class MobileNumberModal {
  String mobileNumber;
  bool isValid;
  bool isSaved = false;
  bool showError = false;
  String customerId = '';
  MobileNumberModal(
      {required this.mobileNumber,
      required this.isValid,
      required this.showError,
      required this.isSaved,
      required this.customerId});
}
