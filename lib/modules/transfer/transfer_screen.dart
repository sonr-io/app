import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:sonr_app/theme/theme.dart';
import 'compass_view.dart';
import 'lobby_view.dart';
import 'transfer_controller.dart';

class TransferScreen extends GetView<TransferController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => SonrScaffold.appBarLeadingAction(
          disableDynamicLobbyTitle: true,
          titleWidget: GestureDetector(child: SonrText.appBar(controller.title.value), onTap: () => Get.bottomSheet(LobbySheet())),
          leading: SonrButton.circle(icon: SonrIcon.close, onPressed: () => Get.offNamed("/home/transfer"), shape: NeumorphicShape.flat),
          action: Get.find<SonrService>().payload != Payload.CONTACT
              ? SonrButton.circle(icon: SonrIcon.remote, onPressed: () async => controller.startRemote(), shape: NeumorphicShape.flat)
              : Container(),
          body: GestureDetector(
            onDoubleTap: () => controller.toggleBirdsEye(),
            child: controller.isRemoteActive.value
                ? RemoteLobbyView()
                : Stack(
                    children: <Widget>[
                      // @ Range Lines
                      Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Stack(
                            children: [
                              Neumorphic(style: SonrStyle.zonePath(proximity: Position_Proximity.Distant)),
                              Neumorphic(style: SonrStyle.zonePath(proximity: Position_Proximity.Near)),
                            ],
                          )),

                      // @ Lobby View
                      LocalLobbyStack(),

                      // @ Compass View
                      Padding(
                        padding: EdgeInsetsX.bottom(64.0),
                        child: CompassView(),
                      ),
                    ],
                  ),
          ),
        ));
  }
}
