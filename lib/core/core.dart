// Core
export 'circle.dart';
export 'dart:async';
export 'dart:convert';
export 'dart:io' hide Socket;
export 'dart:math';
export 'filetype.dart';
export 'package:flutter/services.dart';

// Dev Libraries
export 'package:logger/logger.dart';
import 'package:logger/logger.dart';
export 'package:bloc/bloc.dart';
export 'package:enum_to_string/enum_to_string.dart';

// Networking Libraries
export 'package:socket_io_client/socket_io_client.dart';

// Device Libraries
export 'package:flutter_sensor_compass/flutter_sensor_compass.dart';
export 'package:sensors/sensors.dart';
export 'package:soundpool/soundpool.dart';

// **************************** //
// ** Global Logging Package ** //
// **************************** //
Logger log = Logger();

// ****************** //
// ** Enum Methods ** //
// ****************** //
// Enum Value Converstion to String
String enumAsString(Object o) => o.toString().split('.').last;

// String Conversion to Enum Value
T enumFromString<T>(String key, Iterable<T> values) => values.firstWhere(
      (v) => v != null && key == enumAsString(v),
      orElse: () => null,
    );
