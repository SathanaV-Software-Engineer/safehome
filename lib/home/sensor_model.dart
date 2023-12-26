class SensorDetails {
  String id;
  String name;
  String label;
  String uid;
  String devIndex;
  String type;
  String state;
  String alert;
  String batteryStatus;
  String devIndexValue;

  SensorDetails({
    this.id = '',
    this.name = '',
    this.label = '',
    this.uid = '',
    this.devIndex = '',
    this.type = '',
    this.state = 'arm',
    this.alert = '',
    this.batteryStatus = '100',
    this.devIndexValue = '',
  });

  factory SensorDetails.fromJson(Map<String, dynamic> json) {
    return SensorDetails(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      label: json['label'] ?? '',
      uid: json['uid'] ?? '',
      devIndex: json['devIndex'] ?? '',
      type: json['type'] ?? '',
      state: json['state'] ?? 'arm',
      alert: json['alert'] ?? '',
      batteryStatus: json['batteryStatus'] ?? '100',
      devIndexValue: json['devIndexValue'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'label': label,
      'uid': uid,
      'devIndex': devIndex,
      'type': type,
      'state': state,
      'alert': alert,
      'batteryStatus': batteryStatus,
      'devIndexValue': devIndexValue,
    };
  }
}
