# ble_bloc

This project is a rough POC to test using FlutterBluePlus for BLE communication by using Bloc pattern. As a side dish, a basic bless server to try out simulating a BLE device.  
For now at least, it is Mobile device only (Android tested, should work for IOs but not tested).

## Getting Started

First start the bless server. Run:  
```
pip install bless  
python ./bless/bless_server.py
```

Then start the flutter debugger (in a real Android device).
