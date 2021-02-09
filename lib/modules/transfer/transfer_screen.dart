import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:sonr_app/service/sonr_service.dart';
import 'package:sonr_app/theme/theme.dart';
import 'compass_view.dart';
import 'transfer_controller.dart';

class TransferScreen extends StatelessWidget {
  // @ Initialize
  @override
  Widget build(BuildContext context) {
    return SonrScaffold.appBarLeading(
        title: Get.find<SonrService>().olc.value,
        leading: SonrButton.circleIcon(SonrIcon.close, () => Get.offNamed("/home/transfer")),
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
        )));
  }
}

class LobbyView extends GetView<TransferController> {
  LobbyView({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // @ Listen to Lobby Updates
      Get.find<SonrService>().peers().forEach((id, peer) {
        controller.addPeer(id, peer);
      });

      // Present Text
      return PlayAnimation<double>(
          tween: (0.0).tweenTo(1.0),
          duration: 200.milliseconds,
          delay: 200.milliseconds,
          builder: (context, child, value) {
            return AnimatedOpacity(opacity: value, duration: 200.milliseconds, child: Stack(children: List.from(controller.stackItems)));
          });
    });
  }
}
