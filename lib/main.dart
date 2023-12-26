import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safehome/notifications/firebase_notification_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hgss_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('notifications');
  await initializeApp();
  await initializeFirebaseMessaging();
  initializeLocalNotifications();
  setForegroundNotificationOptions();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) {
      runApp(
        ProviderScope(
          child: HgssApp(),
        ),
      );
    },
  );
}
