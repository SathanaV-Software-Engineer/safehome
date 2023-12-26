import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/login/user_model.dart';
import 'package:safehome/utils/dialog_boxes.dart';

import '../utils/constants.dart';
import 'notification_controller.dart';

class Notifications extends ConsumerWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Notifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<dynamic> notificationList =
        ref.watch(notificationController).notifications;
    UserModel loggedInUser = ref.watch(loginController).loggedUser;
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Image.asset(
                    salzerLabel,
                    width: 100,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 18, 40, 0),
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                        fontSize: 18, color: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: IconButton(
                    onPressed: () {
                      showCustomDialog(
                          ref, context, "logout", loggedInUser.customerId, '');
                    },
                    icon: const Icon(
                      color: Colors.red,
                      Icons.logout,
                      size: 28,
                    ),
                  ),
                )
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _searchField(context, ref),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: SingleChildScrollView(
                  child: ValueListenableBuilder<Box>(
                    valueListenable: Hive.box('notifications').listenable(),
                    builder: (context, box, widget) {
                      List<dynamic> notifications =
                          box.get('FILTEREDNOTIFICATIONS', defaultValue: []);
                      notificationList = notifications.where((e) {
                        return e['isRead'] == false;
                      }).toList();
                      return Padding(
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: <Widget>[
                                  Dismissible(
                                    key: UniqueKey(),
                                    direction: DismissDirection.horizontal,
                                    onDismissed: (direction) {
                                      ref
                                          .read(notificationController)
                                          .markNotificationAsRead(
                                              notification['id']);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              9,
                                      padding: const EdgeInsets.only(top: 5),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 217, 221, 219),
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
                                              padding: const EdgeInsets.only(
                                                  top: 5.0),
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
                                                        notification[
                                                                'timestamp']
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
                                                        notification[
                                                            'deviceName'],
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
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
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
            hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 15.0, color: Theme.of(context).primaryColor),
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
}
