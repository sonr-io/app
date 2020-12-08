import 'package:sonar_app/ui/ui.dart';
import 'package:sonr_core/sonr_core.dart';
import 'package:rive/rive.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';

class Bubble extends StatelessWidget {
  // Bubble Values
  final double value;
  final Peer peer;

  Bubble(this.value, this.peer);

  // Animation Handling
  final TransferController transferController = Get.find();

  @override
  Widget build(BuildContext context) {
    final BubbleAnimController bubbleController =
        Get.put<BubbleAnimController>(BubbleAnimController(peer));
    return GetBuilder<BubbleAnimController>(builder: (_) {
      return Positioned(
          top: calculateOffset(value).dy,
          left: calculateOffset(value).dx,
          child: GestureDetector(
              onTap: () async {
                if (!bubbleController.isInvited()) {
                  // Send Offer to Bubble
                  bubbleController.invite();
                  transferController.invitePeer(peer);
                }
              },
              child: PlayAnimation<double>(
                  tween: (0.0).tweenTo(1.0),
                  duration: 500.milliseconds,
                  delay: 1.seconds,
                  builder: (context, child, value) {
                    return Container(
                        width: 90,
                        height: 90,
                        decoration:
                            BoxDecoration(shape: BoxShape.circle, boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(167, 179, 190, value),
                            offset: Offset(0, 2),
                            blurRadius: 6,
                            spreadRadius: 0.5,
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(248, 252, 255, value / 2),
                            offset: Offset(-2, 0),
                            blurRadius: 6,
                            spreadRadius: 0.5,
                          ),
                        ]),
                        child: Stack(alignment: Alignment.center, children: [
                          Rive(
                            artboard: bubbleController.artboard,
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                          ),
                          GetBuilder<BubbleAnimController>(builder: (_) {
                            if (bubbleController.hasCompleted()) {
                              return PlayAnimation<double>(
                                  tween: (1.0).tweenTo(0.0),
                                  duration: 20.milliseconds,
                                  builder: (context, child, value) {
                                    return AnimatedOpacity(
                                        opacity: value,
                                        duration: 20.milliseconds,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              iconFromPeer(peer, size: 20),
                                              initialsFromPeer(peer),
                                            ]));
                                  });
                            }
                            return PlayAnimation<double>(
                                tween: (0.0).tweenTo(1.0),
                                duration: 500.milliseconds,
                                delay: 1.seconds,
                                builder: (context, child, value) {
                                  return AnimatedOpacity(
                                      opacity: value,
                                      duration: 500.milliseconds,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            iconFromPeer(peer, size: 20),
                                            initialsFromPeer(peer),
                                          ]));
                                });
                          }),
                        ]));
                  })));
    });
  }
}
