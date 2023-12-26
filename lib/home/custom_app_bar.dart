import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/home/profile_icon.dart';
import 'package:safehome/utils/constants.dart';

class HomeGuardAppBar extends ConsumerWidget {
  const HomeGuardAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String currentRoute =
        ModalRoute.of(context)!.settings.name ?? 'Unknown Route';
    log('Current route path: $currentRoute');
    bool isTabClickable = (currentRoute != '/primaryNotifications') &&
        (currentRoute != '/notifications');
    return Container(
      color: Colors.white,
      child: GestureDetector(
        onTap: () => ref.read(deviceController).toggleFab(false),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: ProfileIcon(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 8, 0, 0),
                  child: Image.asset(
                    homeGuardLogo,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 10, 2),
                  child: Stack(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            isTabClickable
                                ? BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 1),
                                  )
                                : const BoxShadow(),
                          ],
                        ),
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if (isTabClickable) {
                                ref.read(deviceController).toggleFab(false);
                                Navigator.of(context)
                                    .pushNamed(primaryNotificationsRoute);
                              }
                            },
                            child: const Center(
                              child: Icon(
                                Icons.notifications,
                                color: Colors.green,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ValueListenableBuilder<Box>(
                          valueListenable:
                              Hive.box('notifications').listenable(),
                          builder: (context, box, widget) {
                            List<dynamic> notifications =
                                box.get('NOTIFICATIONS', defaultValue: []);
                            int notificationsCount = notifications
                                .where((e) {
                                  return e['isRead'] == false;
                                })
                                .toList()
                                .length;
                            return notificationsCount > 0
                                ? Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(1),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      height: 10,
                                      width: 10,
                                    ),
                                  )
                                : const SizedBox();
                          })
                    ],
                  ),
                )
              ]),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }
}

class CustomAppBar extends PreferredSize {
  @override
  final Widget child;
  final double height;

  CustomAppBar({
    super.key,
    required this.height,
    required this.child,
  }) : super(child: child, preferredSize: Size.fromHeight(height));
}
