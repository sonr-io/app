import 'peer_controller.dart';
import 'package:sonr_app/data/constants.dart';
import 'package:sonr_app/theme/theme.dart';

// ^ PeerBubble Utilizes Peer Controller ^ //
class PeerBubble extends StatelessWidget {
  final Peer peer;
  final int index;
  PeerBubble(this.peer, this.index);

  @override
  Widget build(BuildContext context) {
    return GetX<PeerController>(
        init: PeerController(peer, index),
        builder: (controller) {
          return AnimatedPositioned(
              top: 35.0,
              left: 100,
              duration: 150.milliseconds,
              child: AnimatedContainer(
                width: 90,
                height: 90,
                decoration: SonrStyle.bubbleDecoration,
                duration: 200.milliseconds,
                child: PlayAnimation<double>(
                    tween: controller.contentAnimation.value.item1,
                    duration: controller.contentAnimation.value.item2,
                    delay: controller.contentAnimation.value.item3,
                    builder: (context, child, value) {
                      return Obx(() {
                        return AnimatedOpacity(
                          opacity: value,
                          duration: controller.contentAnimation.value.item2,
                          child: GestureDetector(
                            onTap: () => controller.invite(),
                            onLongPress: () => controller.showExpanded(),
                            child: Stack(alignment: Alignment.center, children: [
                              controller.artboard.value.view,
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                Padding(padding: EdgeInsets.all(8)),
                                controller.peer.initials,
                                Padding(padding: EdgeInsets.all(8)),
                              ])
                            ]),
                          ),
                        );
                      });
                    }),
              ));
        });
  }
}

// ^ PeerSheetView Displays Extended Peer Details ^ //
class PeerSheetView extends StatelessWidget {
  final PeerController controller;
  const PeerSheetView(this.controller, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: Get.height / 3 + 25,
        margin: EdgeInsets.symmetric(horizontal: 30),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Stack(children: [
            // Window
            Container(
              margin: EdgeInsets.only(top: 60),
              child: Neumorphic(
                style: SonrStyle.overlay,
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  // Close Button / Position Info
                  Align(
                      heightFactor: 0.9,
                      alignment: Alignment.topRight,
                      child: Container(
                          width: 100,
                          padding: EdgeInsets.all(10),
                          child: Neumorphic(
                            padding: EdgeInsets.all(4),
                            style: SonrStyle.compassStamp,
                            child: Row(children: [
                              SonrIcon.normal(
                                SonrIconData.compass,
                                color: Colors.white,
                                size: 20,
                              ),
                              Obx(() => SonrText.light(
                                    " " + controller.direction.value.direction,
                                    color: Colors.white,
                                    size: 20,
                                  ))
                            ]),
                          ))),

                  // Peer Information
                  controller.peer.fullName,
                  controller.peer.platformExpanded,
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 90, vertical: 10),
                      child: SonrButton.rectangle(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          shape: NeumorphicShape.convex,
                          depth: 4,
                          onPressed: () {
                            controller.invite();
                            Get.back();
                          },
                          icon: SonrIcon.invite,
                          text: SonrText.semibold("Invite", size: 24))),
                  Spacer()
                ]),
              ),
            ),

            // Profile Pic
            Align(
              alignment: Alignment.topCenter,
              child: Neumorphic(
                padding: EdgeInsets.all(4),
                style: NeumorphicStyle(
                  shadowLightColor: Colors.black38,
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: 10,
                  color: SonrColor.base,
                ),
                child: Neumorphic(
                  style: NeumorphicStyle(intensity: 0.5, depth: -8, boxShape: NeumorphicBoxShape.circle(), color: SonrColor.base),
                  child: controller.peer.profilePicture,
                ),
              ),
            ),
          ]),
        ));
  }
}
