import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/add_sensor/sensor_controller.dart';
import 'package:safehome/no_internet_pages/no_internet_page.dart';

import '../home/sensor_model.dart';

class AddSensor extends ConsumerWidget {
  static final GlobalKey<FormState> _key = GlobalKey();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  AddSensor({Key? key}) : super(key: key);
  final Color primaryColor = const Color.fromARGB(255, 5, 77, 67);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        body: Form(key: _key, child: _body(context, ref)),
      ),
    );
  }

  _body(
    BuildContext context,
    WidgetRef ref,
  ) {
    double height = MediaQuery.of(context).size.height;
    SensorDetails sensor = ref.watch(sensorController).selectedsensor;
    return ConnectivityWidget(
        offlineBanner: const NoInternetConnectivityToast(),
        builder: (BuildContext context, bool isOnline) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: height / 5,
                ),
                Text(
                  "Add Guards to your space",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () {
                    ref.read(sensorController).sensorScan(ref, context);
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(100)),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Click to scan QR code",
                  style: TextStyle(
                    color: Color.fromARGB(248, 160, 161, 162),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _sensorName(context, ref),
                ),
                const SizedBox(height: 12.0),
                if (sensor.uid.isNotEmpty)
                  Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 40),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 10, top: 0, bottom: 10),
                        child: Text(
                          ' UID : ${sensor.uid.toString()}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      )),
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: height / 17,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(primaryColor),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0))),
                      ),
                      child: const Text(
                        "Add Sensor",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        ref
                            .read(sensorController)
                            .addSensortoServer(context, ref);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  // _sensorName(BuildContext context, WidgetRef ref) {
  //   TextEditingController controller = TextEditingController();
  //   SensorDetails sensor = ref.watch(sensorController).selectedsensor;
  //   controller.text = sensor.name;
  //   controller.selection = TextSelection.fromPosition(
  //       TextPosition(offset: controller.text.length));
  //   return TextFormField(
  //       maxLength: 13,
  //       onChanged: (value) {
  //         ref.read(sensorController).updateSensorsField('name', value);
  //         // controller.text = value;
  //         // controller.selection = TextSelection.fromPosition(
  //         //     TextPosition(offset: controller.text.length));
  //       },
  //       controller: controller,
  //       cursorColor: Theme.of(context).primaryColor,
  //       decoration: InputDecoration(
  //           focusedBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(25.0),
  //             borderSide: BorderSide(
  //               color: Theme.of(context).primaryColor,
  //             ),
  //           ),
  //           contentPadding: const EdgeInsets.all(16.0),
  //           hintText: 'Sensor Name',
  //           counterText: "",
  //           hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
  //               fontSize: 15.0,
  //               color: const Color.fromARGB(248, 183, 184, 185)),
  //           border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(30.0),
  //               borderSide: BorderSide(color: primaryColor)),
  //           filled: true,
  //           fillColor: Colors.white),
  //       style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16.0));
  // }

  _sensorName(BuildContext context, WidgetRef ref) {
    TextEditingController controller = TextEditingController();
    SensorDetails sensor = ref.watch(sensorController).selectedsensor;
    controller.text = sensor.name;
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 1, 0, 1),
            child: Icon(
              Icons.sensor_occupied,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(
            width: 250,
            child: TextFormField(
              maxLength: 20,
              controller: controller,
              enabled: false,
              onChanged: (value) {
                ref.read(sensorController).updateSensorsField('name', value);
              },
              cursorColor: Theme.of(context).primaryColor,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(16.0),
                hintText: 'Sensor Name',
                counterText: "",
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  color: Color.fromARGB(248, 183, 184, 185),
                ),
                filled: true,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                fillColor: Colors.white,
              ),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
