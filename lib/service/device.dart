import 'dart:async';
import 'dart:io' as io;
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sonr_app/data/data.dart';
import 'package:sonr_app/theme/theme.dart' hide Position;
import 'package:url_launcher/url_launcher.dart';
import 'package:motion_sensors/motion_sensors.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

// @ Enum defines Type of Permission
enum PermissionType { Camera, Gallery, Location, Notifications, Sound }
const K_SENSOR_INTERVAL = Duration.microsecondsPerSecond ~/ 30;

class DeviceService extends GetxService {
  // Accessors
  static bool get isRegistered => Get.isRegistered<DeviceService>();
  static DeviceService get to => Get.find<DeviceService>();

  // Device/Location Properties
  final _compass = Rx<CompassEvent>(null);
  final _keyboardVisible = false.obs;
  final _location = Rx<Position>(null);
  final _platform = Rx<Platform>(null);

  // Sensor Properties
  final _accelerometer = Rx<AccelerometerEvent>(null);
  final _gyroscope = Rx<GyroscopeEvent>(null);
  final _magnetometer = Rx<MagnetometerEvent>(null);
  final _orientation = Rx<OrientationEvent>(null);

  // Getters for Device/Location References
  static Rx<CompassEvent> get compass => to._compass;
  static RxBool get keyboardVisible => to._keyboardVisible;
  static Rx<Platform> get platform => to._platform;
  static Rx<AccelerometerEvent> get accelerometer => to._accelerometer;
  static Rx<GyroscopeEvent> get gyroscope => to._gyroscope;
  static Rx<MagnetometerEvent> get magnetometer => to._magnetometer;
  static Rx<OrientationEvent> get orientation => to._orientation;

  // Returns Current Position
  static Quadruple<double, double, Position_Accelerometer, Position_Gyroscope> get direction {
    return Quadruple(
        compass.value.headingForCameraMode,
        compass.value.heading,
        Position_Accelerometer(
          x: accelerometer.value.x,
          y: accelerometer.value.y,
          z: accelerometer.value.z,
        ),
        Position_Gyroscope(
          x: gyroscope.value.x,
          y: gyroscope.value.y,
          z: gyroscope.value.z,
        ));
  }

  // Platform Checkers
  static bool get isDesktop =>
      Get.find<DeviceService>()._platform.value == Platform.Linux ||
      Get.find<DeviceService>()._platform.value == Platform.MacOS ||
      Get.find<DeviceService>()._platform.value == Platform.Windows;
  static bool get isMobile =>
      Get.find<DeviceService>()._platform.value == Platform.iOS || Get.find<DeviceService>()._platform.value == Platform.Android;
  static bool get isAndroid => Get.find<DeviceService>()._platform.value == Platform.Android;
  static bool get isIOS => Get.find<DeviceService>()._platform.value == Platform.iOS;
  static bool get isLinux => Get.find<DeviceService>()._platform.value == Platform.Linux;
  static bool get isMacOS => Get.find<DeviceService>()._platform.value == Platform.MacOS;
  static bool get isWindows => Get.find<DeviceService>()._platform.value == Platform.Windows;
  static bool get isNotApple =>
      Get.find<DeviceService>()._platform.value != Platform.iOS && Get.find<DeviceService>()._platform.value != Platform.MacOS;

  // References
  final _audioPlayer = AudioCache(prefix: 'assets/sounds/', respectSilence: true);
  final _keyboardVisibleController = KeyboardVisibilityController();

  // ^ Open SharedPreferences on Init ^ //
  Future<DeviceService> init() async {
    // @ 1. Set Platform
    if (io.Platform.isAndroid) {
      _platform(Platform.Android);
    } else if (io.Platform.isIOS) {
      _platform(Platform.iOS);
    } else if (io.Platform.isLinux) {
      _platform(Platform.Linux);
    } else if (io.Platform.isMacOS) {
      _platform(Platform.MacOS);
    } else if (io.Platform.isWindows) {
      _platform(Platform.Windows);
    }

    // @ 2. Initialize References
    // Audio Player
    _audioPlayer.disableLog();
    _audioPlayer.loadAll(List<String>.generate(UISoundType.values.length, (index) => UISoundType.values[index].file));

    // Handle Keyboard Visibility
    _keyboardVisibleController.onChange.listen(_handleKeyboardVisibility);

    // @ 3. Bind Sensors for Mobile
    if (_platform.value == Platform.iOS || _platform.value == Platform.Android) {
      // Bind Direction and Set Intervals
      _compass.bindStream(FlutterCompass.events);
      motionSensors.accelerometerUpdateInterval = K_SENSOR_INTERVAL;
      motionSensors.magnetometerUpdateInterval = K_SENSOR_INTERVAL;
      motionSensors.orientationUpdateInterval = K_SENSOR_INTERVAL;
      motionSensors.gyroscopeUpdateInterval = K_SENSOR_INTERVAL;
      motionSensors.userAccelerometerUpdateInterval = K_SENSOR_INTERVAL;

      // Bind Sensor Streams
      _accelerometer.bindStream(motionSensors.accelerometer);
      _magnetometer.bindStream(motionSensors.magnetometer);
      _orientation.bindStream(motionSensors.orientation);
      _gyroscope.bindStream(motionSensors.gyroscope);
    }
    return this;
  }

  @override
  void onClose() {
    _audioPlayer.clearCache();
    super.onClose();
  }

  // ^ Method Plays a UI Sound ^
  static void playSound({@required UISoundType type}) async {
    await to._audioPlayer.play(type.file);
  }

  // ^ Method Determinse LaunchPage and Changes Screen ^
  static void shiftPage({@required Duration delay}) async {
    Future.delayed(delay, () {
      // Check for User
      if (!UserService.hasUser.value) {
        Get.offNamed("/register");
      } else {
        if (isMobile) {
          // All Valid
          if (UserService.permissions.value.hasLocation) {
            Get.offNamed("/home", arguments: HomeArguments(isFirstLoad: true));
          }

          // No Location
          else {
            Get.find<UserService>().requestLocation().then((value) {
              if (value) {
                Get.offNamed("/home", arguments: HomeArguments(isFirstLoad: true));
              }
            });
          }
        } else {
          Get.offNamed("/home", arguments: HomeArguments(isFirstLoad: true));
        }
      }
    });
  }

  // ^ Launch a URL Event ^ //
  Future launchURL(String url) async {
    if (await canLaunch(url)) {
      SonrOverlay.back();
      await launch(url);
    } else {
      SonrSnack.error("Could not launch the URL.");
    }
  }

  // ^ Refresh User Location Position ^ //
  static Future<Position> currentLocation() async {
    if (UserService.permissions.value.hasLocation) {
      to._location(await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high));
      return to._location.value;
    } else {
      print("No Location Permissions");
      return null;
    }
  }

  // # Handle Keyboard Visibility Update
  _handleKeyboardVisibility(bool keyboardVisible) {
    _keyboardVisible(keyboardVisible);
  }
}

// ^ Asset Sound Types ^ //
enum UISoundType { Confirmed, Connected, Critical, Deleted, Fatal, Joined, Linked, Received, Swipe, Transmitted, Warning }

// ^ Asset Sound Type Utility ^ //
extension UISoundTypeUtil on UISoundType {
  String get file {
    return '${this.value.toLowerCase()}.wav';
  }

  // @ Returns Value Name of Enum Type //
  String get value {
    return this.toString().substring(this.toString().indexOf('.') + 1);
  }
}
