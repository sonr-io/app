import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:sonar_app/theme/theme.dart';
import 'package:sonar_app/modules/invite/progress_view.dart';
import 'package:sonar_app/service/sonr_service.dart';
import 'package:sonr_core/sonr_core.dart';

class FileInviteSheet extends StatelessWidget {
  final AuthInvite invite;

  const FileInviteSheet(
    this.invite, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // @ Extract Data
    SonrService sonr = Get.find();

    return SonrTheme(Obx(() {
      // @ In Transfer
      if (sonr.status() == Status.Busy) {
        return Neumorphic(
            margin: EdgeInsets.only(left: 15, right: 15),
            child: Container(
                padding: EdgeInsetsDirectional.only(start: 15, end: 15),
                decoration: SonrWindowDecoration(),
                height: Get.height / 3 + 20,
                child: Center(
                    child: ProgressView(
                        iconData: iconDataFromPayload(invite.payload)))));
      }
      // @ Pending
      else if (sonr.status() == Status.Pending) {
        return Neumorphic(
            margin: EdgeInsets.only(left: 15, right: 15),
            child: Container(
                decoration: SonrWindowDecoration(),
                height: Get.height / 3 + 20,
                child: Column(
                  children: [
                    // @ Top Right Close/Cancel Button
                    closeButton(() {
                      // Emit Event
                      sonr.respondPeer(false);

                      // Pop Window
                      Get.back();
                    }),

                    // Build Item from Metadata and Peer
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      iconWithPreview(invite.payload.file),
                      Padding(padding: EdgeInsets.all(8)),
                      Column(
                        children: [
                          boldText(invite.from.firstName, size: 32),
                          normalText(invite.from.device.platform, size: 22),
                        ],
                      ),
                    ]),
                    Padding(padding: EdgeInsets.only(top: 8)),

                    // Build Auth Action
                    rectangleButton("Accept", () {
                      // Emit Event
                      sonr.respondPeer(true);
                    }),
                  ],
                )));
      } else {
        return Container();
      }
    }));
  }
}
