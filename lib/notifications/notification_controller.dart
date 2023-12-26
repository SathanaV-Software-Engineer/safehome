import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safehome/notifications/primary_user_notification_page.dart';

final notificationController = ChangeNotifierProvider<NotificationProvider>(
    (ref) => NotificationProvider());

class NotificationProvider extends ChangeNotifier {
  final notificationsDb = Hive.box('notifications');
  List<dynamic> _notifications = [];
  String searchText = '';
  final TabController _tabController =
      TabController(length: 2, vsync: TickerProviderInstance());
  void updateSearchText(String value) {
    searchText = value;
    notifyListeners();
  }

  void setCurrentTab(index) {
    _tabController.index = index;
    notifyListeners();
  }

  getFilteredNotifications() {
    List<dynamic> notificationListFromDb =
        notificationsDb.get("NOTIFICATIONS") ?? [];
    List<dynamic> notificationsList = [];
    if (searchText != '') {
      notificationsList = notificationListFromDb
          .where((element) =>
              element['isRead'] == false &&
              (element['id'].toString().contains(searchText) ||
                  element['title']
                      .toLowerCase()
                      .contains(searchText.toLowerCase()) ||
                  element['body']
                      .toLowerCase()
                      .contains(searchText.toLowerCase()) ||
                  element['gwName']
                      .toLowerCase()
                      .contains(searchText.toLowerCase()) ||
                  element['deviceName']
                      .toLowerCase()
                      .contains(searchText.toLowerCase()) ||
                  element['deviceType']
                      .toLowerCase()
                      .contains(searchText.toLowerCase())))
          .toList();
    } else {
      notificationsList = notificationsDb.get("NOTIFICATIONS") ?? [];
    }
    return notificationsList;
  }

  void markNotificationAsRead(String notificationId) {
    //to update local notifications while removing
    dynamic filterNotificationsList =
        notificationsDb.get("NOTIFICATIONS") ?? [];
    int index = filterNotificationsList
        .indexWhere((element) => element['id'] == notificationId);
    if (index != -1) {
      filterNotificationsList[index]['isRead'] = true;
    }
    notificationsDb.put("NOTIFICATIONS", filterNotificationsList);
  }

  bool promptMessageForUser(userType, tab) {
    log('usertype=$userType tab=$tab');
    return userType == 'secondaryUserLogin' && tab == 0;
  }

  void loadData() {
    _notifications = notificationsDb.get("NOTIFICATIONS") ?? [];
    notifyListeners();
  }

  void updateDataBase() {
    notificationsDb.put("NOTIFICATIONS", _notifications);
    notifyListeners();
  }

  List<dynamic> get notifications => _notifications;
  TabController get tabController => _tabController;
}
