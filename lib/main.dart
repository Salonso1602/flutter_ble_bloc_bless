import 'package:ble_bloc/blocs/adaptor_ble.bloc.dart';
import 'package:ble_bloc/blocs/device_ble.bloc.dart';
import 'package:ble_bloc/blocs/scan_ble.bloc.dart';
import 'package:ble_bloc/screens/blocTest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 206, 0, 0)),
        useMaterial3: true,
      ),
      home: MultiBlocProvider(providers: [
        BlocProvider(create: (_) => BTAdaptorBloc()),
        BlocProvider(create: (_) => BLEDeviceBloc()),
        BlocProvider(create: (_) => BLEScannerBloc())
      ], child: const BlocTest()),
    );
  }
}
