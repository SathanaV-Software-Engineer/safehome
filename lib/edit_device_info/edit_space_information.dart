import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/edit_device_info/edit_space_controller.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/home/loader_contoller.dart';
import 'package:safehome/home/sensor_model.dart';
import 'package:safehome/no_internet_pages/no_internet_page.dart';

import '../home/gw_scan_response.dart';

class EditSpaceInformation extends ConsumerWidget {
  static final GlobalKey<FormState> _key = GlobalKey();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  EditSpaceInformation({Key? key}) : super(key: key);
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
    GatewayQRResponse device = ref.watch(deviceController).currentGwDevice;
    bool enableButton = ref.watch(editSpaceController).showSubmitbutton;
    return ConnectivityWidget(
        offlineBanner: const NoInternetConnectivityToast(),
        builder: (BuildContext context, bool isOnline) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: height / 4,
                ),
                Text(
                  "Space Details",
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _spaceName(context, ref),
                ),
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _deviceName(context, ref, device),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: height / 17,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: (enableButton == true)
                            ? MaterialStateProperty.all(primaryColor)
                            : MaterialStateProperty.all(Colors.grey),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0))),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () async {
                        SensorDetails deviceDetails = SensorDetails(
                            id: device.uid!, name: device.name!, type: 'gw');
                        if (enableButton) {
                          ref.read(deviceController).updateDeviceInformation(
                              context,
                              ref,
                              deviceDetails,
                              ref.read(editSpaceController).gatewayLabel);
                          await Future.delayed(const Duration(seconds: 2)).then(
                              (value) => cleanLoaderMessage(context, ref));
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  _spaceName(BuildContext context, WidgetRef ref) {
    TextEditingController gatewayController = TextEditingController();
    gatewayController.text = ref.watch(editSpaceController).gatewayLabel;
    String? gatewayLabel = ref.watch(deviceController).currentGwDevice.label;
    gatewayController.selection = TextSelection.fromPosition(
        TextPosition(offset: gatewayController.text.length));
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
              Icons.home,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(
            width: 250,
            child: TextFormField(
              maxLength: 20,
              controller: gatewayController,
              onChanged: (value) {
                ref
                    .read(editSpaceController)
                    .updateLabel(ref, value, gatewayLabel);
              },
              cursorColor: Theme.of(context).primaryColor,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(16.0),
                hintText: 'Space Name',
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

  _deviceName(
    BuildContext context,
    WidgetRef ref,
    GatewayQRResponse device,
  ) {
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
              Icons.router,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child: Text(device.name!)),
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10),
                child: Text(
                  ' UID : ${device.uid.toString()}',
                  style: const TextStyle(fontSize: 10),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
