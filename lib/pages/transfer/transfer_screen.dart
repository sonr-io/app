import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:sonr_app/common/lobby/sheet_view.dart';
import 'package:sonr_app/common/lobby/stack_view.dart';
import 'package:sonr_app/common/lobby/title_widget.dart';
import 'package:sonr_app/common/peer/item_view.dart';
import 'package:sonr_app/data/model/model_lobby.dart';
import 'package:sonr_app/theme/theme.dart';
import 'compass_view.dart';
import 'transfer_controller.dart';

// ^ Transfer Screen Entry Point ^ //
class TransferScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetX<TransferController>(
      init: TransferController(),
      builder: (controller) {
        if (controller.isRemoteActive.value) {
          return RemoteLobbyView(controller, info: controller.remote.value);
        } else {
          return LocalLobbyView(controller);
        }
      },
    );
  }
}

// ^ Local Lobby View ^ //
class LocalLobbyView extends StatelessWidget {
  final TransferController controller;

  const LocalLobbyView(this.controller, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SonrScaffold.appBarLeadingAction(
      disableDynamicLobbyTitle: true,
      titleWidget: GestureDetector(child: SonrText.appBar(controller.title.value), onTap: () => Get.bottomSheet(LobbySheet())),
      leading: ShapeButton.circle(icon: SonrIcon.close, onPressed: () => Get.offNamed("/home/transfer"), shape: NeumorphicShape.flat),
      action: Get.find<SonrService>().payload != Payload.CONTACT
          ? ShapeButton.circle(icon: SonrIcon.remote, onPressed: () async => controller.startRemote(), shape: NeumorphicShape.flat)
          : Container(),
      body: GestureDetector(
        onDoubleTap: () => controller.toggleBirdsEye(),
        child: Stack(
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
            LobbyService.localSize.value > 0 ? LocalLobbyStack(controller) : Container(),

            // @ Compass View
            Padding(
              padding: EdgeInsetsX.bottom(32.0),
              child: GestureDetector(
                onTap: () {
                  controller.toggleShifting();
                },
                child: CompassView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ^ Remote Lobby View ^ //
class RemoteLobbyView extends StatefulWidget {
  final RemoteInfo info;
  final TransferController controller;
  const RemoteLobbyView(this.controller, {Key key, @required this.info}) : super(key: key);
  @override
  _RemoteLobbyViewState createState() => _RemoteLobbyViewState();
}

class _RemoteLobbyViewState extends State<RemoteLobbyView> {
  // References
  int toggleIndex = 1;
  LobbyModel lobbyModel;
  LobbyStream peerStream;

  // * Initial State * //
  @override
  void initState() {
    // Set Stream
    peerStream = LobbyService.listenToLobby(widget.info);
    peerStream.listen(_handlePeerUpdate);
    super.initState();
  }

  // * On Dispose * //
  @override
  void dispose() {
    peerStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SonrScaffold.appBarLeadingAction(
        disableDynamicLobbyTitle: true,
        titleWidget: _buildTitleWidget(),
        leading: ShapeButton.circle(icon: SonrIcon.close, onPressed: () => Get.offNamed("/home/transfer"), shape: NeumorphicShape.flat),
        action: ShapeButton.circle(icon: SonrIcon.leave, onPressed: () => widget.controller.stopRemote(), shape: NeumorphicShape.flat),
        body: ListView.builder(
          itemCount: lobbyModel != null ? lobbyModel.length + 1 : 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return LobbyTitleView(
                onChanged: (index) {
                  setState(() {
                    toggleIndex = index;
                  });
                },
                title: widget.info.display,
              );
            } else {
              // Build List Item
              return PeerListItem(
                lobbyModel.atIndex(index - 1),
                index - 1,
                remote: widget.info,
              );
            }
          },
        ));
  }

  Widget _buildTitleWidget() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      SonrText.appBar("Remote"),
      IconButton(
        icon: Icon(Icons.info_outline),
        onPressed: () {
          SonrSnack.remote(message: widget.info.display, duration: 12000);
        },
      )
    ]);
  }

  // ^ Updates Stack Children ^ //
  _handlePeerUpdate(LobbyModel lobby) {
    // Update View
    setState(() {
      lobbyModel = lobby;
    });
  }
}
