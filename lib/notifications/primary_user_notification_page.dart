import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safehome/home/custom_app_bar.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/login/user_model.dart';
import 'package:safehome/no_internet_pages/no_internet_page.dart';
import 'package:safehome/utils/dialog_boxes.dart';

import '../utils/constants.dart';
import 'notification_controller.dart';

class TickerProviderInstance extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}

class PrimaryUserNotification extends ConsumerWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  PrimaryUserNotification({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: ConnectivityWidget(
          offlineBanner: const NoInternetConnectivityToast(),
          builder: (BuildContext context, bool isOnline) {
            return Scaffold(
              key: scaffoldKey,
              appBar: CustomAppBar(height: 55, child: const HomeGuardAppBar()),
              body: _tabSwitch(context, ref),
            );
          }),
    );
  }
}

class SecondaryUserNotification extends ConsumerWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  SecondaryUserNotification({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          appBar: CustomAppBar(height: 55, child: const HomeGuardAppBar()),
          body: _tabSwitch(context, ref),
        ),
      ),
    );
  }
}

_tabSwitch(BuildContext context, WidgetRef ref) {
  TabController tabController = ref.watch(notificationController).tabController;
  String? gatewayId = ref.watch(deviceController).currentGwDevice.name;
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _searchField(context, ref),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(
                25.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: TabBar(
                controller: tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                  color: Theme.of(context).primaryColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: [
                  _tabHeader('My Notifications', gatewayId),
                  _tabHeader('Others', gatewayId)
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _contentToDisplay(context, ref, "own"),
              _contentToDisplay(context, ref, "others"),
            ],
          ),
        ),
      ],
    ),
  );
}

_searchField(BuildContext context, WidgetRef ref) {
  return SizedBox(
    height: 45,
    child: TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
          prefixIconColor: Theme.of(context).primaryColor,
          prefixIcon: const Icon(Icons.search),
          contentPadding: const EdgeInsets.all(8.0),
          hintText: 'Search',
          counterText: "",
          hintStyle: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontSize: 15.0, color: Theme.of(context).primaryColor),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: Theme.of(context).primaryColor)),
          filled: true,
          fillColor: Colors.white),
      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16.0),
      keyboardType: TextInputType.text,
      onChanged: (value) =>
          ref.read(notificationController).updateSearchText(value),
    ),
  );
}

Tab _tabHeader(String label, String? gatewayId) {
  return Tab(
    child: ValueListenableBuilder<Box>(
      valueListenable: Hive.box('notifications').listenable(),
      builder: (context, box, widget) {
        List<dynamic> notifications =
            box.get('NOTIFICATIONS', defaultValue: []);

        int notificationCount = notifications
            .where((e) =>
                e['isRead'] == false &&
                (label == 'My Notifications'
                    ? e['gwName'] == gatewayId
                    : e['gwName'] != gatewayId))
            .toList()
            .length;

        return Text(
          '$label ($notificationCount)',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
          ),
        );
      },
    ),
  );
}

_contentToDisplay(BuildContext context, WidgetRef ref, String currentTab) {
  TabController tabController = ref.watch(notificationController).tabController;
  UserModel loggedUser = ref.watch(loginController).loggedUser;
  List<dynamic> notificationList = [];
  String? gatewayId = ref.watch(deviceController).currentGwDevice.name;
  return SingleChildScrollView(
    child: ValueListenableBuilder<Box>(
      valueListenable: Hive.box('notifications').listenable(),
      builder: (context, box, widget) {
        notificationList = ref
            .read(notificationController)
            .getFilteredNotifications()
            .where((e) {
          if (currentTab == 'own') {
            return e['isRead'] == false && e['gwName'] == gatewayId;
          } else {
            return e['isRead'] == false && e['gwName'] != gatewayId;
          }
        }).toList();
        return notificationList.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  reverse: false,
                  itemCount: notificationList.length,
                  itemExtent: 100.0,
                  itemBuilder: (BuildContext context, int index) {
                    final notification = notificationList[index];
                    String iconPath = doorOpen;

                    if (notification['deviceType'] == 'ds') {
                      iconPath = doorOpen;
                    } else if (notification['deviceType'] == 'rm') {
                      iconPath = remote;
                    } else if (notification['deviceType'] == 'ms') {
                      iconPath = voice;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: <Widget>[
                          Dismissible(
                            key: UniqueKey(),
                            direction: DismissDirection.horizontal,
                            onDismissed: (direction) {
                              ref
                                  .read(notificationController)
                                  .markNotificationAsRead(notification['id']);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 9,
                              padding: const EdgeInsets.only(top: 5),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 217, 221, 219),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 1,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                notification['gwName'],
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 7, 56, 50),
                                                  fontSize: 17,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                notification['timestamp']
                                                    .toString(),
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 7, 56, 50),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Image.asset(
                                                iconPath,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 20,
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                notification['deviceName'],
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 7, 56, 50),
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                notification['body']
                                                    .toString()
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 179, 45, 45),
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            : Center(
                child: ref.read(notificationController).promptMessageForUser(
                        loggedUser.userType, tabController.index)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 130.0, bottom: 20),
                              child: Icon(
                                Icons.person_add_disabled_rounded,
                                size: 40,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 18,
                                ),
                                children: const [
                                  TextSpan(
                                    text:
                                        'You are not the primary user. Consider purchasing a security system.',
                                  ),
                                ],
                              ),
                            ),
                          ])
                    : Column(children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 130.0),
                          child: Image.asset(
                            emptyFolder,
                            color: Theme.of(context).primaryColor,
                            height: 100,
                            width: 100,
                          ),
                        ),
                        const Text('No Notifications Yet!',
                            style: TextStyle(
                              color: Color.fromARGB(255, 7, 56, 50),
                              fontSize: 18,
                            )),
                      ]),
              );
      },
    ),
  );
}
