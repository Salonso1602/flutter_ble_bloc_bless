import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum BLEDeviceStates { none, connecting, connected, disconnected }

class BluetoothDeviceBlocState {
  List<int> lastReading = [];
  BluetoothDevice? device;
  BLEDeviceStates deviceState;
  BluetoothDeviceBlocState(
      {this.device, this.deviceState = BLEDeviceStates.none, this.lastReading = const []});

  List<BluetoothService> get deviceServices {
    return device != null && deviceState == BLEDeviceStates.connected
        ? device!.servicesList
        : [];
  }
}

enum BLEDeviceEventTypes {
  setDevice,
  connect,
  write,
  read,
  subscribe,
  disconnect,
  clear
}

class BLEDeviceEvents {
  final BLEDeviceEventTypes type;
  final BluetoothDevice? device;
  BLEDeviceEvents(this.type, {this.device});
}

class BLEDeviceBloc extends Bloc<BLEDeviceEvents, BluetoothDeviceBlocState> {
  late final StreamSubscription? bluetoothStateSubscription;
  late final Map<Guid, StreamSubscription> charNotifyStreams = {};

  BLEDeviceBloc() : super(BluetoothDeviceBlocState()) {
    on<BLEDeviceEvents>((event, emit) async {
      if (event.type == BLEDeviceEventTypes.setDevice) {
        emit(BluetoothDeviceBlocState(
            device: event.device, deviceState: BLEDeviceStates.disconnected));
      }
      if (event.type == BLEDeviceEventTypes.connect) {
        emit(BluetoothDeviceBlocState(
            deviceState: BLEDeviceStates.connecting, device: state.device));
        try {
          print("START SCAN");
          await state.device?.connect(timeout: const Duration(seconds: 15));
          print("START Services");
          await state.device?.discoverServices();
          emit(BluetoothDeviceBlocState(
              deviceState: BLEDeviceStates.connected, device: state.device));
        } on Exception catch (e) {
          // ignore: avoid_print
          print("TIMEOUT ${e.toString()}");
          emit(BluetoothDeviceBlocState(
              deviceState: BLEDeviceStates.disconnected));
        }
      }
      if (event.type == BLEDeviceEventTypes.clear) {
        emit(BluetoothDeviceBlocState(deviceState: BLEDeviceStates.none));
      }
      if (event.type == BLEDeviceEventTypes.disconnect) {
        print("DISCONNECT");
        state.device?.disconnect();
        emit(BluetoothDeviceBlocState(
            deviceState: BLEDeviceStates.disconnected, device: state.device));
      }
    });
  }

  void setupListener() {
    bluetoothStateSubscription = state.device?.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        add(BLEDeviceEvents(BLEDeviceEventTypes.disconnect));
      }
      if (state == BluetoothConnectionState.connected) {
        this.state.device?.discoverServices();
        this.state.device?.onServicesReset.listen((_) {
          this.state.device?.discoverServices();
        });
      }
    });
  }

  void writeToCharacteristic(
      BluetoothCharacteristic characteristic, List<int> payload) {
    try {
      characteristic.write(payload);
    } on FlutterBluePlusException {
      add(BLEDeviceEvents(BLEDeviceEventTypes.disconnect));
    }
  }

  void readCharacteristic(BluetoothCharacteristic characteristic) async {
    StreamSubscription? sub;
    try {
      sub = characteristic.lastValueStream.listen((value) {
        emit(BluetoothDeviceBlocState(device: state.device, deviceState: state.deviceState, lastReading: value));
      });
      await characteristic.read();
    } on PlatformException {
      add(BLEDeviceEvents(BLEDeviceEventTypes.disconnect));
    } on FlutterBluePlusException {
      add(BLEDeviceEvents(BLEDeviceEventTypes.disconnect));
    }
    sub?.cancel();
  }

  void listenCharacteristic(BluetoothCharacteristic characteristic) async {
    try {
      StreamSubscription? charSub = charNotifyStreams[characteristic.characteristicUuid];
      if(charSub != null) {
        await charSub.cancel();
      }
      charNotifyStreams[characteristic.characteristicUuid] =
          characteristic.lastValueStream.listen((value) {
        print("NOTIFY:");
        print(value);
      });
      await characteristic.setNotifyValue(true);
    } on Exception {
      print("ERROR NOTI");
    }
  }

  @override
  Future<void> close() {
    state.device?.disconnect();
    bluetoothStateSubscription?.cancel();
    for (StreamSubscription sub in charNotifyStreams.values) {
      sub.cancel();
    }
    return super.close();
  }
}
