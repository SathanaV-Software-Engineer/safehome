class GatewayQRResponse {
  String? uid;
  String? name;
  String? type;
  String? label;
  GatewayQRResponse({this.uid, this.name, this.type, this.label});

  GatewayQRResponse.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    type = json['type'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['name'] = name;
    data['type'] = type;
    data['label'] = label;
    return data;
  }
}
