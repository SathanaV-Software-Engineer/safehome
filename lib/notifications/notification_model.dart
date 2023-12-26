class NotificationModel {
  String id;
  String title;
  String body;
  String gwName;
  String gwLabel;
  String gwId;
  String deviceName;
  String deviceLabel;
  String deviceType;
  String profileName;
  String alert;
  bool isRead;
  String timestamp;

  NotificationModel(
      {required this.id,
      required this.title,
      required this.body,
      required this.gwName,
      required this.deviceName,
      required this.deviceType,
      required this.isRead,
      required this.timestamp,
      required this.alert,
      required this.profileName,
      required this.gwId,
      required this.gwLabel,
      required this.deviceLabel});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'gwName': gwName,
      'gwLabel': gwLabel,
      'gwId': gwId,
      'profileName': profileName,
      'alert': alert,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'deviceLabel': deviceLabel,
      'isRead': isRead ? 1 : 0,
      'timestamp': timestamp,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      gwName: map['gwName'],
      gwLabel: map['gwLabel'],
      gwId: map['gwId'],
      profileName: map['profileName'],
      alert: map['alert'],
      deviceName: map['deviceName'],
      deviceLabel: map['deviceLabel'],
      deviceType: map['deviceType'],
      isRead: map['isRead'] == 1,
      timestamp: map['timestamp'],
    );
  }
}
