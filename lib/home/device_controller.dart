import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/home/loader_contoller.dart';
import 'package:safehome/home/sensor_model.dart';
import 'package:safehome/home/home_service.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/utils/api_handler.dart';
import 'package:safehome/utils/common_utils.dart';
import 'package:safehome/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'gw_scan_response.dart';

final deviceController = ChangeNotifierProvider<HomeProvider>((ref) {
  HomeProvider homeProvider = HomeProvider();
  // homeProvider.initialize();
  ref.onDispose(() {
    homeProvider.dispose();
  });
  return homeProvider;
});

class HomeProvider extends ChangeNotifier {
  GatewayQRResponse currentGwDevice = GatewayQRResponse();
  String _selectedProfile = '';
  bool _gatewayActiveStatus = true;
  Map _selectedProfileObj = {};
  bool pageLoader = false;
  bool _isLoading = false;
  List<SensorDetails> _deviceList = [];
  String _errorMessage = '';
  bool _showApplyProfile = false;
  Map _serverAttribute = {};
  String _webSocketError = '';
  dynamic _channel;
  String token = '';
  String _editedDeviceLable = '';
  bool _isFabOpen = false;
  bool _isPullToRefresh = false;
  bool _startGlowing = false;
  late HomeService _service;
  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  void closeChannel() {
    _channel.sink.close();
  }

  Future<void> initialize(BuildContext context, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    _channel = WebSocketChannel.connect(
      Uri.parse('$websocketApi?token=$token'),
    );
    _service = HomeService(context, ref);
    startListeningToWebsocket();
    await streamListener(context, ref);
    getServerAttribute();
    getRelatedDevices();
  }

  updateeditedLable(newDeviceLable) {
    _editedDeviceLable = newDeviceLable;
  }

  void toggleFab(value) {
    _isFabOpen = value;
    notifyListeners();
  }

  Future updateDeviceInformation(BuildContext context, WidgetRef ref,
      SensorDetails data, String label) async {
    _service = HomeService(context, ref);
    if (label.isEmpty) {
      showToast('enter valid data');
      return;
    }
    setLoaderMessage(context, ref, updateGatewayDetails);
    try {
      dynamic response =
          await _service.callEditDevice(data.id, data.name, label, data.type);
      if (response.statusCode == 200 && context.mounted) {
        refreshPage(ref);
        if (data.type == 'gw') {
          log('response $response');
          String name = response.data['name'];
          String type = 'gw';
          String label = response.data['label'];
          String device =
              '{"uid":"${data.id}","name":"$name","type":"$type", "label": "$label"}';
          await addDevice(device);
        } else {
          Navigator.of(context, rootNavigator: true).pop();
        }
      } else {
        showToast(getErrorMessageFromThingsBoard(response.statusCode));
      }
    } catch (error) {
      showToast(getErrorMessageFromException(error));
    } finally {
      if (context.mounted) cleanLoaderMessage(context, ref);
    }
  }

  Future removeDevice(BuildContext context, WidgetRef ref, String gatewayId,
      String sensorName) async {
    _service = HomeService(context, ref);
    setLoaderMessage(context, ref, removeSensorMessage(sensorName));
    try {
      dynamic response =
          await _service.callRemoveDevice(currentGwDevice.uid, gatewayId);
      if (response.statusCode == 200 && context.mounted) {
        refreshPage(ref);
        Navigator.of(context, rootNavigator: true).pop();
        return 200;
      } else {
        showToast(getErrorMessageFromThingsBoard(response.statusCode));
      }
    } catch (error) {
      showToast(getErrorMessageFromException(error));
    } finally {
      if (context.mounted) cleanLoaderMessage(context, ref);
    }
  }

  void startListeningToWebsocket() {
    Map data = {
      "attrSubCmds": [],
      "tsSubCmds": [],
      "historyCmds": [],
      "entityDataCmds": [
        {
          "query": {
            "entityFilter": {
              "type": "singleEntity",
              "singleEntity": {
                "id": currentGwDevice.uid,
                "entityType": "DEVICE"
              }
            },
            "pageLink": {
              "page": 0,
              "pageSize": 50,
              "textSearch": null,
              "dynamic": true,
              "sortOrder": null
            },
            "entityFields": [
              {"type": "ENTITY_FIELD", "key": "name"},
              {"type": "ENTITY_FIELD", "key": "label"},
              {"type": "ENTITY_FIELD", "key": "additionalInfo"}
            ],
            "latestValues": [
              {"type": "ATTRIBUTE", "key": "state"},
              {"type": "SHARED_ATTRIBUTE", "key": "primaryFcmid"},
              {"type": "SERVER_ATTRIBUTE", "key": "active"},
              {"type": "TIME_SERIES", "key": "alert"}
            ]
          },
          "latestCmd": {
            "keys": [
              {"type": "ATTRIBUTE", "key": "state"},
              {"type": "TIME_SERIES", "key": "alert"},
              {"type": "SERVER_ATTRIBUTE", "key": "active"}
            ]
          },
          "cmdId": 6
        }
      ],
      "entityDataUnsubscribeCmds": [],
      "alarmDataCmds": [],
      "alarmDataUnsubscribeCmds": [],
      "entityCountCmds": [],
      "entityCountUnsubscribeCmds": []
    };
    String jsonString = json.encode(data);

    _channel.sink.add(jsonString);
    Map dataToListenDevices = {
      "attrSubCmds": [],
      "tsSubCmds": [],
      "historyCmds": [],
      "entityDataCmds": [
        {
          "query": {
            "entityFilter": {
              "type": "relationsQuery",
              "rootEntity": {
                "entityType": "DEVICE",
                "id": currentGwDevice.uid,
              },
              "direction": "FROM",
              "maxLevel": 1,
              "fetchLastLevelOnly": false,
              "filters": [
                {
                  "relationType": "Manages",
                  "entityTypes": ["DEVICE"]
                }
              ]
            },
            "pageLink": {
              "dynamic": true,
              "page": 0,
              "pageSize": 20,
              "sortOrder": {
                "key": {"key": "name", "type": "ENTITY_FIELD"},
                "direction": "ASC"
              }
            },
            "entityFields": [
              {"type": "ENTITY_FIELD", "key": "name"},
              {"type": "ENTITY_FIELD", "key": "label"},
              {"type": "ENTITY_FIELD", "key": "type"}
            ],
            "latestValues": [
              {"type": "ATTRIBUTE", "key": "state"},
              {"type": "SHARED_ATTRIBUTE", "key": "primaryFcmid"},
              {"type": "TIME_SERIES", "key": "alert"}
            ]
          },
          "latestCmd": {
            "keys": [
              {"type": "ATTRIBUTE", "key": "state"},
              {"type": "TIME_SERIES", "key": "alert"}
            ]
          },
          "cmdId": 8
        }
      ],
      "entityDataUnsubscribeCmds": [],
      "alarmDataCmds": [],
      "alarmDataUnsubscribeCmds": [],
      "entityCountCmds": [],
      "entityCountUnsubscribeCmds": []
    };
    jsonString = json.encode(dataToListenDevices);
    _channel.sink.add(jsonString);
  }

  Future getSystemDetails(
      BuildContext context, WidgetRef ref, String customerId) async {
    _service = HomeService(context, ref);
    try {
      Response response = await _service.getSystemDetails(customerId);
      if (response.statusCode == 200) {
        if (response.data.isNotEmpty) {
          String uid = response.data[0]["id"];
          String name = response.data[0]['name'];
          String type = response.data[0]['type'];
          String label = response.data[0]['label'];
          String device =
              '{"uid":"$uid","name":"$name","type":"$type", "label": "$label"}';
          await addDevice(device);
          ref.read(loginController).setUserType('primaryUserLogin');
          return 'primaryUserLogin';
        } else {
          ref.read(loginController).setUserType('secondaryUserLogin');
          return 'secondaryUserLogin';
        }
      } else {
        showToast(getErrorMessageFromThingsBoard(response.statusCode));
      }
    } catch (e) {
      showToast(getErrorMessageFromException(e));
    }
  }

  Future editGWlable({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      Response response =
          await _service.updateGWlable(currentGwDevice, editedDeviceLable);
      if (response.statusCode == 200) {
        return 200;
      } else {
        showToast(getErrorMessageFromThingsBoard(response.statusCode));
      }
    } catch (e) {
      showToast(getErrorMessageFromException(e));
    }
  }

  void triggerSoS(BuildContext context, WidgetRef ref) async {
    _service = HomeService(context, ref);
    _startGlowing = false;
    try {
      Map<String, dynamic> data = {
        "method": "sos",
        "params": {"trigger": "1"}
      };
      dynamic response =
          await _service.callRpcTwoWay(currentGwDevice.uid!, data);
      if (response.statusCode == 200) {
        log("Request successful: ${response.data}");
        if (context.mounted) cleanLoaderMessage(context, ref);
        showGlow();
        showToast('SOS Triggered', 'success');
      } else {
        if (context.mounted) cleanLoaderMessage(context, ref);
        _errorMessage = getErrorMessageFromThingsBoard(response.statusCode);
        showToast(_errorMessage);
      }
    } catch (error) {
      if (context.mounted) cleanLoaderMessage(context, ref);
      _errorMessage = getErrorMessageFromException(error);
      showToast(_errorMessage);
      log("Error: $error");
    }
  }

  void showGlow() {
    _startGlowing = true;
    const glowDuration = Duration(seconds: 10);
    Timer(glowDuration, () {
      _startGlowing = false;
      notifyListeners();
    });
    notifyListeners();
  }

  void changeStateOfDevice(int index) {
    if (selectedProfileObj.isNotEmpty &&
            (selectedProfileObj['result'] == 'okP2' ||
                selectedProfileObj['result'] == 'okP3') ||
        selectedProfile == 'SLEEP' ||
        selectedProfile == 'AWAY') {
      List<SensorDetails> updatedItems = List.from(deviceList);

      final currentState = updatedItems[index].state;
      updatedItems[index].state = (currentState == 'arm') ? 'disarm' : 'arm';

      _deviceList = updatedItems;
      _showApplyProfile = true;
      _isFabOpen = false;
      notifyListeners();
    }
  }

  Future changeProfile(BuildContext context, WidgetRef ref, String profile,
      [Map jsonFromChangeProfile = const {}]) async {
    setLoaderMessage(context, ref, changeProfileMessage);
    _showApplyProfile = false;
    _isLoading = true;
    _isFabOpen = false;
    notifyListeners();
    final Map<String, dynamic> profileData = {
      'ARM': {
        "method": "armState",
        "params": {"profilestate": "arm"}
      },
      'DISARM': {
        "method": "armState",
        "params": {"profilestate": "disarm"}
      },
      'HOME': {"method": "p1", "params": {}},
      'SLEEP': {"method": "p2", "params": {}},
      'AWAY': {"method": "p3", "params": {}},
    };
    if (jsonFromChangeProfile.isNotEmpty) {
      profileData[profile]['params'] = jsonFromChangeProfile;
    } else {
      if (profile == 'SLEEP' || profile == 'AWAY' || profile == 'HOME') {
        if (profile == 'HOME') {
          Map jsonData = {};
          for (SensorDetails item in deviceList) {
            if (item.type != 'rm') {
              if (item.type == 'ms') {
                jsonData[item.devIndexValue] = 0;
              } else {
                jsonData[item.devIndexValue] = 1;
              }
            }
          }
          profileData[profile]['params'] = jsonData;
        } else {
          final rpcRequestJson = serverAttribute.isNotEmpty
              ? serverAttribute['okP${profile == 'SLEEP' ? '2' : '3'}']
              : null;
          if (rpcRequestJson != null) {
            profileData[profile]['params'] = rpcRequestJson['rpc_request_json'];
          } else {
            _selectedProfile = profile;
            _selectedProfileObj = {};
            getRelatedDevices();
            _isLoading = false;
            _showApplyProfile = true;
            notifyListeners();
            cleanLoaderMessage(context, ref);
            return;
          }
        }
      }
    }

    if (profileData.containsKey(profile)) {
      profileData[profile]['timeout'] = '40000';
      return await performProfileChange(context, ref, profileData[profile]);
    }
    notifyListeners();
  }

  Future performProfileChange(
      BuildContext context, WidgetRef ref, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = '';
    _service = HomeService(context, ref);
    try {
      dynamic response =
          await _service.callRpcTwoWay(currentGwDevice.uid!, data);
      if (response.statusCode == 200) {
        _errorMessage = '';
        return response;
      } else {
        _errorMessage = getErrorMessageFromThingsBoard(response.statusCode);
        showToast(_errorMessage);
      }
    } catch (error) {
      log('catching error $error');
      _errorMessage = getErrorMessageFromException(error);
      showToast(_errorMessage);
    } finally {
      if (context.mounted) cleanLoaderMessage(context, ref);
      _isLoading = false;

      _isFabOpen = false;
      notifyListeners();
    }
  }

  void applyProfile(BuildContext context, WidgetRef ref) async {
    Map<String, dynamic> data = {};
    _service = HomeService(context, ref);
    final updatedProfile = {...serverAttribute};
    for (SensorDetails item in deviceList) {
      if (item.type != 'rm') {
        data[item.devIndexValue] = (item.state == 'arm') ? 1 : 0;
      }
    }
    if (selectedProfile.isNotEmpty) {
      final selectedProfileResult = selectedProfileObj['result'];
      String alias = '';
      String profileKey = '';
      if (selectedProfileResult == null) {
        alias = selectedProfile;
        profileKey = selectedProfile.toLowerCase() == 'sleep' ? 'okP2' : 'okP3';
      } else {
        alias = (selectedProfileResult == 'okP2') ? 'sleep' : 'away';
        profileKey = selectedProfileResult;
      }
      dynamic response =
          await changeProfile(context, ref, alias.toUpperCase(), data);
      if (response.statusCode == 200) {
        updatedProfile[profileKey] = {
          "alias": alias,
          "rpc_request_json": data,
        };
        try {
          final response = await _service.addDataToServerAttribute(
              currentGwDevice.uid!, {"profile_settings": updatedProfile});
          if (response.statusCode == 200) {
            _serverAttribute = updatedProfile;
          } else {
            _errorMessage = getErrorMessageFromThingsBoard(response.statusCode);
          }
        } catch (error) {
          _errorMessage = getErrorMessageFromException(error);
        } finally {
          _showApplyProfile = false;
          notifyListeners();
        }
      }
    }
  }

  bool isJson(String str) {
    try {
      json.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  void emptyDevice() {
    currentGwDevice.name = null;
    currentGwDevice.type = null;
    currentGwDevice.uid = null;
    _selectedProfile = '';
    _selectedProfileObj = {};
    pageLoader = false;
    _isLoading = false;
    _deviceList = [];
    _errorMessage = '';
    _showApplyProfile = false;
    _serverAttribute = {};
    _webSocketError = '';
    _channel;
    token = '';
  }

  String getStateOfDeviceForCurrentProfile(String type) {
    switch (selectedProfile.toUpperCase()) {
      case 'ARMED':
        return 'arm';
      case 'DISARM':
        return 'disarm';
      case 'SLEEP':
        return 'disarm';
      case 'AWAY':
        return 'disarm';
      case 'HOME':
        if (type == 'ms') {
          return 'disarm';
        }
        return 'arm';
      default:
        return '';
    }
  }

  Future getStateFromSharedAttribute() async {
    try {
      dynamic response = await _service
          .getSharedScopedAttributes(currentGwDevice.uid!, {"keys": "state"});

      log('getState -> response ${response.data[0]["value"]}');
      String value = response.data[0]["value"];
      if (response.statusCode == 200) {
        _selectedProfile = value;
        _selectedProfileObj = isJson(value) ? jsonDecode(value) : {};
        _showApplyProfile = false;
        _errorMessage = '';
        return response;
      }
    } catch (error) {
      log('catching error $error');
      _errorMessage = getErrorMessageFromException(error);
      showToast(_errorMessage);
    } finally {
      notifyListeners();
    }
  }

  void getRelatedDevices() async {
    try {
      Response response =
          await _service.findRelatedDevices(currentGwDevice.uid!);
      dynamic responseData = response.data['data'];
      if (response.statusCode == 200) {
        List<SensorDetails> listOfDevices =
            responseData.map<SensorDetails>((data) {
          String type = data['latest']['ATTRIBUTE']['type']['value'];
          SensorDetails deviceDetail = SensorDetails();
          deviceDetail.name = data['latest']['ENTITY_FIELD']['name']['value'];
          deviceDetail.label = data['latest']['ENTITY_FIELD']['label']['value'];
          deviceDetail.id = data['entityId']['id'];
          final value = data['latest']['ATTRIBUTE']['devIndex']['value'];
          final indexValue = value.split('/');
          deviceDetail.devIndex = value;
          deviceDetail.devIndexValue = indexValue[0];
          deviceDetail.uid = data['latest']['ATTRIBUTE']['deviceuid']['value'];
          deviceDetail.alert = data['latest']['TIME_SERIES']['alert']['value'];
          deviceDetail.state = selectedProfileObj.isEmpty
              ? getStateOfDeviceForCurrentProfile(type)
              : selectedProfileObj[indexValue[0]] == 1
                  ? 'arm'
                  : 'disarm';
          deviceDetail.type = type;
          deviceDetail.batteryStatus = '';

          return deviceDetail;
        }).toList();
        _deviceList = listOfDevices;
        _errorMessage = '';
      } else {
        _errorMessage = getErrorMessageFromThingsBoard(response.statusCode);
        showToast(_errorMessage);
      }
    } catch (error) {
      _errorMessage = getErrorMessageFromException(error);
      showToast(_errorMessage);
    } finally {
      _isPullToRefresh = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  refreshPage(WidgetRef ref) {
    _showApplyProfile = false;
    _isPullToRefresh = true;
    _isLoading = true;
    notifyListeners();
    getStateFromSharedAttribute().then((value) {
      getRelatedDevices();
      getServerAttribute();
    });
  }

  Future<void> addDevice(response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    GatewayQRResponse scannedDevice =
        GatewayQRResponse.fromJson(jsonDecode(response));
    await prefs.setString(
        'gatewayDetails',
        jsonEncode({
          'uid': scannedDevice.uid,
          'name': scannedDevice.name,
          'type': scannedDevice.type,
          'label': scannedDevice.label ?? ''
        }));
    currentGwDevice = GatewayQRResponse(
        uid: scannedDevice.uid,
        name: scannedDevice.name,
        type: scannedDevice.type,
        label: scannedDevice.label ?? '');
    log('GatewayName = ${currentGwDevice.name.toString()}');
    notifyListeners();
  }

  removeGatewayFromStore() {
    currentGwDevice = GatewayQRResponse(uid: '', name: '', type: '', label: '');
    notifyListeners();
  }

  Future<void> getServerAttribute() async {
    dynamic response =
        await _service.getServerScopedAttributes(currentGwDevice.uid!);

    try {
      if (response is Response && response.statusCode == 200) {
        final responseData = response.data as List;
        final filteredData = responseData
            .where((item) => item['key'] == 'profile_settings')
            .toList();
        if (filteredData.isNotEmpty) {
          _serverAttribute = filteredData[0]['value'];
        } else {
          _serverAttribute = {};
        }
        notifyListeners();
      } else {
        showToast(getErrorMessageFromThingsBoard(response.statusCode));
      }
    } catch (error) {
      showToast(getErrorMessageFromException(error));
    }
  }

  streamListener(BuildContext context, WidgetRef ref) {
    _channel.stream.listen((message) {
      log('message $message');
      String value = '';
      String activeStatus = '';
      String deviceId = '';
      Map getData = jsonDecode(message);
      _webSocketError = '';
      if (getData['cmdId'] == 6) {
        if (getData['data'] != null) {
          if (getData['data']['data'][0]['latest'].containsKey('ATTRIBUTE')) {
            value = getData['data']['data'][0]['latest']['ATTRIBUTE']['state']
                ['value'];
          } else if (getData['data']['data'][0]['latest']['TIME_SERIES']
              .containsKey('alert')) {
            value = getData['data']['data'][0]['latest']['TIME_SERIES']['alert']
                ['value'];
          }
          if (getData['data']['data'][0]['latest']
              .containsKey('SERVER_ATTRIBUTE')) {
            activeStatus = getData['data']['data'][0]['latest']
                ['SERVER_ATTRIBUTE']['active']['value'];
          }
        } else {
          if (getData['update'][0]['latest'].containsKey('ATTRIBUTE')) {
            value =
                getData['update'][0]['latest']['ATTRIBUTE']['state']['value'];
          } else if (getData['update'][0]['latest']['TIME_SERIES'] != null &&
              getData['update'][0]['latest']['TIME_SERIES']
                  .containsKey('alert')) {
            value =
                getData['update'][0]['latest']['TIME_SERIES']['alert']['value'];
          }
          log('hello ${getData['update'][0]['latest']['SERVER_ATTRIBUTE']}');
          if (getData['update'][0]['latest']['SERVER_ATTRIBUTE'] != null &&
              getData['update'][0]['latest']['SERVER_ATTRIBUTE']['active'] !=
                  null) {
            activeStatus = getData['update'][0]['latest']['SERVER_ATTRIBUTE']
                ['active']['value'];
          }
        }
        log('gatewayStatus $activeStatus');
        if (activeStatus.isNotEmpty) {
          _gatewayActiveStatus = convertStringToBool(activeStatus);
        }
        _selectedProfile = value;
        _selectedProfileObj = isJson(value) ? jsonDecode(value) : {};
        _showApplyProfile = false;
        notifyListeners();
        getRelatedDevices();
      } else if (getData['cmdId'] == 8) {
        log("update ${getData['update']}");
        if (getData['update'] != null) {
          if (getData['update'][0]['latest']['TIME_SERIES']
              .containsKey('alert')) {
            deviceId = getData['update'][0]['entityId']['id'];
            value =
                getData['update'][0]['latest']['TIME_SERIES']['alert']['value'];
            log("note --> $deviceId $value");
            for (SensorDetails device in _deviceList) {
              if (device.id == deviceId) {
                log('device.id -> ${device.id}');
                device.alert = value;
                notifyListeners();
                break;
              }
            }
          }
        }
      }
    }, onError: (error) async {
      log('webSocket error: $error');
      _webSocketError = 'Websocket is not connected';
      showToast('Error while connecting to devices');
      notifyListeners();

      await ref
          .read(loginController)
          .login(ref)
          .then((value) => initialize(context, ref));
    });
  }

  loginAgain(context, ref) {}
  String get selectedProfile => _selectedProfile;
  Map get selectedProfileObj => _selectedProfileObj;
  bool get isLoading => _isLoading;
  List<SensorDetails> get deviceList => _deviceList;
  String get errorMessage => _errorMessage;
  bool get showApplyProfile => _showApplyProfile;
  Map get serverAttribute => _serverAttribute;
  String get webSocketError => _webSocketError;
  String get editedDeviceLable => _editedDeviceLable;
  bool get isFabOpen => _isFabOpen;
  bool get isPullToRefresh => _isPullToRefresh;
  bool get startGlowing => _startGlowing;
  bool get gatewayActiveStatus => _gatewayActiveStatus;
}
