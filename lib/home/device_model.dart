import 'package:safehome/home/sensor_model.dart';

class DeviceDetails {
  String name;
  String customer;
  String label;
  String uid;
  String devIndex;
  String type;
  String state;
  String batteryStatus;
  String devIndexValue;
  Map<String, Map<String, int>> profileSetting;
  List<SensorDetails> sensors;

  DeviceDetails({
    required this.name,
    required this.customer,
    required this.label,
    required this.uid,
    required this.devIndex,
    required this.type,
    required this.state,
    required this.batteryStatus,
    required this.devIndexValue,
    required this.profileSetting,
    required this.sensors,
  });

  factory DeviceDetails.fromJson(Map<String, dynamic> json) {
    var profileSettingMap = json['profile_setting'];
    Map<String, Map<String, int>> profileSetting = {};

    if (profileSettingMap != null && profileSettingMap is Map) {
      profileSettingMap.forEach((key, value) {
        if (value is Map) {
          profileSetting[key] =
              Map<String, int>.from(value['rpc_request_json']);
        }
      });
    }

    var sensorsList = json['sensors'] as List;
    List<SensorDetails> sensors = sensorsList
        .map((sensorJson) => SensorDetails.fromJson(sensorJson))
        .toList();

    return DeviceDetails(
      name: json['name'],
      customer: json['customer'],
      label: json['label'],
      uid: json['uid'],
      devIndex: json['devIndex'],
      type: json['type'],
      state: json['state'],
      batteryStatus: json['batteryStatus'],
      devIndexValue: json['devIndexValue'],
      profileSetting: profileSetting,
      sensors: sensors,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> profileSettingJson = {};
    profileSetting.forEach((key, value) {
      profileSettingJson[key] = {'rpc_request_json': value};
    });

    List<Map<String, dynamic>> sensorsJson =
        sensors.map((sensor) => sensor.toJson()).toList();

    return {
      'name': name,
      'customer': customer,
      'label': label,
      'uid': uid,
      'devIndex': devIndex,
      'type': type,
      'state': state,
      'batteryStatus': batteryStatus,
      'devIndexValue': devIndexValue,
      'profile_setting': profileSettingJson,
      'sensors': sensorsJson,
    };
  }
}
