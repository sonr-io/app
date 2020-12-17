import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:sonar_app/theme/theme.dart';
import 'package:sonar_app/service/sonr_service.dart';

import 'peer_stack.dart';
import 'compass_view.dart';
import 'zone_painter.dart';

const STACK_CONSTANT = 1;

class TransferScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SonrService sonr = Get.find();
    return SonrTheme(Scaffold(
        appBar: SonrExitAppBar(
          context,
          "/home",
          title: sonr.code,
        ),
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: SafeArea(
            child: Stack(
          children: <Widget>[
            // @ Range Lines
            ZoneView(),

            // @ Peer Bubbles
            PeerStack(),

            // @ Compass View
            CompassView(),
          ],
        ))));
  }
}
