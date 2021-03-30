import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:sonr_app/theme/theme.dart';
import 'peer_widget.dart';

// ^ Local Lobby Stack View ^ //
class LocalLobbyStack extends StatefulWidget {
  @override
  _LocalLobbyStackState createState() => _LocalLobbyStackState();
}

class _LocalLobbyStackState extends State<LocalLobbyStack> {
  // References
  int lobbySize = 0;
  List<PeerBubble> stackChildren = <PeerBubble>[];
  StreamSubscription<Lobby> localLobbyStream;

  // * Initial State * //
  @override
  void initState() {
    // Add Initial Data
    _handleLobbyUpdate(LobbyService.local.value);

    // Set Stream
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
    return PlayAnimation<double>(
        tween: (0.0).tweenTo(1.0),
        duration: 150.milliseconds,
        builder: (context, child, value) {
          return AnimatedOpacity(opacity: value, duration: 150.milliseconds, child: Stack(children: stackChildren));
        });
  }

  // * Updates Stack Children * //
  _handleLobbyUpdate(Lobby data) {
    // Initialize
    var children = <PeerBubble>[];

    // Clear List
    stackChildren.clear();

    // Iterate through peers and IDs
    data.peers.forEach((id, peer) {
      // Add to Stack Items
      if (peer.platform == Platform.Android || peer.platform == Platform.iOS) {
        children.add(PeerBubble(peer, stackChildren.length - 1));
      }
    });

    // Update View
    setState(() {
      lobbySize = data.size;
      stackChildren = children;
    });
  }
}

// ^ Switched Lobby View ^ //
class RemoteLobbyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: LobbyService.localSize.value,
        itemBuilder: (context, idx) {
          return Column(children: [
            SonrText.title("Handling Remote..."),
          ]);
        });
  }
}

// ^ Sheet Lobby View ^ //
class LobbySheet extends StatefulWidget {
  @override
  _LobbySheetState createState() => _LobbySheetState();
}

class _LobbySheetState extends State<LobbySheet> {
  // References
  int lobbySize = 0;
  int toggleIndex = 0;
  List<Peer> peerList = <Peer>[];
  StreamSubscription<Lobby> peerStream;

  // * Initial State * //
  @override
  void initState() {
    // Add Initial Data
    _handlePeerUpdate(LobbyService.local.value);

    // Set Stream
    peerStream = LobbyService.local.listen(_handlePeerUpdate);
    super.initState();
  }

  // * On Dispose * //
  @override
  void dispose() {
    peerStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicBackground(
        backendColor: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Neumorphic(
            style: SonrStyle.normal,
            child: ListView.builder(
              itemCount: peerList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return _buildTitle();
                } else {
                  // Build List Item
                  return PeerListItem(peerList[index - 1], index - 1);
                }
              },
            )));
  }

  // ^ Builds Title View ^ //
  Widget _buildTitle() {
    return Column(children: [
      // Build Title
      Padding(padding: EdgeInsetsX.top(8)),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [SonrIcon.profile, Padding(padding: EdgeInsetsX.right(16)), SonrText.title("All Peers")]),

      // Build Toggle View
      Container(
        padding: EdgeInsets.only(top: 8, bottom: 16),
        margin: EdgeInsetsX.horizontal(24),
        child: NeumorphicToggle(
          style: NeumorphicToggleStyle(depth: 20, backgroundColor: UserService.isDarkMode.value ? SonrColor.Dark : SonrColor.White),
          thumb: Neumorphic(style: SonrStyle.toggle),
          selectedIndex: toggleIndex,
          onChanged: (val) {
            setState(() {
              toggleIndex = val;
            });
          },
          children: [
            ToggleElement(
                background: Center(child: SonrText.medium("Media", color: SonrColor.Grey, size: 16)),
                foreground: SonrIcon.neumorphicGradient(SonrIconData.media, FlutterGradientNames.newRetrowave, size: 24)),
            ToggleElement(
                background: Center(child: SonrText.medium("All", color: SonrColor.Grey, size: 16)),
                foreground: SonrIcon.neumorphicGradient(SonrIconData.all_categories,
                    UserService.isDarkMode.value ? FlutterGradientNames.happyUnicorn : FlutterGradientNames.eternalConstance,
                    size: 22.5)),
            ToggleElement(
                background: Center(child: SonrText.medium("Contacts", color: SonrColor.Grey, size: 16)),
                foreground: SonrIcon.neumorphicGradient(SonrIconData.friends, FlutterGradientNames.orangeJuice, size: 24)),
          ],
        ),
      ),
    ]);
  }

  // ^ Updates Stack Children ^ //
  _handlePeerUpdate(Lobby lobby) {
    // Initialize
    var children = <Peer>[];

    // Clear List
    peerList.clear();

    // Iterate through peers and IDs
    lobby.peers.forEach((id, peer) {
      // Add to Stack Items
      if (peer.platform != Platform.Android || peer.platform != Platform.iOS) {
        children.add(peer);
      }
    });

    // Update View
    setState(() {
      lobbySize = lobby.size;
      peerList = children;
    });
  }
}
