import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'icon.dart';

// ^ Sonr Global AppBar Data ^ //
// ignore: non_constant_identifier_names
NeumorphicAppBar SonrAppBar(
  String title,
) {
  return NeumorphicAppBar(
      title: Center(
          child: Text(title,
              style: GoogleFonts.poppins(), textAlign: TextAlign.center)),
      leading: null);
}

// ignore: non_constant_identifier_names
NeumorphicAppBar SonrHomeBar(
  Function onPressed,
) {
  return NeumorphicAppBar(
      title: Center(
          child: Text("Home",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 28, //customize depth here
                color: Colors.white, //customize color here
              ),
              textAlign: TextAlign.center)),
      leading: Align(
          alignment: Alignment.centerLeft,
          child: NeumorphicButton(
            padding: EdgeInsets.all(8),
            style: NeumorphicStyle(
                intensity: 0.85,
                boxShape: NeumorphicBoxShape.circle(),
                shape: NeumorphicShape.convex,
                depth: 8),
            child: GradientIcon(
              Icons.person_outline,
              FlutterGradientNames.itmeoBranding,
            ),
            onPressed: onPressed,
          )));
}

// ^ Utilized in Transfer/Settings Screens ^ //
// ignore: non_constant_identifier_names
NeumorphicAppBar SonrExitAppBar(
  String exitLocation, {
  String title: "",
}) {
  // Create App Bar
  return NeumorphicAppBar(
      title: Center(child: Text(title, style: GoogleFonts.poppins())),
      leading: Align(
          alignment: Alignment.center,
          child: NeumorphicButton(
            padding: EdgeInsets.all(8),
            style: NeumorphicStyle(
                intensity: 0.85,
                boxShape: NeumorphicBoxShape.circle(),
                shape: NeumorphicShape.flat,
                depth: 8),
            child: GradientIcon(Icons.close, FlutterGradientNames.phoenixStart),
            onPressed: () {
              Get.offAllNamed(exitLocation);
            },
          )));
}

// ^ Utilized in Profile Screen ^ //
// ignore: non_constant_identifier_names
AppBar SonrProfileAppBar(
  String exitLocation, {
  String title: "",
}) {
  // Create App Bar
  return AppBar(
      backgroundColor: Color(0x44000000),
      elevation: 0,
      title: Center(child: Text(title, style: GoogleFonts.poppins())),
      leading: Align(
          alignment: Alignment.center,
          child: NeumorphicButton(
            padding: EdgeInsets.all(8),
            style: NeumorphicStyle(
                intensity: 0.85,
                boxShape: NeumorphicBoxShape.circle(),
                shape: NeumorphicShape.flat,
                depth: 8),
            child: GradientIcon(Icons.close, FlutterGradientNames.phoenixStart),
            onPressed: () {
              Get.offAllNamed(exitLocation);
            },
          )));
}
