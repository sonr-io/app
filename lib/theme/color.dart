import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'icon.dart';

const Color K_BASE_COLOR = Color(0xffDDDDDD);
const Color K_DIALOG_COLOR = Color.fromRGBO(27, 27, 27, 0.7);

// ^ Find Icons color based on Theme - Light/Dark ^
Color findIconsColor() {
  final theme = NeumorphicTheme.of(Get.context);
  if (Get.isDarkMode) {
    return theme.current.accentColor;
  } else {
    return null;
  }
}

// ^ Find Text color based on Theme - Light/Dark ^
Color findTextColor() {
  if (Get.isDarkMode) {
    return Colors.white;
  } else {
    return Colors.black;
  }
}

// ^ Progress Gradient Mask Random ^
Gradient randomProgressGradient() {
  // Predefined Colors
  var opts = [
    FlutterGradients.amyCrisp(),
    FlutterGradients.sugarLollipop(),
    FlutterGradients.summerGames(),
    FlutterGradients.supremeSky(),
    FlutterGradients.juicyCake(),
    FlutterGradients.northMiracle(),
    FlutterGradients.seaLord()
  ];

  // Generates a new Random object
  final _random = new Random();

  // Generate a random index based on the list length
  return opts[_random.nextInt(opts.length)];
}

// ^ Color from HEX Code ^
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
