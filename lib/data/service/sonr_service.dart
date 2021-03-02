import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Node;
import 'package:sonr_app/core/core.dart';
import 'package:sonr_app/modules/transfer/peer_controller.dart';
import 'package:sonr_core/sonr_core.dart';
import 'media_service.dart';
import 'sql_service.dart';
import 'user_service.dart';
export 'package:sonr_core/sonr_core.dart';

class SonrService extends GetxService with TransferQueue {
  // @ Set Properties
  final _connected = false.obs;
  final _peers = Map<String, Peer>().obs;
  final _lobbySize = 0.obs;
  final _progress = 0.0.obs;
  static RxMap<String, Peer> get peers => Get.find<SonrService>()._peers;
  static RxInt get lobbySize => Get.find<SonrService>()._lobbySize;
  static RxBool get connected => Get.find<SonrService>()._connected;
  static SonrService get to => Get.find<SonrService>();
  static RxDouble get progress => Get.find<SonrService>()._progress;
  // @ Set References
  Node _node;

  // ^ Updates Node^ //
  SonrService() {
    DeviceService.direction.listen((dir) {
      if (_connected.value) {
        // Update Direction
        _node.update(dir.headingForCameraMode);
      }
    });
  }

  // ^ Initialize Service Method ^ //
  Future<SonrService> init() async {
    // Validate Location
    if (DeviceService.hasPosition) {
      // Create Worker
      _node = await SonrCore.initialize(DeviceService.lat, DeviceService.lon, UserService.username, UserService.current.contact);

      // Set Callbacks
      _node.onConnected = _handleConnected;
      _node.onRefreshed = _handleRefresh;
      _node.onDirected = _handleDirect;
      _node.onInvited = _handleInvited;
      _node.onReplied = _handleResponded;
      _node.onProgressed = _handleProgress;
      _node.onReceived = _handleReceived;
      _node.onTransmitted = _handleTransmitted;
      _node.onError = _handleError;
      _connected(true);
      return this;
    }
    _connected(false);
    return this;
  }

  // ***********************
  // ******* Events ********
  // ***********************
  // ^ Connect to Sonr Network ^
  static connect() async {
    // Validate Location
    if (DeviceService.hasPosition && !to._connected.value) {
      // Create Worker
      to._node = await SonrCore.initialize(DeviceService.lat, DeviceService.lon, UserService.username, UserService.current.contact);

      // Set Callbacks
      to._node.onConnected = to._handleConnected;
      to._node.onRefreshed = to._handleRefresh;
      to._node.onDirected = to._handleDirect;
      to._node.onInvited = to._handleInvited;
      to._node.onReplied = to._handleResponded;
      to._node.onProgressed = to._handleProgress;
      to._node.onReceived = to._handleReceived;
      to._node.onTransmitted = to._handleTransmitted;
      to._node.onError = to._handleError;

      // Set Connected
      to._connected(true);
    }
  }

  // ^ Sets Contact for Node ^
  static void setContact(Contact contact) async {
    // - Check Connected -
    if (to._connected.conn) {
      await to._node.setContact(contact);
    }
  }

  // ^ Set Payload for Contact ^ //
  static queueContact() async {
    // - Check Connected -
    if (to._connected.conn) {
      to.addToQueue(TransferQueueItem.contact());
    }
  }

  // ^ Set Payload for Media ^ //
  static queueMedia(MediaFile media) async {
    // - Check Connected -
    if (to._connected.conn) {
      to.addToQueue(TransferQueueItem.media(media));
    }
  }

  // ^ Set Payload for URL Link ^ //
  static queueUrl(String url) async {
    // - Check Connected -
    if (to._connected.conn) {
      to.addToQueue(TransferQueueItem.url(url));
    }
  }

  // ^ Invite-Peer Event ^
  static invite(PeerController c) async {
    if (to._connected.conn) {
      // Set Peer Controller
      to.currentInvited(c);

      // File Payload
      if (to.payload == Payload.MEDIA) {
        assert(to.currentTransfer.media != null);
        await to._node.inviteFile(c.peer, to.currentTransfer.media);
      }

      // Contact Payload
      else if (to.payload == Payload.CONTACT) {
        await to._node.inviteContact(c.peer);
      }

      // Link Payload
      else if (to.payload == Payload.URL) {
        assert(to.currentTransfer.url != null);
        await to._node.inviteLink(c.peer, to.currentTransfer.url);
      }

      // No Payload
      else {
        SonrSnack.error("No media, contact, or link provided");
      }
    }
  }

  // ^ Respond-Peer Event ^
  static respond(bool decision) async {
    if (to._connected.conn) {
      // Send Response
      await to._node.respond(decision);
    }
  }

  // ^ Async Function notifies transfer complete ^ //
  static Future<TransferCard> completed() async {
    if (!to._connected.value) {
      SonrSnack.error("Not Connected to the Sonr Network");
      to.received.completeError("Error Transferring File");
    }
    return to.received.future;
  }

  // **************************
  // ******* Callbacks ********
  // **************************
  // ^ Handle Connected to Bootstrap Nodes ^ //
  void _handleConnected() {
    _node.update(DeviceService.direction.value.headingForCameraMode);
  }

  // ^ Handle Lobby Update ^ //
  void _handleRefresh(Lobby data) {
    _peers(data.peers);
    _lobbySize(data.peers.length);
  }

  // ^ Node Has Been Directed from Other Device ^ //
  void _handleDirect(TransferCard data) async {
    HapticFeedback.heavyImpact();
  }

  // ^ Node Has Been Invited ^ //
  void _handleInvited(AuthInvite data) async {
    if (!Get.isDialogOpen) {
      HapticFeedback.heavyImpact();
      SonrOverlay.invite(data);
    }
  }

  // ^ Node Has Been Accepted ^ //
  void _handleResponded(AuthReply data) async {
    // Check if Sent Back Contact
    if (data.type == AuthReply_Type.Contact) {
      HapticFeedback.vibrate();
      SonrOverlay.reply(data);
    }
    // For Cancel
    else if (data.type == AuthReply_Type.Cancel) {
      HapticFeedback.vibrate();
      currentDecided(false);
    } else {
      // For File
      currentDecided(data.decision);
    }
  }

  // ^ Transfer Has Updated Progress ^ //
  void _handleProgress(double data) async {
    _progress(data);
  }

  // ^ Resets Peer Info Event ^
  void _handleTransmitted(Peer data) async {
    currentCompleted();
  }

  // ^ Mark as Received File ^ //
  Future<void> _handleReceived(TransferCard data) async {
    HapticFeedback.heavyImpact();

    // Save Card to Gallery
    MediaService.saveTransfer(data).then((value) {
      data.hasExported = value;
      received.complete(data);
      Get.find<SQLService>().storeCard(data);
    });
  }

  // ^ An Error Has Occurred ^ //
  void _handleError(ErrorMessage data) async {
    print(data.method + "() - " + data.message);
    SonrSnack.error("Internal Error Occurred");
  }
}

extension SonrSnackbarAction on RxBool {
  bool get conn {
    if (this.value) {
      return true;
    } else {
      SonrSnack.error("Not Connected to the Sonr Network");
      return false;
    }
  }
}