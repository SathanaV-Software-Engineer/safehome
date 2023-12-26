import 'package:avatar_glow/avatar_glow.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:safehome/add_sensor/sensor_controller.dart';
import 'package:safehome/add_user/secondary_user_controller.dart';
import 'package:safehome/edit_device_info/edit_space_controller.dart';
import 'package:safehome/home/custom_app_bar.dart';
import 'package:safehome/home/gw_scan_response.dart';
import 'package:safehome/device_history/device_history_controller.dart';
import 'package:safehome/home/loader_contoller.dart';
import 'package:safehome/home/sensor_model.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/no_internet_pages/no_internet_page.dart';
import 'dart:math' as math;

import '../add_sensor/add_sensor_page.dart';
import '../device_history/device_history_page.dart';
import '../edit_device_info/edit_space_information.dart';
import '../setting/settings.dart';
import '../utils/constants.dart';
import '../utils/dialog_boxes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String selectedProfile = ref.watch(deviceController).selectedProfile;
    bool gatewayStatus = ref.watch(deviceController).gatewayActiveStatus;
    Map selectedProfileObj = ref.watch(deviceController).selectedProfileObj;
    bool isLoading = ref.watch(deviceController).isLoading;
    List deviceList = ref.watch(deviceController).deviceList;
    String errorMessage = ref.watch(deviceController).errorMessage;
    bool showApplyProfile = ref.watch(deviceController).showApplyProfile;
    bool isPullToRefresh = ref.watch(deviceController).isPullToRefresh;
    String webSocketError = ref.watch(deviceController).webSocketError;
    bool showGlow = ref.watch(deviceController).startGlowing;
    bool isFabOpen = ref.watch(deviceController).isFabOpen;
    GatewayQRResponse currentGwDevice =
        ref.watch(deviceController).currentGwDevice;
    Color defaultIconColor = const Color.fromARGB(255, 112, 112, 112);
    Color enabledColor = Theme.of(context).primaryColor;

    Color redHighlight = const Color.fromARGB(255, 148, 34, 34);
    Color greenHighlight = const Color.fromARGB(255, 0, 48, 2);
    //iconColor
    bool isHomeActive = (selectedProfileObj.isEmpty
        ? selectedProfile == 'HOME'
        : selectedProfileObj['result'] == 'okP1');
    bool isSleepActive = (selectedProfileObj.isEmpty
        ? selectedProfile == 'SLEEP'
        : selectedProfileObj['result'] == 'okP2');
    bool isAwayActive = (selectedProfileObj.isEmpty
        ? selectedProfile == 'AWAY'
        : selectedProfileObj['result'] == 'okP3');
    final iconWidgets = [
      {
        "widget": IconButton(
            onPressed: () {
              if (selectedProfile != 'ARMED') {
                showCustomDialog(ref, context, 'armDevices', '', '');
              }
            },
            icon: Image.asset(
              lock,
              color:
                  selectedProfile == 'ARMED' ? Colors.white : defaultIconColor,
              height: 45,
              width: 30,
            )),
        "color": selectedProfile == 'ARMED' ? enabledColor : defaultIconColor,
        "active": selectedProfile == 'ARMED',
      },
      {
        "widget": IconButton(
            onPressed: () {
              if (selectedProfile != 'DISARM') {
                showCustomDialog(ref, context, 'disarmDevices', '', '');
              }
            },
            icon: Image.asset(
              unlocked,
              color:
                  selectedProfile == 'DISARM' ? Colors.white : defaultIconColor,
              height: 50,
              width: 30,
            )),
        "color": selectedProfile == 'DISARM'
            ? const Color.fromARGB(255, 184, 23, 11)
            : defaultIconColor,
        "active": selectedProfile == 'DISARM',
      },
      {
        "widget": IconButton(
          onPressed: () {
            if (!isHomeActive) {
              ref.read(deviceController).changeProfile(context, ref, 'HOME');
            }
          },
          icon: Icon(
            color: isHomeActive ? Colors.white : defaultIconColor,
            Icons.home,
            size: 35,
          ),
        ),
        "color": isHomeActive ? enabledColor : defaultIconColor,
        "active": isHomeActive,
      },
      {
        "widget": IconButton(
          onPressed: () {
            if (!isSleepActive) {
              ref.read(deviceController).changeProfile(context, ref, 'SLEEP');
            }
          },
          icon: Icon(
            color: isSleepActive ? Colors.white : defaultIconColor,
            Icons.hotel_rounded,
            size: 35,
          ),
        ),
        "color": isSleepActive ? enabledColor : defaultIconColor,
        "active": isSleepActive,
      },
      {
        "widget": IconButton(
            onPressed: () {
              if (!isAwayActive) {
                ref.read(deviceController).changeProfile(context, ref, 'AWAY');
              }
            },
            icon: Image.asset(
              away,
              color: isAwayActive ? Colors.white : defaultIconColor,
              height: 38,
            )),
        "color": isAwayActive ? enabledColor : defaultIconColor,
        "active": isAwayActive,
      },
    ];
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: SafeArea(
        child: ConnectivityWidget(
            offlineBanner: const NoInternetConnectivityToast(),
            builder: (BuildContext context, bool isOnline) {
              return Scaffold(
                appBar: CustomAppBar(
                  height: 55,
                  child: const HomeGuardAppBar(),
                ),
                body: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                ref.read(deviceController).toggleFab(false);
                                ref.read(editSpaceController).updateLabel(
                                    ref,
                                    currentGwDevice.label!,
                                    currentGwDevice.label);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditSpaceInformation(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 150,
                                height: 45,
                                padding: const EdgeInsets.only(
                                  left: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  border: Border.all(
                                    width: 1,
                                    color: const Color.fromARGB(
                                        255, 119, 117, 117),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(25),
                                    topRight: Radius.circular(25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        currentGwDevice.label!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.start,
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      width: 13,
                                      height: 13,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: gatewayStatus
                                              ? const Color.fromARGB(
                                                  78, 28, 73, 30)
                                              : const Color.fromARGB(
                                                  87, 128, 35, 28),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color.fromARGB(
                                                    120, 216, 216, 214)
                                                .withOpacity(0.5),
                                            spreadRadius: 3,
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                        color: gatewayStatus
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            AvatarGlow(
                              animate: showGlow,
                              glowColor: Colors.red,
                              glowRadiusFactor: 1,
                              glowShape: BoxShape.circle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: GestureDetector(
                                  onTap: () {
                                    ref.read(deviceController).toggleFab(false);
                                    setLoaderMessage(context, ref, triggerSos);
                                    ref
                                        .read(deviceController)
                                        .triggerSoS(context, ref);
                                  },
                                  child: Container(
                                    width: 120,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          width: 1,
                                          color: const Color.fromARGB(
                                              255, 168, 22, 22)),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(25)),
                                    ),
                                    child: const Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            "SOS",
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 179, 45, 45),
                                                fontSize: 18),
                                          ),
                                          Icon(
                                            Icons.sensors,
                                            color: Color.fromARGB(
                                                255, 179, 45, 45),
                                            size: 28,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 24.0, right: 8),
                          child: Wrap(
                            runAlignment: WrapAlignment.spaceAround,
                            spacing: width / 36,
                            alignment: WrapAlignment.center,
                            direction: Axis.horizontal,
                            children:
                                List.generate(iconWidgets.length, (index) {
                              return Container(
                                width: width / 6.5,
                                height: height * 0.08,
                                decoration: BoxDecoration(
                                  color: iconWidgets[index]["active"] as bool
                                      ? iconWidgets[index]["color"] as Color
                                      : Colors.white,
                                  border: Border.all(
                                    width: 1,
                                    color: iconWidgets[index]["active"] as bool
                                        ? (selectedProfile == 'DISARM'
                                            ? redHighlight
                                            : greenHighlight)
                                        : const Color.fromARGB(
                                            255, 194, 194, 194),
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  boxShadow: [
                                    if (iconWidgets[index]["active"] as bool)
                                      BoxShadow(
                                        color: const Color.fromARGB(
                                                255, 235, 235, 143)
                                            .withOpacity(0.5),
                                        spreadRadius: 5,
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                  ],
                                ),
                                child: Center(
                                    child:
                                        iconWidgets[index]["widget"] as Widget),
                              );

                              // }),
                            }),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (errorMessage.isNotEmpty)
                          Center(
                            child: Text(errorMessage),
                          ),
                        if (webSocketError.isNotEmpty)
                          Center(
                            child: Text(webSocketError),
                          ),
                        RefreshIndicator(
                          backgroundColor: Colors.black,
                          displacement: 1000.0,
                          onRefresh: () async {
                            ref.read(deviceController).refreshPage(ref);
                            return Future<void>.delayed(
                                const Duration(seconds: 2));
                          },
                          child: isLoading
                              ? isPullToRefresh
                                  ? SizedBox(
                                      height: 400,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                    )
                                  : const SizedBox(
                                      height: 400,
                                    )
                              : GestureDetector(
                                  onTap: () => ref
                                      .read(deviceController)
                                      .toggleFab(false),
                                  onHorizontalDragDown: (details) => ref
                                      .read(deviceController)
                                      .toggleFab(false),
                                  child: SizedBox(
                                    height: height * 0.57 -
                                        (showApplyProfile ? 70 : 0),
                                    child: SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: SlidableAutoCloseBehavior(
                                          closeWhenOpened: true,
                                          closeWhenTapped: true,
                                          child: ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            reverse: false,
                                            itemCount: deviceList.length,
                                            itemExtent: 77.0,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              SensorDetails device =
                                                  deviceList[index];
                                              String iconPath = doorOpen;
                                              Color trailingIconColor =
                                                  Theme.of(context)
                                                      .primaryColor;
                                              IconData statusIcon = Icons.lock;
                                              if (device.state == 'disarm') {
                                                statusIcon = Icons.lock_open;
                                                trailingIconColor =
                                                    const Color.fromARGB(
                                                        255, 184, 23, 11);
                                              }
                                              if (device.type == 'ds') {
                                                iconPath = doorOpen;
                                                if (device.alert
                                                    .contains('DoorOpen')) {
                                                  iconPath = doorOpen;
                                                } else if (device.alert
                                                    .contains('DoorClose')) {
                                                  iconPath = doorClose;
                                                }
                                              } else if (device.type == 'rm') {
                                                iconPath = remote;
                                              } else if (device.type == 'ms') {
                                                iconPath = voice;
                                              }

                                              if (device.state == 'arm') {
                                                trailingIconColor =
                                                    Theme.of(context)
                                                        .primaryColor;
                                              } else if (device.state ==
                                                  'disarm') {
                                                trailingIconColor =
                                                    const Color.fromARGB(
                                                        255, 184, 23, 11);
                                              }
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        20, 0, 18, 0),
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            13,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black12,
                                                              blurRadius: 1,
                                                              spreadRadius: 1,
                                                            )
                                                          ],
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            Positioned(
                                                              left: 0,
                                                              top: 0,
                                                              width: 660,
                                                              child: Slidable(
                                                                closeOnScroll:
                                                                    true,
                                                                groupTag: 1,
                                                                endActionPane:
                                                                    ActionPane(
                                                                  extentRatio:
                                                                      0.45,
                                                                  motion:
                                                                      const BehindMotion(),
                                                                  children: [
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        showDeviceEditDialog(
                                                                          ref,
                                                                          context,
                                                                          device,
                                                                        );
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            MediaQuery.of(context).size.width /
                                                                                7,
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                15,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                            borderRadius: BorderRadius.circular(20)),
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .edit_outlined,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              25,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        showCustomDialog(
                                                                            ref,
                                                                            context,
                                                                            'deleteDevice',
                                                                            device.id,
                                                                            device.label);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            MediaQuery.of(context).size.width /
                                                                                7,
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                15,
                                                                        decoration: BoxDecoration(
                                                                            color: const Color.fromARGB(
                                                                                255,
                                                                                146,
                                                                                45,
                                                                                45),
                                                                            borderRadius:
                                                                                BorderRadius.circular(20)),
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .delete_outline,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              25,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                child: Column(
                                                                  children: <Widget>[
                                                                    Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height /
                                                                          13,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          getAlertIcon(device
                                                                              .alert
                                                                              .toString()),
                                                                          Padding(
                                                                              padding: const EdgeInsets.only(right: 60),
                                                                              child: SizedBox(
                                                                                width: 40,
                                                                                child: device.type != 'rm'
                                                                                    ? device.state == 'arm'
                                                                                        ? IconButton(
                                                                                            icon: Icon(
                                                                                              statusIcon,
                                                                                              color: trailingIconColor,
                                                                                              size: 24,
                                                                                            ),
                                                                                            onPressed: () => ref.read(deviceController).changeStateOfDevice(index),
                                                                                          )
                                                                                        : GestureDetector(
                                                                                            onTap: () => ref.read(deviceController).changeStateOfDevice(index),
                                                                                            child: Image.asset(
                                                                                              unlocked,
                                                                                              color: trailingIconColor,
                                                                                              height: 20,
                                                                                              width: 55,
                                                                                            ),
                                                                                          )
                                                                                    : null,
                                                                              )),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              left: 60,
                                                              top: 15,
                                                              child: Container(
                                                                width: 150,
                                                                height: 28,
                                                                color: Colors
                                                                    .white,
                                                                child: Text(
                                                                    device.label
                                                                        .toString(),
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Color
                                                                          .fromARGB(
                                                                              255,
                                                                              7,
                                                                              56,
                                                                              50),
                                                                      fontSize:
                                                                          18,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              left: 20,
                                                              top: 15,
                                                              child: (iconPath ==
                                                                      doorClose)
                                                                  ? Icon(
                                                                      Icons
                                                                          .door_back_door,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                    )
                                                                  : Image.asset(
                                                                      iconPath,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                      width: 22,
                                                                      height:
                                                                          22,
                                                                    ),
                                                            )
                                                          ],
                                                        )),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        if (showApplyProfile)
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height / 17,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).primaryColor),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0))),
                                ),
                                child: const Text(
                                  "Apply Profile",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                onPressed: () {
                                  ref
                                      .read(deviceController)
                                      .applyProfile(context, ref);
                                },
                              ),
                            ),
                          )
                      ]),
                ),
                floatingActionButton: Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        heroTag: "btn2",
                        backgroundColor: Theme.of(context).primaryColor,
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        // access the provider via ref.read(), then increment its state.
                        onPressed: () {
                          ref.read(deviceController).toggleFab(false);
                          ref
                              .read(secondaryUserController)
                              .fetchSecondaryUsers(
                                  context, ref, currentGwDevice.uid)
                              .then((value) => {
                                    if (value != null)
                                      {
                                        Navigator.of(context)
                                            .pushNamed(addUserRoute)
                                      }
                                  });
                        },
                        child: const Icon(
                          Icons.group_add_sharp,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            left: MediaQuery.of(context).size.height / 25,
                            child: Image.asset(
                              salzerLabel,
                              width: 100,
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            child: ExpandableFab(
                              distance: 180,
                              ref: ref,
                              initialOpen: isFabOpen,
                              children: [
                                ActionButton(
                                  onPressed: () {
                                    ref.read(deviceController).toggleFab(false);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Settings(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                  ),
                                ),
                                ActionButton(
                                  onPressed: () {
                                    ref.read(deviceController).toggleFab(false);
                                    ref
                                        .read(deviceHistoryController)
                                        .clearFilterData();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DeviceHistory(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.restore,
                                    color: Colors.white,
                                  ),
                                ),
                                ActionButton(
                                  onPressed: () {
                                    ref.read(deviceController).toggleFab(false);
                                    ref.read(editSpaceController).updateLabel(
                                        ref,
                                        currentGwDevice.label!,
                                        currentGwDevice.label);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditSpaceInformation(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.router,
                                    color: Colors.white,
                                  ),
                                ),
                                ActionButton(
                                  onPressed: () {
                                    ref.read(deviceController).toggleFab(false);
                                    ref
                                        .read(sensorController)
                                        .clearSensorDetails();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddSensor(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}

Widget getAlertIcon(String value) {
  value = value.toLowerCase();
  return Row(
    children: [
      if (value.contains('lowbat'))
        const Icon(
          Icons.battery_alert,
          color: Colors.red,
        ),
      if (value.contains('tamper'))
        const Icon(
          Icons.warning_rounded,
          color: Colors.red,
        ),
    ],
  );
}

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.ref,
    required this.children,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;
  final WidgetRef ref;
  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      widget.ref.read(deviceController).toggleFab(_open);
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _setValue(value) {
    setState(() {
      _open = value;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _setValue(widget.initialOpen);
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 60,
      height: 60,
      child: Center(
        child: Material(
          color: Theme.of(context).primaryColor,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            heroTag: "btn1",
            elevation: 2.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0)),
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: _toggle,
            child: const Icon(
              Icons.touch_app,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 14.0, bottom: 3),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(100)),
            boxShadow: [
              BoxShadow(
                  color: theme.colorScheme.onSecondary,
                  blurRadius: 1,
                  spreadRadius: 3)
            ]),
        child: Center(
          child: IconButton(
            onPressed: onPressed,
            iconSize: 25,
            icon: SizedBox(height: 100, width: 100, child: icon),
            color: theme.colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }
}
