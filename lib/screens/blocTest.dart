import 'package:ble_bloc/blocs/device_ble.bloc.dart';
import 'package:ble_bloc/blocs/scan_ble.bloc.dart';
import 'package:ble_bloc/screens/ble_list.widget.dart';
import 'package:ble_bloc/screens/device.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocTest extends StatefulWidget {
  const BlocTest({super.key});

  @override
  State<BlocTest> createState() => _BlocTestState();
}

class _BlocTestState extends State<BlocTest> {
  @override
  Widget build(BuildContext context) {
    final cub = context.read<BLEScannerBloc>();
    final devc = context.watch<BLEDeviceBloc>();
    return Scaffold(
      appBar: AppBar(
        title: Text(devc.state.device?.advName ?? "Select one"),
        actions: devc.state.deviceState == BLEDeviceStates.none ? [
          OutlinedButton(
              onPressed: () {
                cub.add(ScanEvents(ScanEventTypes.START));
              },
              child: const Text("scan")),
          OutlinedButton(
              onPressed: () {
                cub.add(ScanEvents(ScanEventTypes.CLEAR));
              },
              child: const Text("clear"))
        ] : [
          OutlinedButton(
              onPressed: () {
                devc.add(BLEDeviceEvents(BLEDeviceEventTypes.clear));
              },
              child: const Text("go back")),
        ],
      ),
      body:
      devc.state.deviceState == BLEDeviceStates.none ?  
      BlocBuilder<BLEScannerBloc, BluetoothScanState>(
          builder: (ctx, state) {
        return BLEDeviceList(
          state.results,
          onDeviceSelect: (btDevice) {
            devc.add(BLEDeviceEvents(BLEDeviceEventTypes.setDevice,
                device: btDevice));
          },
        );
      }) : 
      BLEDeviceScreen(),
    );
  }
}
