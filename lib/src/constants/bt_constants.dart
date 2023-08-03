// ignore_for_file: non_constant_identifier_names
//ae is Client
//ab is Server

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

Guid SERVICE = Guid("0000abf0-0000-1000-8000-00805f9b34fb");
Guid WRITECHARACTERISTICS = Guid("0000abf1-0000-1000-8000-00805f9b34fb");

////SERVER SIDE CHARACTERISTICS
Guid MAGNITUDE_SERVER = Guid("0000adf8-0000-1000-8000-00805f9b34fb");
Guid TAG_SERVER = Guid("0000adf7-0000-1000-8000-00805f9b34fb");
Guid FREQUENCY_SERVER = Guid("0000adf9-0000-1000-8000-00805f9b34fb");
Guid BATTERY_VOLTAGE_SERVER = Guid("0000adf1-0000-1000-8000-00805f9b34fb");
Guid CHARGERCONN_SERVER = Guid("0000adff-0000-1000-8000-00805f9b34fb");
Guid UUID_SERVER = Guid("0000adf4-0000-1000-8000-00805f9b34fb");
Guid PROVISIONED_SERVER = Guid("0000adf6-0000-1000-8000-00805f9b34fb");

Guid BATTERY_PERCENTAGE_SERVER = Guid("0000adf3-0000-1000-8000-00805f9b34fb");
Guid BATTERY_TIME_REMAINING_SERVER =
    Guid("0000adf2-0000-1000-8000-00805f9b34fb");

Guid RAW_BATTERY_VALUE_SERVER = Guid("0000ae01-0000-1000-8000-00805f9b34fb");

////CLIENT SIDE CHARACTERISTICS

Guid TAG_CLIENT = Guid("0000aef7-0000-1000-8000-00805f9b34fb");
Guid UUID_CLIENT = Guid("0000aef4-0000-1000-8000-00805f9b34fb");
Guid MAGNITUDE_CLIENT = Guid("0000aef8-0000-1000-8000-00805f9b34fb");
Guid BATTERY_VOLTAGE_CLIENT = Guid("0000aef1-0000-1000-8000-00805f9b34fb");
Guid FREQUENCY_CLIENT = Guid("0000aef9-0000-1000-8000-00805f9b34fb");
Guid PROVISIONED_CLIENT = Guid("0000aef6-0000-1000-8000-00805f9b34fb");
Guid CHARGERCONN_CLIENT = Guid("0000aeff-0000-1000-8000-00805f9b34fb");
Guid BATTERY_PERCENTAGE_CLIENT = Guid("0000aef3-0000-1000-8000-00805f9b34fb");
Guid BATTERY_TIME_REMAINING_CLIENT =
    Guid("0000aef2-0000-1000-8000-00805f9b34fb");

String FREQ = "freq";
String MAG = "mag";
String MODE = "MODE";
String INFO = "info;";
String SOS = "sos;";
String RESTART = "restart;";
String RSTF = "rstf;";
String RPROV = "rprov;";
String NOTIFICON = "@mipmap/ic_launcher";

final List<String> modesNames = [
  'Novib',
  'Swing phase continuous',
  'Swing phase burst',
  'Stance phase continuous',
  'Stance phase burst',
  'Open loop'
];

final Map<String, String> modesDictionary = {
  'Novib': "-1",
  'Swing phase continuous': "2",
  'Swing phase burst': "1",
  'Stance phase continuous': "0",
  'Stance phase burst': "3",
  'Open loop': "4"
};
