import 'package:ble_bloc/blocs/device_ble.bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEDeviceScreen extends StatelessWidget {
  const BLEDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final writeController = TextEditingController();
    final deviceBloc = context.watch<BLEDeviceBloc>();

    List<ButtonTheme> buildReadWriteNotifyButton(
        BluetoothCharacteristic characteristic) {
      List<ButtonTheme> buttons = <ButtonTheme>[];

      if (characteristic.properties.read) {
        buttons.add(
          ButtonTheme(
            minWidth: 10,
            height: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                child:
                    const Text('READ', style: TextStyle(color: Colors.black)),
                onPressed: () async {
                  deviceBloc.readCharacteristic(characteristic);
                },
              ),
            ),
          ),
        );
      }
      if (characteristic.properties.write) {
        buttons.add(
          ButtonTheme(
            minWidth: 10,
            height: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                child:
                    const Text('WRITE', style: TextStyle(color: Colors.black)),
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Write"),
                          content: Row(
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: writeController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text("Send"),
                              onPressed: () {
                                deviceBloc.writeToCharacteristic(characteristic,
                                    [int.parse(writeController.text)]);
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      });
                },
              ),
            ),
          ),
        );
      }
      if (characteristic.properties.notify) {
        buttons.add(
          ButtonTheme(
            minWidth: 10,
            height: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                child:
                    const Text('NOTIFY', style: TextStyle(color: Colors.black)),
                onPressed: () async {
                  deviceBloc.listenCharacteristic(characteristic);
                },
              ),
            ),
          ),
        );
      }
      return buttons;
    }

    List<Widget> buildConnectDeviceView(
        BuildContext ctx, BluetoothDeviceBlocState state) {
      List<Widget> containers = <Widget>[];

      for (BluetoothService service in state.deviceServices) {
        List<Widget> characteristicsWidget = <Widget>[];

        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          characteristicsWidget.add(
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(characteristic.uuid.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      ...buildReadWriteNotifyButton(characteristic),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                        'Value: ${state.lastReading}'),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            ),
          );
        }
        containers.add(
          ExpansionTile(
              title: Text(service.uuid.toString()),
              children: characteristicsWidget),
        );
      }
      containers.add(ListTile(
        title: state.deviceState == BLEDeviceStates.connected
            ? ElevatedButton(
                onPressed: () {
                  deviceBloc
                      .add(BLEDeviceEvents(BLEDeviceEventTypes.disconnect));
                },
                child: const Text("Disconnect"))
            : ElevatedButton(
                onPressed: () {
                  deviceBloc.add(BLEDeviceEvents(BLEDeviceEventTypes.connect));
                },
                child: const Text("Connect")),
      ));

      return containers;
    }

    return BlocBuilder<BLEDeviceBloc, BluetoothDeviceBlocState>(
        builder: (ctx, state) {
      return ListView(
        padding: const EdgeInsets.all(8),
        children: buildConnectDeviceView(ctx, state),
      );
    });
  }
}
