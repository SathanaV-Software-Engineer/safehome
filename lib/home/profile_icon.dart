import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safehome/edit_profile_info/edit_profile_controller.dart';
import 'package:safehome/edit_profile_info/edit_profile_information.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/home/gw_scan_response.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/login/user_model.dart';
import 'package:safehome/utils/common_utils.dart';
import 'package:safehome/utils/dialog_boxes.dart';

class ProfileIcon extends ConsumerWidget {
  const ProfileIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel loggedUser = ref.watch(loginController).loggedUser;
    GatewayQRResponse currentGwDevice =
        ref.watch(deviceController).currentGwDevice;
    String? firstLetter = getFirstLetter(loggedUser.profileName ?? '');
    return ValueListenableBuilder<Box>(
        valueListenable: Hive.box('notifications').listenable(),
        builder: (context, box, widget) {
          return SizedBox(
            height: 100,
            child: PopupMenuButton(
              onSelected: (value) {},
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              icon: Stack(
                children: [
                  Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: firstLetter != null
                          ? Center(
                              child: Text(firstLetter.toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 20)),
                            )
                          : const Icon(
                              Icons.person_3_rounded,
                              color: Colors.white,
                            )),
                ],
              ),

              elevation: 20,
              offset: const Offset(0, 55),
              // position: PopupMenuPosition.under,

              padding: const EdgeInsets.fromLTRB(0, 14, 8, 0),
              color: Colors.white,

              itemBuilder: (BuildContext bc) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      ref.read(editProfileController).setInitialUserDetails(
                          ref.read(loginController).loggedUser);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileInformation(),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 1.0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_circle_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 40,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            loggedUser.profileName ?? '',
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(loggedUser.mobileNumber ?? '',
                                              style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 12))
                                        ]),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.navigate_next_outlined,
                                size: 30,
                                color: Theme.of(context).primaryColor,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                      textStyle: const TextStyle(color: Colors.black),
                      value: '/deviceDetails',
                      onTap: () {},
                      child: const Row(
                        children: [
                          Icon(Icons.touch_app_sharp, color: Colors.black),
                          SizedBox(
                            width: 16.0,
                            height: 40,
                          ),
                          Text('Take a tour'),
                          Divider(
                            color: Colors.black,
                            thickness: 1.0,
                          ),
                        ],
                      )),
                  PopupMenuItem(
                      textStyle: const TextStyle(color: Colors.black),
                      value: '/logout',
                      onTap: () {
                        showCustomDialog(
                          ref,
                          context,
                          "logout",
                          currentGwDevice.uid,
                          '',
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.logout, color: Colors.black),
                          SizedBox(
                            width: 16.0,
                            height: 40,
                          ),
                          Text('Logout'),
                          Divider(
                            color: Colors.black,
                            thickness: 1.0,
                          ),
                        ],
                      )),

                  // if (loggedUser.userType == 'primaryUserLogin')
                  //   PopupMenuItem(
                  //       textStyle: TextStyle(color: Colors.black),
                  //       value: '/primaryNotifications',
                  //       onTap: () {
                  //         ref.read(deviceController).toggleFab(false);
                  //         Navigator.of(context)
                  //             .pushNamed(primaryNotificationsRoute);
                  //       },
                  //       child: Row(
                  //         children: [
                  //           Icon(Icons.notifications, color: Colors.black),
                  //           SizedBox(width: 8.0),
                  //           Text('Notification'),
                  //           SizedBox(width: 8.0),
                  //           if (notificationsCount > 0)
                  //             Container(
                  //               decoration: BoxDecoration(
                  //                 shape: BoxShape.circle,
                  //                 color: Theme.of(context)
                  //                     .primaryColor, // Choose your dot color
                  //               ),
                  //               child: Padding(
                  //                 padding: const EdgeInsets.all(6),
                  //                 child: Text(
                  //                   notificationsCount.toString(),
                  //                   style: const TextStyle(
                  //                       color: Colors.white, fontSize: 10),
                  //                 ),
                  //               ),
                  //             )
                  //         ],
                  //       )),
                ];
              },
            ),
          );
        });
  }
}
