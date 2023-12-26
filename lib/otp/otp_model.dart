class OtpModel {
  int? otp;
  int? errorCode;

  OtpModel({this.otp, this.errorCode});

  OtpModel.fromJson(Map<String, dynamic> json) {
    otp = json['otp'];
    errorCode = json['error_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['otp'] = otp;
    data['error_code'] = errorCode;
    return data;
  }
}
