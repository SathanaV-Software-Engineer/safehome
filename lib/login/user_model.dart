class UserModel {
  String? profileName;
  String? mobileNumber;
  String? email;
  String? userId;
  String? customerId;
  String? label;
  String? password;
  String? userType;
  bool? active;
  String? token;
  String? refreshToken;
  String? createdBy;
  String? createdDate;
  String? updatedBy;
  String? updatedDate;

  UserModel(
      {this.profileName,
      this.mobileNumber,
      this.email,
      this.userId,
      this.customerId,
      this.label,
      this.password,
      this.userType,
      this.active,
      this.token,
      this.refreshToken,
      this.createdBy,
      this.createdDate,
      this.updatedBy,
      this.updatedDate});

  UserModel.fromJson(Map<String, dynamic> json) {
    profileName = json['profileName'].toString();
    mobileNumber = json['mobileNumber'].toString();
    email = json['email'].toString();
    userId = json['userId'].toString();
    customerId = json['customerId'].toString();
    label = json['label'].toString();
    password = json['password'].toString();
    userType = json['userType'];
    active = json['active'];
    token = json['token'];
    refreshToken = json['refreshToken'];
    createdBy = json['createdBy'];
    createdDate = json['createdDate'];
    updatedBy = json['updatedBy'];
    updatedDate = json['updatedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['profileName'] = profileName;
    data['mobileNumber'] = mobileNumber;
    data['email'] = email;
    data['userId'] = userId;
    data['customerId'] = customerId;
    data['label'] = label;
    data['password'] = password;
    data['userType'] = userType;
    data['active'] = active;
    data['token'] = token;
    data['refreshToken'] = refreshToken;
    data['createdBy'] = createdBy;
    data['createdDate'] = createdDate;
    data['updatedBy'] = updatedBy;
    data['updatedDate'] = updatedDate;
    return data;
  }
}
