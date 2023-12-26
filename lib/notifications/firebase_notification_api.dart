import 'dart:developer';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safehome/firebase_options.dart';
import 'package:safehome/utils/api_handler.dart';
import 'package:safehome/utils/common_utils.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'notification_model.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
  sound: RawResourceAndroidNotificationSound('siren'),
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void showNotification(
    {required String title,
    required String body,
    required String messageId,
    required String gwId,
    required String gwName,
    required String gwLabel,
    required String deviceName,
    required String deviceLabel,
    required String profileName,
    required String alert,
    required String type,
    required String time}) {
  log('time $time');
  if (time.length < 12) {
    time = '0$time';
  }
  // DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
  // String formattedDate = DateFormat('MM/dd/yyyy HH.mm.ss').format(dateTime);
  int hour = int.parse(time.substring(0, 2));
  int minute = int.parse(time.substring(2, 4));
  int second = int.parse(time.substring(4, 6));
  int day = int.parse(time.substring(6, 8));
  int month = int.parse(time.substring(8, 10));
  int year = int.parse(time.substring(10, 12));

  DateTime dateTime = DateTime(year + 2000, month, day, hour, minute, second);

  String formattedDate = DateFormat('dd/MM/yy h:mm a').format(dateTime);
  log('Formatted Date: $formattedDate');
  storeNotificationtoLocaldb(NotificationModel(
    id: messageId,
    title: title,
    body: body,
    gwName: gwName,
    gwLabel: gwLabel,
    gwId: gwId,
    deviceName: deviceName,
    deviceLabel: deviceLabel,
    deviceType: type,
    profileName: profileName,
    alert: alert,
    isRead: false,
    timestamp: formattedDate,
  ));

  flutterLocalNotificationsPlugin.show(
    messageId.hashCode,
    '$body - $deviceLabel',
    title,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        groupKey: 'GROUP1',
        groupAlertBehavior: GroupAlertBehavior.all,
        color: Colors.blue,
        importance: Importance.max,
        setAsGroupSummary: true,
        additionalFlags: Int32List.fromList(<int>[4]),
        styleInformation: const DefaultStyleInformation(true, true),
        sound: const RawResourceAndroidNotificationSound('siren'),
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );
}

Future<void> storeNotificationtoLocaldb(NotificationModel notification) async {
  final notificationsDb = Hive.box('notifications');
  final notifications = notificationsDb.get("NOTIFICATIONS") ?? [];
  notifications.insert(
    0,
    {
      'id': notification.id,
      'title': notification.title,
      'body': notification.body,
      'gwName': notification.gwName,
      'deviceName': notification.deviceName,
      'deviceType': notification.deviceType,
      'isRead': false,
      'timestamp': notification.timestamp,
    },
  );
  notificationsDb.put("NOTIFICATIONS", notifications);
  log(notification.toString());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  log('A bg message just showed up : ${message.data}');
  if (message.data.isNotEmpty) {
    showNotification(
        body: message.data['body'] ?? '',
        title: message.data['title'] ?? '',
        messageId: message.messageId ?? '',
        gwId: message.data['gwId'] ?? '',
        gwName: message.data['gwName'] ?? '',
        gwLabel: message.data['gwLabel'] ?? '',
        deviceLabel: message.data['deviceLabel'] ?? '',
        deviceName: message.data['deviceName'] ?? '',
        type: message.data['type'] ?? '',
        alert: message.data['alert'] ?? '',
        profileName: message.data['profileName'] ?? '',
        time: message.data['time'] ?? '14052101101');
  }
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('notifications');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    log('Background task executed at ${DateTime.now()}');

    await displayGroupedNotification();
    return Future.value(true);
  });
}

displayGroupedNotification() async {
  const String groupKey = 'com.android.example.WORK_EMAIL';
  const String groupChannelId = 'grouped channel id';
  const String groupChannelName = 'grouped channel name';
  const String groupChannelDescription = 'grouped channel description';

  await Hive.initFlutter();
  await Hive.openBox('notifications');
  final notificationsDb = Hive.box('notifications');
  List notifications = notificationsDb.get("NOTIFICATIONS") ?? [];
  List notificationList =
      notifications.where((e) => e['isRead'] == false).toList();

  log('list count ${notificationList.length}');
  if (notificationList.isEmpty) {
    flutterLocalNotificationsPlugin.show(
      3,
      'Reminder',
      'Your space is secured with Home Guard',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder',
          'reminderIfEmptyNotifications',
          channelDescription: channel.description,
          groupAlertBehavior: GroupAlertBehavior.all,
          color: Colors.blue,
          importance: Importance.max,
          setAsGroupSummary: true,
          styleInformation: const DefaultStyleInformation(true, true),
          sound: const RawResourceAndroidNotificationSound('siren'),
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  } else {
    for (int i = 0; i < notificationList.length; i++) {
      log("${notificationList[i]['title']}");
      await flutterLocalNotificationsPlugin.show(
        i + 1,
        notificationList[i]['body'],
        notificationList[i]['title'],
        const NotificationDetails(
          android: AndroidNotificationDetails(
            groupChannelId,
            groupChannelName,
            channelDescription: groupChannelDescription,
            color: Colors.blue,
            showWhen: false,
            importance: Importance.max,
            groupKey: groupKey,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
    await flutterLocalNotificationsPlugin.show(
      3,
      'Reminder',
      '${notificationList.length} unread messages',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          groupChannelId,
          groupChannelName,
          channelDescription: groupChannelDescription,
          color: Colors.blue,
          importance: Importance.max,
          // styleInformation: inboxStyleInformation,
          groupKey: groupKey,
          setAsGroupSummary: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

Future<void> initializeFirebaseMessaging() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  displayGroupedNotification();
  NotificationSettings settings = await firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    showToast('granted');
    log('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    log('User granted provisional permission');
    showToast('granted 2');
  } else {
    showToast('You will not receive notifications from this app');
  }
  final fcmToken = await firebaseMessaging.getToken();
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('fcmId', fcmToken ?? "");
  log("FCMToken: $fcmToken");
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('test $message');
    if (message.data.isNotEmpty) {
      showNotification(
          body: message.data['body'] ?? '',
          title: message.data['title'] ?? '',
          messageId: message.messageId ?? '',
          gwId: message.data['gwId'] ?? '',
          gwName: message.data['gwName'] ?? '',
          gwLabel: message.data['gwLabel'] ?? '',
          deviceLabel: message.data['deviceLabel'] ?? '',
          deviceName: message.data['deviceName'] ?? '',
          type: message.data['type'] ?? '',
          alert: message.data['alert'] ?? '',
          profileName: message.data['profileName'] ?? '',
          time: message.data['time'] ?? '14052101101');
    }
  });
}

void cleanRemainderTasks() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('isAlarmSet', 'false');
  Workmanager().cancelAll();
}

void startRemainderTasks() async {
  final prefs = await SharedPreferences.getInstance();
  final isAlarmSet = prefs.getString('isAlarmSet') ?? 'false';
  if (!convertStringToBool(isAlarmSet)) {
    prefs.setString('isAlarmSet', 'true');
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    await Workmanager().registerPeriodicTask(
      "periodicTask",
      "homeGuardRemainder",
      // initialDelay: const Duration(minutes: 15),
      frequency: const Duration(minutes: 15),
    );
  }
}

void initializeLocalNotifications() async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

void setForegroundNotificationOptions() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}
