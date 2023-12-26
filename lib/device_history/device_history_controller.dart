import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/home/loader_contoller.dart';
import 'package:intl/intl.dart';
import '../home/sensor_model.dart';
import '../utils/api_handler.dart';
import 'device_history_service.dart';

final deviceHistoryController = ChangeNotifierProvider<DeviceHistoryProvider>(
    (ref) => DeviceHistoryProvider());

class DeviceHistoryProvider extends ChangeNotifier {
  String _fromDate = '0';
  String _toDate = '0';
  SensorDetails _selectedsensor = SensorDetails();
  List _deviceHistoryList = [];
  updateSelectedDate(DateTime selectedDate, bool isFromDate) {
    if (isFromDate) {
      int fromTimestamp = selectedDate.millisecondsSinceEpoch;
      _fromDate = fromTimestamp.toString();
    } else {
      int toTimestamp = selectedDate.millisecondsSinceEpoch;
      _toDate = toTimestamp.toString();
    }
    log('From Date: $_fromDate');
    log('From Time: $_toDate');
    notifyListeners();
  }

  void updateSelectedDeviceId(device) {
    _selectedsensor = device;
    notifyListeners();
  }

  clearFilterData() {
    _fromDate = '0';
    _toDate = '0';
    _deviceHistoryList = [];
    _selectedsensor = SensorDetails();
    notifyListeners();
  }

  Future fetchDeviceHistory(BuildContext context, WidgetRef ref) async {
    DeviceHistoryService service = DeviceHistoryService(context, ref);
    try {
      if (_fromDate != '0' && _toDate != '0' && _selectedsensor.id != '') {
        Response response = await service.getDeviceHistory(
            _fromDate, _toDate, _selectedsensor.id);
        if (response.statusCode == 200) {
          _deviceHistoryList = [];
          dynamic data = response.data;
          if (data['alert'] != null) {
            for (var item in data['alert']) {
              Map<String, dynamic> newItem = Map.from(item);
              DateTime dateTime =
                  DateTime.fromMillisecondsSinceEpoch(item['ts'], isUtc: true);
              String formattedDate =
                  DateFormat('MM/dd/yyyy HH.mm.ss').format(dateTime);
              newItem['dateTime'] = formattedDate;
              _deviceHistoryList.add(newItem);
            }
          }
          return 200;
        } else {
          showToast(getErrorMessageFromThingsBoard(response.statusCode));
          _deviceHistoryList = [];
        }
      } else {
        showToast(
            'Please apply filters for date and sensor to view the History.');
        _deviceHistoryList = [];
      }
    } catch (e) {
      showToast(getErrorMessageFromException(e));
      _deviceHistoryList = [];
    } finally {
      if (context.mounted) cleanLoaderMessage(context, ref);
      notifyListeners();
    }
  }

  String get fromDate => _fromDate;
  String get toDate => _toDate;
  SensorDetails get selectedSensor => _selectedsensor;
  List get deviceHistoryList => _deviceHistoryList;
}
