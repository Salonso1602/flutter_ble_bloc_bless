import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum BluetoothControllerState { ON, OFF, LOADING }

// Allows to control the state of bluetooth in the cellphone
class BTAdaptorBloc extends Cubit<BluetoothControllerState> {
  late final StreamSubscription bluetoothStreamSubscription;

  BTAdaptorBloc()
      : super(BluetoothControllerState.OFF) {
    monitorBluetooth();
  }

  StreamSubscription<BluetoothAdapterState> monitorBluetooth() {
    return bluetoothStreamSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      print("flutter_ble package streams $state");
      if (state == BluetoothAdapterState.on) {
        print("Cubit inside if statement $state");
        emitBluetoothOn();
      } else if (state == BluetoothAdapterState.off) {
        print("Inside if statement $state");
        emitBluetoothOff();
      } else if (state == BluetoothAdapterState.unknown) {
        print("Inside if statement $state");
        emitBluetoothStateLoading();
      }
    });
  }

  void emitBluetoothOn() {
    emit(BluetoothControllerState.ON);
  }

  void emitBluetoothOff() {
    emit(BluetoothControllerState.OFF);
  }

  void emitBluetoothStateLoading() {
    emit(BluetoothControllerState.LOADING);
  }

  @override
  Future<void> close() {
    bluetoothStreamSubscription.cancel();
    return super.close();
  }
}
