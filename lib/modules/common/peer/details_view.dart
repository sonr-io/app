import 'package:sonr_app/theme/theme.dart';
import 'peer.dart';

// ^ PeerSheetView Displays Extended Peer Details ^ //
class PeerDetailsView extends StatelessWidget {
  final BubbleController controller;
  const PeerDetailsView(this.controller, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: Get.height / 3 + 25,
        margin: EdgeInsets.symmetric(horizontal: 30),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Stack(children: [
            // Window
            NeumorphicBackground(
              borderRadius: BorderRadius.circular(20),
              backendColor: Colors.transparent,
              margin: EdgeInsets.only(top: 60),
              child: Neumorphic(
                style: SonrStyle.overlay,
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  // Close Button / Position Info
                  Align(
                      heightFactor: 0.9,
                      alignment: Alignment.topRight,
                      child: Container(
                          padding: EdgeInsets.all(4),
                          height: 32,
                          width: 86,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), color: SonrPalette.AccentNavy.withOpacity(0.75)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [SonrIcons.Discover.white, Obx(() => " ${controller.peerVector.value.data.directionString}".h6_White)]))),

                  // Peer Information
                  controller.peer.value.fullName,
                  controller.peer.value.platformExpanded,
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 90, vertical: 10),
                      child: ColorButton.primary(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          onPressed: () {
                            controller.invite();
                            Get.back();
                          },
                          icon: SonrIcons.Share,
                          text: "Invite")),
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
                  color: SonrColor.White,
                ),
                child: Neumorphic(
                  style: NeumorphicStyle(intensity: 0.5, depth: -8, boxShape: NeumorphicBoxShape.circle(), color: SonrColor.White),
                  child: controller.peer.value.profilePicture(),
                ),
              ),
            ),
          ]),
        ));
  }
}
