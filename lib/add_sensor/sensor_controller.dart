import 'dart:convert';
import 'dart:developer';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/add_sensor/sensor_service.dart';
import 'package:safehome/home/device_controller.dart';
import 'package:safehome/home/gw_scan_response.dart';
import 'package:safehome/home/loader_contoller.dart';
import 'package:safehome/login/login_controller.dart';
import '../home/sensor_model.dart';
import '../utils/api_handler.dart';
import '../utils/constants.dart';

final sensorController =
    ChangeNotifierProvider<SensorProvider>((ref) => SensorProvider());

class SensorProvider extends ChangeNotifier {
  final SensorService _service = SensorService();
  final SensorDetails _selectedsensor = SensorDetails();

  void updateSelectedDeviceId(device) {
    _selectedsensor.id = device;
    notifyListeners();
  }

  addSensor(response) {
    dynamic data = jsonDecode(response);
    _selectedsensor.uid = data['uid'];
    _selectedsensor.name = data['name'];
    _selectedsensor.type = data['type'];
    notifyListeners();
  }

  clearSensorDetails() {
    _selectedsensor.name = '';
    _selectedsensor.uid = '';
    notifyListeners();
  }

  updateSensorsField(field, value) {
    if (field == 'name') {
      _selectedsensor.name = value;
      _selectedsensor.uid = '';
    } else {
      _selectedsensor.uid = value;
    }
    notifyListeners();
  }

  Future<void> sensorScan(WidgetRef ref, BuildContext context) async {
    final result = await BarcodeScanner.scan();
    if (result.rawContent.isNotEmpty) {
      if (result.rawContent.length > 4) {
        addSensor(result.rawContent);
      } else {
        showToast(scanValidSensor);
      }
      log(result.toString());
    }
  }

  bool isSensorPresent(WidgetRef ref, String sensorName) {
    List<SensorDetails> deviceList = ref.watch(deviceController).deviceList;
    return deviceList
        .where((element) => element.name == sensorName)
        .toList()
        .isNotEmpty;
  }

  Future addSensortoServer(BuildContext context, WidgetRef ref) async {
    GatewayQRResponse gateway = ref.read(deviceController).currentGwDevice;
    if (_selectedsensor.name == '') {
      showToast('Please enter something');
      return;
    }
    // if (isSensorPresent(ref, _selectedsensor.name)) {
    //   showToast(sensorAlreadyAvailable(_selectedsensor.name, gateway.label));
    //   return;
    // }
    setLoaderMessage(context, ref, addingSensor);
    try {
      Response response = await _service.addSensorService(gateway.uid,
          ref.read(loginController).loggedUser.customerId, _selectedsensor);
      if (response.statusCode == 200) {
        clearSensorDetails();
        if (response.data["sensors"][0]["id"] == null) {
          showToast(invalidSensorDetails);
          return;
        }
        ref.read(deviceController).getRelatedDevices();
        if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
        return 200;
      } else {
        showToast(getErrorMessageFromThingsBoard(response.statusCode));
      }
    } catch (e) {
      showToast(getErrorMessageFromException(e));
    } finally {
      if (context.mounted) cleanLoaderMessage(context, ref);
    }
  }

  SensorDetails get selectedsensor => _selectedsensor;
}
