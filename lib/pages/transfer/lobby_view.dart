import 'dart:async';

import 'package:animated_widgets/animated_widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sonr_app/data/model/model_lobby.dart';
import 'package:sonr_app/modules/lobby/lobby.dart';
import 'package:sonr_app/modules/peer/card_view.dart';
import 'package:sonr_app/pages/transfer/transfer_controller.dart';
import 'package:sonr_app/theme/theme.dart';

import 'payload_view.dart';

// ^ Local Lobby View ^ //
class LocalLobbyView extends GetView<TransferController> {
  const LocalLobbyView({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(() => SonrScaffold(
          gradientName: FlutterGradientNames.plumBath,
          appBar: DesignAppBar(
            action: controller.currentPayload != Payload.CONTACT
                ? PlainButton(icon: SonrIcons.Remote, onPressed: () async => controller.startRemote())
                : Container(width: 56, height: 56),
            leading: PlainIconButton(icon: SonrIcons.Close.gradient(gradient: SonrGradient.Critical), onPressed: () => Get.offNamed("/home")),
            title: Container(child: GestureDetector(child: controller.title.value.h3, onTap: () => Get.bottomSheet(LobbySheet()))),
          ),
          body: Stack(
            children: <Widget>[
              // @ Lobby View
              //_LocalLobbyStack(),
              CarouselSlider(
                options: CarouselOptions(height: 400.0),
                items: LobbyService.local.value.peers.map((i) => Builder(builder: (context) => PeerCard(i))).toList(),
              ),

              // @ Compass View
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: GestureDetector(
                    onTap: () {
                      controller.toggleShifting();
                    },
                    child: PayloadView(),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// ^ Local Lobby Stack View ^ //
class _LocalLobbyStack extends StatefulWidget {
  const _LocalLobbyStack({Key key}) : super(key: key);
  @override
  _LocalLobbyStackState createState() => _LocalLobbyStackState();
}

class _LocalLobbyStackState extends State<_LocalLobbyStack> {
  // References
  List<PeerCard> stackChildren = <PeerCard>[];
  StreamSubscription<LobbyModel> localLobbyStream;

  // * Initial State * //
  @override
  void initState() {
    // Add Initial Data
    _handleLobbyUpdate(LobbyService.local.value);
    localLobbyStream = LobbyService.local.listen(_handleLobbyUpdate);
    super.initState();
  }

  // * On Dispose * //
  @override
  void dispose() {
    localLobbyStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (stackChildren.length > 0) {
      return OpacityAnimatedWidget(
          duration: 150.milliseconds,
          child: Stack(
            children: stackChildren,
            alignment: Alignment.center,
          ),
          enabled: true);
    } else {
      return Container();
    }
  }

  // @ Updates Stack Children
  _handleLobbyUpdate(LobbyModel data) {
    // Initialize
    var children = <PeerCard>[];

    // Clear List
    stackChildren.clear();

    // Iterate through peers and IDs
    if (data != null) {
      data.peers.forEach((peer) {
        if (peer.platform == Platform.IOS || peer.platform == Platform.Android) {
          // Add to Stack Items
          children.add(PeerCard(peer));
        }
      });
    }

    // Update View
    setState(() {
      stackChildren = children;
    });
  }
}
