import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEDeviceList extends StatelessWidget {
  final List<ScanResult> deviceList;
  
  final Function(BluetoothDevice)? onDeviceSelect;

  const BLEDeviceList(this.deviceList, {super.key, this.onDeviceSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Devices: ${deviceList.length.toString()}",
          style: Theme.of(context).textTheme.displaySmall,
        ),
        deviceList.isNotEmpty
            ? Expanded(
                child: ListView.builder(
                    itemCount: deviceList.length,
                    itemBuilder: (ctx, index) => ListTile(
                          title: deviceList[index].device.advName != "" ? Text(deviceList[index].device.advName) : const Text("Unknown BLE Device"),
                          subtitle: Text(deviceList[index].device.remoteId.str),
                          onTap: () {if (onDeviceSelect != null) {onDeviceSelect!(deviceList[index].device);}},
                        )),
              )
            : const Center(
                child: Text("No devices found"),
              )
      ],
    );
  }
}
