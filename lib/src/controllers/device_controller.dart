// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:developer';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:walk/src/constants/bt_constants.dart';
import 'package:walk/src/constants/wifi_enum.dart';

class DeviceController extends ChangeNotifier {
  /// stores scanned devices
  List<BluetoothDevice> _scannedDevices = [];

  bool isBluetoothOn = false;

  /// stores connected devices
  List<BluetoothDevice> _connectedDevices = [];

  BluetoothDevice? _connectedDevice;

  BluetoothDevice? get connectedDevice => _connectedDevice;

  void clearConnectedDevice() {
    _connectedDevice = null;
    notifyListeners();
  }

  void updateConnectedDevice(BluetoothDevice device) {
    _connectedDevice = device;
    notifyListeners();
  }

  /// stores characterisitcs of devices
  List<BluetoothCharacteristic> _characteristics = [];

  /// stores services of devices
  List<BluetoothService> _services = [];

  bool isConnecting = false;

  /// checks whether wifi credentials are saved on or not
  int _wifiProvisioned = 0;

  /// getting scanned devices
  List<BluetoothDevice> get getScannedDevices => _scannedDevices;

  /// getting connected devices
  List<BluetoothDevice> get getConnectedDevices => _connectedDevices;

  ///Created a map of characteristics
  Map<Guid, BluetoothCharacteristic> _characteristicMap = {};

  ///Getter function to get the characteristic map
  Map<Guid, BluetoothCharacteristic> get characteristicMap =>
      _characteristicMap;

  ///
  bool _isListening = false;
  bool get listenStatus => _isListening;

  Set<String> _info = {};

  /// Stores value for remaining battery
  int get clientBatteryRemaining {
    double seconds = double.parse(_rbattC);
    double minutes = seconds / 60;
    return minutes.floor();
  }

  int get serverBatteryRemaining {
    double seconds = double.parse(_rbattS);
    double minutes = seconds / 60;
    return minutes.floor();
  }

  ///outputs the set<String> which contains the information obtained from the device after sending the "info" command to the device;
  Set<String> get info => _info;

  /// Names for buttons in device controller page
  List<String> buttonNames = ['SOS', 'RES', 'RSTF', 'RPRV'];

  void clearInfo() {
    /// Clears the _info set so that new information can be stored , without older one being present creating ambiguity
    _info.clear();
    notifyListeners();
  }

  bool isScanning = false;
  bool get scanStatus => isScanning;
  void changeScanStatus(bool status) {
    isScanning = status;
    notifyListeners();
  }

  double _freqValue = 0.3;
  double _modeValue = -1;
  double _magSValue = 0;
  double _magCValue = 0;

  double get frequencyValue {
    return _freqValue;
  }

  double get modeValue {
    return _modeValue;
  }

  double get magSValue {
    return _magSValue;
  }

  double get magCValue {
    return _magCValue;
  }

  void setmodeValue(double value) {
    _modeValue = value;
    notifyListeners();
  }

  void setmagSValue(double value) {
    _magSValue = value;
    notifyListeners();
  }

  void setmagCValue(double value) {
    _magCValue = value;
    notifyListeners();
  }

  void setfreqValue(double value) {
    _freqValue = value;
    notifyListeners();
  }

  /// Getting wifi provision status
  int get wifiProvisionStatus => _wifiProvisioned;

  int _clientStatus = 0;

  int get clientStatus => _clientStatus;

  /// Status of battery
  bool _batteryInfoStatus = false;

  ///  Getting status of battery
  bool get batteryInfoStatus => _batteryInfoStatus;

  /// Stores server[L] battery value
  String _batteryS = "1.0";

  /// Stores client[R] battery value
  String _batteryC = "1.0";

  /// Stores client[R] remaining battery value
  String _rbattC = "0000";

  /// Stores server[L] remaining battery value
  String _rbattS = "0000";

  ///getting the context for dialog box
  BuildContext? homeContext;

  ///Intialising Location library
  Location location = Location();

  /// Battery value for client[R]
  double get battC {
    return double.parse(_batteryC);
  }

  /// Battery value for server[L]
  double get battS {
    return double.parse(_batteryS);
  }

  // //Constructor to start scanning as soon as an object of Device Controller is inititated in the runApp
  DeviceController(
      {bool performScan = false, bool checkPrevconnection = false}) {
    askForPermission();
    if (checkPrevconnection) {
      checkPrevConnection();
    }
  }

  ///Handles the bluetooth and location permission for both devices, below and above android version 12;
  Future askForPermission() async {
    // initializes the flutter blue package

    if (await Permission.location.isDenied ||
        await Permission.bluetooth.isDenied) {
      await Permission.location.request();
      await Permission.bluetooth.request();
      await Permission.nearbyWifiDevices.request();
      await Permission.bluetoothAdvertise.request();
      await Permission.bluetoothConnect.request();
      await Permission.bluetoothScan.request();
      log("asking for permission complete");
      if (await Permission.bluetooth.isGranted &&
          await Permission.location.isGranted &&
          homeContext != null) {
        turnBluetoothOn(homeContext!);

        await location
            .serviceEnabled(); // check whether the service is enabled or not
      }
    } else if (await FlutterBluePlus.adapterState.first !=
            BluetoothAdapterState.on ||
        !await location.serviceEnabled() && homeContext != null) {
      await location.requestService(); // request to on location service
      await BluetoothEnable.enableBluetooth; // enables bluetooth
      isBluetoothOn = true;
      notifyListeners();
    }
  }

  /// Turning on Bluetooth from within the app
  Future<void> turnBluetoothOn(BuildContext context) async {
    try {
      String dialogTitle = "Turn on Bluetooth and location?";
      bool displayDialogContent = true;
      String dialogContent =
          "This app requires Bluetooth and Location turned on to connect to a device.";
      String cancelBtnText = "Nope";
      String acceptBtnText = "Sure";
      double dialogRadius = 10.0;
      bool barrierDismissible = true; //

      // // Custom Dialog box for turning On Bluetooth
      await BluetoothEnable.customBluetoothRequest(
              context,
              dialogTitle,
              displayDialogContent,
              dialogContent,
              cancelBtnText,
              acceptBtnText,
              dialogRadius,
              barrierDismissible)
          .then((value) {
        log('customBT request: $value');
      });
    } catch (e) {
      log(' error: $e');
    }
  }

  //// Used to scan the devices and add the scanned devices to the scannedDevices list;
  Future<void> startDiscovery(Function onConnect) async {
    try {
      FlutterBluePlus.setLogLevel(LogLevel.verbose);
      await askForPermission();
      _scannedDevices.clear();

      isConnecting =
          false; ////Reset the connecting flag so that when the scan results come up they can be connected to if needed

      isScanning = true;
      notifyListeners();
      FlutterBluePlus.scan(
        timeout: const Duration(seconds: 10),
        withServices: [
          Guid("0000acf0-0000-1000-8000-00805f9b34fb"),
        ],

        ///timeout can be ignored , to keep the scan running continuosly
        allowDuplicates: false,
      ).listen((scanResult) async {
        print(scanResult.toString());
        if (!isConnecting) {
          ////If the device is not being connected to then only try and connect to it
          await connectToDevice(scanResult.device, onConnect);
        }
      }, onDone: () {
        isScanning = false;
        notifyListeners();
      }).onError((error) {
        log('startDiscover() error: $error');
      });
    } catch (e) {
      log("Error in startDiscovery$e");
    }
  }

  ///Checks already connected devices and highlights the respective device's tile in the home screen.
  Future checkPrevConnection() async {
    log("check prev called ");
    _connectedDevices = await FlutterBluePlus.connectedSystemDevices;
    if (_connectedDevices.isNotEmpty) {
      _connectedDevice = _connectedDevices[0];
      await connectToDevice(_connectedDevice!, () {});
    }
  }

  ///Used to connect to a device and update connectedDevices list
  Future connectToDevice(BluetoothDevice device, Function onConnect) async {
    try {
      bool gotServices = false;
      isConnecting = true;
      notifyListeners();
      Fluttertoast.showToast(msg: "Connecting to ${device.localName}");
      await device.connect(
        autoConnect: false,
      );

      await HapticFeedback.vibrate();
      Fluttertoast.showToast(msg: "Connected to ${device.localName}");
      gotServices = await discoverServices(device);
      gotServices ? _connectedDevice = device : null;
      notifyListeners();
      onConnect();
    } catch (e) {
      log(e.toString());
      Fluttertoast.showToast(msg: "Could not connect ");
      device.disconnect();
      _connectedDevice = null;
      notifyListeners();
    }
  }

  ///Handles the disconnection procedure
  Future disconnectDevice(BluetoothDevice device) async {
    try {
      Fluttertoast.showToast(msg: "Disconnecting ");
      await device.disconnect();
      await HapticFeedback.mediumImpact();
      Fluttertoast.showToast(msg: "Disconnected successfully");
      _connectedDevice = null;

      ///Removing the device for the connectedDevices list
      _services.clear();

      ///Clearing the services of the devices
      _characteristics.clear();

      /// Clearing the characteristics obtained from the device
      notifyListeners();
    } catch (e) {
      log("Error in disconnecting ${e.toString()}");
      Fluttertoast.showToast(msg: "Could not disconnect :$e");
    }
  }

  ///Used to discover the services and characteristics;
  ///Also flood services and characteristics into a map
  Future<bool> discoverServices(BluetoothDevice device) async {
    try {
      _services = await device.discoverServices();
      _characteristicMap.clear();
      _characteristics = _services
          .where((element) => element.uuid == SERVICE)
          .first
          .characteristics;

      for (var element in _characteristics) {
        characteristicMap.putIfAbsent(element.uuid, () => element);
      }
      notifyListeners();
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: "Unexpected error in getting the services");
      log("Discover services $e");
      return false;
    }
  }

  ///Used to send any message to the device basically command , it is sent in ASCII format
  Future sendToDevice(String command, Guid characteristic) async {
    try {
      ///Checking if the bluetooth is on
      if (await FlutterBluePlus.adapterState.first ==
          BluetoothAdapterState.on) {
        log(command);

        BluetoothCharacteristic? writeTarget =
            _characteristicMap[WRITECHARACTERISTICS];

        ///Searching for the actual characteristic by the GUID of the characteristic known
        await writeTarget!.write(command.codeUnits);

        ///Converting the command to ASCII then sending
        await HapticFeedback.mediumImpact();
        if (command.contains(RegExp(r"MODE"))) {
          Fluttertoast.showToast(msg: "Mode changed ! ");
        }
      } else {
        Fluttertoast.showToast(msg: "Seems like bluetooth is turned off ");
      }
    } catch (e) {
      log("error in sending message $e");
      Fluttertoast.showToast(msg: "Unexpected error in sending command ");
    }
  }

  ///Function used to get battery values
  Future<bool> getBatteryPercentageValues() async {
    try {
      BluetoothCharacteristic? clientTarget =
          _characteristicMap[BATTERY_PERCENTAGE_CLIENT];
      BluetoothCharacteristic? serverTarget =
          _characteristicMap[BATTERY_PERCENTAGE_SERVER];

      var clientResponse = await clientTarget!.read();

      ///divided by 1000
      var serverResponse = await serverTarget!.read();
      String tempBattC = String.fromCharCodes(clientResponse);
      String tempBattS = String.fromCharCodes(serverResponse);
      if (double.parse(tempBattS) > 100 || double.parse(tempBattS) < 0) {
        log("Server Battery Percentage Out of Limit , modifying ....");
        if (double.parse(tempBattS) > 100) {
          _batteryS = "100";
          notifyListeners();
        } else {
          _batteryS = "0";
          notifyListeners();
        }
      }
      if (double.parse(tempBattC) > 100 || double.parse(tempBattC) < 0) {
        log("Client battery percentage Out of Limit , modifying ....");
        if (double.parse(tempBattC) > 100) {
          _batteryC = "100";
          notifyListeners();
        } else {
          _batteryC = "0";
          notifyListeners();
        }
        _batteryInfoStatus = true;
      } else {
        log("Battery values in range");
        log("CLIENT BATTERY PERCENTAGE is $tempBattC");
        log("SERVER BATTERY PERCENTAGE is $tempBattS");
        _batteryC = tempBattC;
        _batteryS = tempBattS;
        _batteryInfoStatus = true;
        notifyListeners();
      }
      _batteryInfoStatus = true;
      return true;
    } catch (e) {
      log(e.toString());
      log("Something went wrong while getting batteryValues.");
      return false;
    }
  }

  Future<void> getFrequencyValues() async {
    try {
      BluetoothCharacteristic? serverTarget =
          _characteristicMap[FREQUENCY_SERVER];

      var serverResponse = await serverTarget!.read();
      var tempFreq = double.parse(String.fromCharCodes(serverResponse));
      if (tempFreq < 0.3) {
        _freqValue = 0.3;
        notifyListeners();
      }
      if (tempFreq > 2) {
        _freqValue = 2;
        notifyListeners();
      } else {
        _freqValue = tempFreq;
        notifyListeners();
      }

      log("SERVER Frequency Value is ${String.fromCharCodes(serverResponse)}");
    } catch (e) {
      log(e.toString());
      log("Something went wrong while getting frequencyValues.");
    }
  }

  Future<void> getMagnitudeValues() async {
    try {
      BluetoothCharacteristic? serverTarget =
          _characteristicMap[MAGNITUDE_SERVER];
      BluetoothCharacteristic? clientTarget =
          _characteristicMap[MAGNITUDE_CLIENT];

      var serverResponse = await serverTarget!.read();
      var clientResponse = await clientTarget!.read();
      var serverTempMagnitude = double.parse(
        String.fromCharCodes(serverResponse),
      );
      var clientTempMagnitude = double.parse(
        String.fromCharCodes(clientResponse),
      );
      if (serverTempMagnitude < 0) {
        _magSValue = 0;
        notifyListeners();
      }
      if (serverTempMagnitude > 4) {
        _magSValue = 4;
        notifyListeners();
      } else {
        _magSValue = serverTempMagnitude;
        notifyListeners();
      }

      if (clientTempMagnitude < 0) {
        _magCValue = 0;
        notifyListeners();
      }
      if (clientTempMagnitude > 4) {
        _magCValue = 4;
        notifyListeners();
      } else {
        _magCValue = clientTempMagnitude;
        notifyListeners();
      }

      log("SERVER Magnitude Value is ${String.fromCharCodes(serverResponse)}");
      log("Client Magnitude Value is ${String.fromCharCodes(clientResponse)}");
    } catch (e) {
      log(e.toString());
      log("Something went wrong while getting magnitudeValues.");
    }
  }

  ///Function to get the wifiProvisioned Status
  Future<int> getWifiProvisionedStatus() async {
    try {
      BluetoothCharacteristic? clientTarget =
          _characteristicMap[PROVISIONED_CLIENT];
      BluetoothCharacteristic? serverTarget =
          _characteristicMap[PROVISIONED_SERVER];

      var clientResponse = await clientTarget!.read();
      var serverResponse = await serverTarget!.read();

      if (String.fromCharCodes(clientResponse) == "1" &&
          String.fromCharCodes(serverResponse) == "1") {
        _wifiProvisioned = WifiStatus.PROVISIONED.index;
        notifyListeners();
      }
      if (String.fromCharCodes(clientResponse) == "-1" ||
          String.fromCharCodes(serverResponse) == "-1") {
        _wifiProvisioned = WifiStatus.PROCESSING.index;
        log("hgererer");
        notifyListeners();
      }
      if (String.fromCharCodes(clientResponse) == "0" ||
          String.fromCharCodes(serverResponse) == "0") {
        log("elseee");
        _wifiProvisioned = WifiStatus.NOTPROVISONED.index;
        notifyListeners();
      }

      log("Client provisioned status is ${String.fromCharCodes(clientResponse)}");
      log("Server provisioned status is ${String.fromCharCodes(serverResponse)}");
      log("Wifi provisioned $_wifiProvisioned");
      return _wifiProvisioned;
    } catch (e) {
      log(e.toString());
      log("Something went wrong while getting wifi provisioned status");
      return _wifiProvisioned;
    }
  }

  Future<void> getBatteryRemaining() async {
    try {
      BluetoothCharacteristic? clientTarget =
          _characteristicMap[BATTERY_TIME_REMAINING_CLIENT];
      BluetoothCharacteristic? serverTarget =
          _characteristicMap[BATTERY_TIME_REMAINING_SERVER];

      var clientResponse = await clientTarget!.read();
      var serverResponse = await serverTarget!.read();

      _rbattC = String.fromCharCodes(clientResponse);
      _rbattS = String.fromCharCodes(serverResponse);
      notifyListeners();

      log("Server battery remaining $_rbattS");
      log("Client battery reamining $_rbattC");
    } catch (e) {
      log(e.toString());
      log("Something went wrong while getting battery left values ");
    }
  }

  Future<void> getClientStatusStream() async {
    ////actually this is just wifi provisioned status charac , listening for status here only!

    BluetoothCharacteristic? target = _characteristicMap[PROVISIONED_CLIENT];
    Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        try {
          var devices = getConnectedDevices;
          if (devices.isNotEmpty) {
            var response = await target!.read();
            var result = String.fromCharCodes(response);
            log("Client Status Result is $result");
          } else {
            timer.cancel();
          }
        } catch (e) {
          log("in stream ${e.toString()}");
          // throw Exception("Reading from the device clashed!! , Retrying");
        }
      },
    );
  }

  ///ONLY FOR NEWTON'S TESTING NOT TO BE USED IN ACTUAL APPLICATION
  Future<String> getRawBatteryNewton() async {
    try {
      BluetoothCharacteristic? target =
          _characteristicMap[RAW_BATTERY_VALUE_SERVER];
      var response = await target!.read();
      return String.fromCharCodes(response);
    } catch (e) {
      log(e.toString());
      return "error occurred";
    }
  }

  Future<bool> refreshBatteryValues() async {
    bool refreshed;
    refreshed = await getBatteryPercentageValues();
    if (refreshed) {
      return true;
    }
    return false;
  }
}
