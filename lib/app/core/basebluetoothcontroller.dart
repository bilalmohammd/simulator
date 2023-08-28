import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class BaseBluetoothController extends GetxController{

  final flutterReactiveBle = FlutterReactiveBle();
  final devicesList = <DiscoveredDevice>[].obs;
  /// var for bluetooth connectivity check
  var isConnected = false.obs;
  var scanIsInProgress = false.obs;
  var connectionInProgress = false.obs;
  QualifiedCharacteristic? qualifiedCharacteristic;
  var isSubscribeToCharacteristic = false;


  StreamSubscription? _subscription;
  DiscoveredDevice? selectedDevice;
  StreamSubscription<ConnectionStateUpdate>? _connection;
  var subscribeOutput = "".obs;

  /// bluetooth commands for scanning nearby bluetooth devices
  // Future<void> startBleScan(List<Uuid> serviceIds) async {
  //   if (_connection != null) {
  //     _connection!.cancel();
  //     if (_subscription !=       null) {
  //       _subscription!.cancel();
  //     }
  //   }
  //   devicesList.clear();
  //   scanIsInProgress.value = true;
  //   _subscription = flutterReactiveBle.scanForDevices(withServices: serviceIds).listen((device) {
  //
  //     final knownDeviceIndex = devicesList.indexWhere((d) => d.id == device.id);
  //     if (knownDeviceIndex >= 0) {
  //       devicesList[knownDeviceIndex] = device;
  //     } else {
  //       // if (device.name.startsWith('RN')) {
  //       devicesList.add(device);
  //       // }
  //     }
  //
  //   }, onError: (Object e) => print('Device scan fails with error: $e'));
  // }

  Future<void> startBleScan(List<Uuid> serviceIds) async {
    if (_connection != null) {
      _connection!.cancel();
      if (_subscription != null) {
        _subscription!.cancel();
      }
    }
    devicesList.clear();
    scanIsInProgress.value = true;
    _subscription = flutterReactiveBle.scanForDevices(withServices: serviceIds).listen((device) {
      _checkAndAddConnectableDevice(device);
    }, onError: (Object e) => print('Device scan fails with error: $e'));
  }

  void _checkAndAddConnectableDevice(DiscoveredDevice device) {
    // You might need to adjust this check based on your use case
    if (device.name != null && device.name.isNotEmpty) {
      final knownDeviceIndex = devicesList.indexWhere((d) => d.id == device.id);
      if (knownDeviceIndex >= 0) {
        devicesList[knownDeviceIndex] = device;
      } else {
        devicesList.add(device);
      }
    }
  }
  /// stop bluetooth scaning
  Future<void> stopBleScan() async {
    scanIsInProgress.value = false;
    await _subscription?.cancel();
    _subscription = null;
  }

  /// when bluetooth connected then it automatically stop
  Future<void> stopWhileScan() async {
    scanIsInProgress.value = false;
    isConnected.value = false;
    await _subscription?.cancel();
    _subscription = null;
  }
  /// for bluetooth connecting progress
  stopConnectionProgress() async {
    scanIsInProgress.value = false;
    connectionInProgress.value = false;
    isConnected.value = false;

    if (_subscription != null) {
      await _subscription?.cancel();
      _subscription = null;
    }
  }
  /// check connection state of bluetooth connectivity
  Future<void> connectBleDevice(DiscoveredDevice device) async {
    connectionInProgress.value = true;

    _connection = flutterReactiveBle
        .connectToDevice(
      id: device.id,
      connectionTimeout: const Duration(seconds: 30),
    )
        .listen((update) {
      print('ConnectionState for device ${device.id} : ${update.connectionState}');
      if (update.connectionState == DeviceConnectionState.connected) {
        flutterReactiveBle.discoverServices(device.id).then((list) => getBleDiscoveredServices(list, device));
        flutterReactiveBle.requestMtu(deviceId: device.id, mtu: 168).then((value) => print(">>>>>>>> mut value ${value!}"));
        scanIsInProgress.value = false;
        selectedDevice = device;
        // resetAllValues();
      } else if (update.connectionState == DeviceConnectionState.connecting) {
        print(DeviceConnectionState.connecting);
      }
    }, onError: (Object error) {
      print('Connecting to device ${device.id} resulted in error ${error}');
    });
  }
  /// while connecting we can disconnect if it taking longer time
  Future<void> disconnectWhileScan() async {
    if (_connection != null) {
      await _connection!.cancel();
      // actualFilterDataArray.clear();
      isConnected.value = false;
      scanIsInProgress.value = false;
      connectionInProgress.value = false;
      // dignosysDataCollection.clear();
      // resetAllValues();
    }
  }
  /// disconnect bluetooth device
  Future<void> bleDisconnect() async {
    if (selectedDevice != null) {
      if (selectedDevice!.name.endsWith("Simulator")) {
        // stopSimulation4RealTimeInstaParam();
      } else {
        if (_connection != null) {
          await _connection!.cancel();
          // actualFilterDataArray.clear();
        }
      }
      isConnected.value = false;
      scanIsInProgress.value = false;
      connectionInProgress.value = false;
      // dignosysDataCollection.clear();
    } else {
      // resetAllValues();
    }
  }
  getBleDiscoveredServices(List<DiscoveredService> services, DiscoveredDevice device) {
    services.forEach((element) {
      element.characteristics.forEach((element) {
        if (element.isWritableWithResponse && element.isNotifiable && element.isIndicatable) {
          qualifiedCharacteristic =
              QualifiedCharacteristic(serviceId: element.serviceId, characteristicId: element.characteristicId, deviceId: device.id);

          connectionInProgress.value = false;
          isConnected.value = true;
          // dignosysDataCollection.clear();
          List<int> bufferData = [];
          /// check data length and store all value in bufferData list
          flutterReactiveBle.subscribeToCharacteristic(qualifiedCharacteristic!).listen((data) {
            if (data.length == 155 || data[0] == 0x4) {
              bufferData = data.toList(growable: true);
            } else if (data.length == 17 || data.length == 14  || data.length == 74) {
              bufferData = bufferData + data.toList(growable: true);

              isSubscribeToCharacteristic = true;

              subscribeOutput.value = bufferData.toString();

              print(subscribeOutput.value);

              // dignosysDataCollection.add(DiagnosisDataValue(subscribeOutput.value, "Received"));

              // var dataHexValues = bufferData.map((e) => DataConverterUtil.toPaddedHex(e));
              /// check first two bytes of ble data response
              // var commandResponseHeader = dataHexValues.elementAt(0) + dataHexValues.elementAt(1);

              // print(">>>>commandResponseHeader>>>>> :  $commandResponseHeader");

              // bleResponseParsing(commandResponseHeader, dataHexValues);

              bufferData.clear();
            } else {
              subscribeOutput.value = data.toList(growable: true).toString();
              // isSubscribeToCharacteristic = true;

              print(subscribeOutput.value);

              // dignosysDataCollection.add(DiagnosisDataValue(subscribeOutput.value, "Received"));

              // var dataHexValues = data.map((e) => DataConverterUtil.toPaddedHex(e));

              // var commandResponseHeader = dataHexValues.elementAt(0) + dataHexValues.elementAt(1);

              // print(">>>>commandResponseHeader>>>>> :  $commandResponseHeader");

              // bleResponseParsing(commandResponseHeader, dataHexValues);
            }
          }, onError: (dynamic error) {
            print(error.toString());
            // dignosysDataCollection.add(DiagnosisDataValue(error.toString(), "--Error--"));
          });
        }
      });
    });
  }

  selectSimulatorDevice(DiscoveredDevice device) {
    selectedDevice = device;
  }

}