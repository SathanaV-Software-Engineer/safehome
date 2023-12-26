import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/home/sensor_model.dart';
import 'package:safehome/no_internet_pages/no_internet_page.dart';
import '../utils/dialog_boxes.dart';
import 'device_recovery_mode.dart';

class Settings extends ConsumerWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Settings({Key? key}) : super(key: key);
  final Color primaryColor = const Color.fromARGB(255, 5, 77, 67);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? gatewayID = ref.watch(deviceController).currentGwDevice.uid;
    List<SensorDetails> sensorList = ref.watch(deviceController).deviceList;
    return SafeArea(
      child: ConnectivityWidget(
          offlineBanner: const NoInternetConnectivityToast(),
          builder: (BuildContext context, bool isOnline) {
            return Scaffold(
              key: scaffoldKey,
              body: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.83,
                  height: MediaQuery.of(context).size.height * 0.2,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2,
                        color: const Color.fromARGB(255, 211, 210, 210)),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.83,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  side:
                                      BorderSide(width: 1, color: primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  )),
                              onPressed: () {
                                showCustomDialog(ref, context, "factoryReset",
                                    gatewayID, sensorList);
                              },
                              child: const Text(
                                'Device Factory Reset',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.83,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  side:
                                      BorderSide(width: 1, color: primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  )),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DeviceRecoveryMode(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Device Recovery Mode',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
