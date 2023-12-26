import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/home/gw_scan_response.dart';
import 'package:safehome/home/loader_contoller.dart';
import 'package:safehome/no_internet_pages/no_internet_page.dart';
import 'package:safehome/utils/constants.dart';
import 'package:intl/intl.dart';
import '../home/device_controller.dart';
import '../home/sensor_model.dart';
import 'device_history_controller.dart';

class DeviceHistory extends ConsumerWidget {
  DeviceHistory({Key? key}) : super(key: key);

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final Color primaryColor = const Color.fromARGB(255, 5, 77, 67);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<SensorDetails> deviceList = ref.watch(deviceController).deviceList;
    late DateTime fromDate;
    late DateTime toDate;
    String selectedFromDateTimeStamp =
        ref.watch(deviceHistoryController).fromDate;
    GatewayQRResponse currentGwDevice =
        ref.watch(deviceController).currentGwDevice;
    String selectedToDateTimeStamp = ref.watch(deviceHistoryController).toDate;
    SensorDetails selectedDevice =
        ref.watch(deviceHistoryController).selectedSensor;
    String formattedfromDate = '';
    String formattedtoDate = '';
    List deviceHistory = ref.watch(deviceHistoryController).deviceHistoryList;

    if (selectedFromDateTimeStamp != '0') {
      DateTime fromDateTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(selectedFromDateTimeStamp));
      formattedfromDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(fromDateTime);
    }
    if (selectedToDateTimeStamp != '0') {
      DateTime toDateTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(selectedToDateTimeStamp));
      formattedtoDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(toDateTime);
    }
    SensorDetails gateway = SensorDetails.fromJson({
      'id': currentGwDevice.uid,
      'name': currentGwDevice.name,
      'label': currentGwDevice.label,
      'type': currentGwDevice.type
    });
    List<SensorDetails> sensors = List.from(deviceList);
    sensors.add(gateway);
    return SafeArea(
      child: ConnectivityWidget(
          offlineBanner: const NoInternetConnectivityToast(),
          builder: (BuildContext context, bool isOnline) {
            return Scaffold(
              key: scaffoldKey,
              body: Column(
                children: <Widget>[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 40,
                        width: 180,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(width: 1, color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () async {
                            DateTime? selectedDate = await showDatePicker(
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: primaryColor,
                                      onPrimary: Colors.white,
                                      onSurface: primaryColor,
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: primaryColor,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2018),
                              lastDate: DateTime(2030),
                              cancelText: '',
                            );

                            if (selectedDate != null && context.mounted) {
                              BuildContext originalContext = context;
                              TimeOfDay? selectedTime = await showTimePicker(
                                context: originalContext,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: primaryColor,
                                        onPrimary: Colors.white,
                                        onSurface: primaryColor,
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: primaryColor,
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (selectedTime != null) {
                                fromDate = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );
                                ref
                                    .read(deviceHistoryController)
                                    .updateSelectedDate(fromDate, true);
                              }
                            }
                          },
                          child: Text(
                            formattedfromDate == ''
                                ? 'From Date'
                                : formattedfromDate,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 122, 121, 121),
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        width: 180,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(width: 1, color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () async {
                            DateTime? selectedDate = await showDatePicker(
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: primaryColor,
                                      onPrimary: Colors.white,
                                      onSurface: primaryColor,
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: primaryColor,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2018),
                              lastDate: DateTime(2030),
                              cancelText: '',
                            );

                            if (selectedDate != null && context.mounted) {
                              BuildContext originalContext = context;
                              TimeOfDay? selectedTime = await showTimePicker(
                                context: originalContext,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: primaryColor,
                                        onPrimary: Colors.white,
                                        onSurface: primaryColor,
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: primaryColor,
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (selectedTime != null) {
                                toDate = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );
                                ref
                                    .read(deviceHistoryController)
                                    .updateSelectedDate(toDate, false);
                              }
                            }
                          },
                          child: Text(
                            formattedtoDate == '' ? 'To Date' : formattedtoDate,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 122, 121, 121),
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 40,
                        width: 180,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(width: 1, color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            selectDeviceDialog(context, ref, sensors);
                          },
                          child: Text(
                            selectedDevice.name == ''
                                ? 'Select Device'
                                : selectedDevice.name,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 122, 121, 121),
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        width: 180,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(134, 18, 183, 32),
                            side: BorderSide(width: 1, color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            setLoaderMessage(
                                context, ref, fetchingDeviceHistory);
                            ref
                                .read(deviceHistoryController)
                                .fetchDeviceHistory(context, ref);
                          },
                          child: const Text(
                            'SUBMIT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: Text(
                      'Selected Device History Details',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                    itemCount: deviceHistory.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(
                            left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: primaryColor, width: 1.0),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              deviceHistory[index]["value"]
                                  .toString()
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              deviceHistory[index]["dateTime"].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )),
                ],
              ),
              appBar: AppBar(
                title: Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Text(
                    'Device History',
                    style: TextStyle(fontSize: 18, color: primaryColor),
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),
            );
          }),
    );
  }
}

selectDeviceDialog(
    BuildContext context, WidgetRef ref, List<SensorDetails> deviceList) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.88,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                padding: const EdgeInsets.all(16.0),
                child: const Center(
                  child: Text(
                    "Choose Device for History",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: deviceList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(deviceHistoryController)
                              .updateSelectedDeviceId(deviceList[index]);
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height / 18,
                          child: ListTile(
                            title: Center(
                              child: Text(
                                deviceList[index].name.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      (index != deviceList.length - 1)
                          ? const Divider(
                              thickness: 1,
                              color: Color.fromARGB(255, 150, 148, 148),
                            )
                          : const SizedBox(
                              height: 10,
                            ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
