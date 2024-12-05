import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothScanState {
  List<ScanResult> results;
  BluetoothScanState({required this.results});
}

enum ScanEventTypes {START, STOP, CLEAR}
class ScanEvents {
  final ScanEventTypes type;
  ScanEvents(this.type);
}

// Scanner bloc, allows to scan for devices and get their info
class BLEScannerBloc extends Bloc<ScanEvents, BluetoothScanState> {
  late final StreamSubscription bluetoothScanStreamSubscription;

  BLEScannerBloc() : super(BluetoothScanState(results: [])) {
    setupListener();
    on<ScanEvents>((event, emit){
      if (event.type == ScanEventTypes.START) {
        FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      }
      if (event.type == ScanEventTypes.CLEAR) {
        emit(BluetoothScanState(results: []));
      }
    });
  }

  void setupListener() {
    FlutterBluePlus.scanResults.listen((state) {
      emit(BluetoothScanState(results: state));
    }).asFuture().then((a){
      print("AAAAA");
      print(a);
    });
  }

  @override
  Future<void> close() {
    bluetoothScanStreamSubscription.cancel();
    return super.close();
  }
}
