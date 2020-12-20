import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:sonar_app/modules/transfer/lobby_view.dart';
import 'package:sonar_app/service/sonr_service.dart';
import 'package:sonar_app/theme/theme.dart';
import 'compass_view.dart';

class TransferScreen extends StatelessWidget {
  // @ Initialize
  @override
  Widget build(BuildContext context) {
    return SonrTheme(Scaffold(
        appBar: SonrExitAppBar(
          "/home-from-transfer",
          title: Get.find<SonrService>().code.value,
        ),
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: SafeArea(
            child: Stack(
          children: <Widget>[
            // @ Range Lines
            Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: CustomPaint(
                  size: Size(Get.width, Get.height),
                  painter: ZonePainter(),
                  child: Container(),
                )),

            // @ Lobby View
            LobbyView(),

            // @ Compass View
            CompassView(),
          ],
        ))));
  }
}
