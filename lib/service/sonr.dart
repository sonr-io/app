import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Node;
import 'package:sonr_app/data/data.dart';
import 'package:sonr_app/modules/common/peer/peer.dart';
import 'package:sonr_app/theme/theme.dart';
import 'package:sonr_core/sonr_core.dart';
import 'cards.dart';
import 'lobby.dart';
import 'user.dart';
export 'package:sonr_core/sonr_core.dart';

extension StatusUtils on Status {
  bool get isNotConnected => this == Status.NONE;
  bool get isConnecting => this == Status.NONE || this == Status.CONNECTED;
  bool get isConnected => this != Status.NONE;
  bool get isReady => this == Status.BOOTSTRAPPED;
}

class SonrService extends GetxService with TransferQueue {
  // Accessors
  static bool get isRegistered => Get.isRegistered<SonrService>();
  static SonrService get to => Get.find<SonrService>();

  // @ Set Properties
  final _isReady = false.obs;
  final _progress = 0.0.obs;
  final _properties = Peer_Properties().obs;
  final _status = Rx<Status>(Status.NONE);

  // @ Static Accessors
  static RxDouble get progress => to._progress;
  static Rx<Status> get status => to._status;

  // @ Set References
  Node _node;
  Function(AuthInvite) _remoteCallback;

  // ^ Updates Node^ //
  SonrService() {
    Timer.periodic(250.milliseconds, (timer) {
      if (DeviceService.isMobile && SonrRouting.areServicesRegistered && isRegistered) {
        // Publish Position
        if (to._isReady.value) {
          DeviceService.compass.value ?? _node.update(direction: DeviceService.direction);
        }
      }
    });
  }

  // @ Register Handler for Remote Invite
  void registerRemoteInvite(Function(AuthInvite) invite) {
    _remoteCallback = invite;
  }

  // ^ Initialize Service Method ^ //
  Future<SonrService> init() async {
    // Initialize
    _properties(Peer_Properties(hasPointToShare: UserService.pointShareEnabled));

    // Check for Connect Requirements
    if (UserService.hasRequiredToConnect) {
      var pos = await DeviceService.currentLocation();

      // Create Node
      _node = await SonrCore.initialize(pos.latitude, pos.longitude, UserService.username, UserService.contact.value);
      _node.onStatus = _handleStatus;
      _node.onRefreshed = Get.find<LobbyService>().handleRefresh;
      _node.onInvited = _handleInvited;
      _node.onReplied = _handleResponded;
      _node.onProgressed = _handleProgress;
      _node.onReceived = _handleReceived;
      _node.onTransmitted = _handleTransmitted;
      _node.onError = _handleError;
      return this;
    } else {
      return this;
    }
  }

  // ^ Connect to Service Method ^ //
  Future<void> connect() async {
    if (_node == null) {
      // Get Data
      var pos = await DeviceService.currentLocation();

      // Create Node
      _node = await SonrCore.initialize(pos.latitude, pos.longitude, UserService.username, UserService.contact.value);
      _node.onStatus = _handleStatus;
      _node.onRefreshed = Get.find<LobbyService>().handleRefresh;
      _node.onEvent = Get.find<LobbyService>().handleEvent;
      _node.onInvited = _handleInvited;
      _node.onReplied = _handleResponded;
      _node.onProgressed = _handleProgress;
      _node.onReceived = _handleReceived;
      _node.onTransmitted = _handleTransmitted;
      _node.onError = _handleError;

      // Connect Node
      _node.connect();
      _node.update(direction: DeviceService.direction);
    } else {
      _node.connect();
      _node.update(direction: DeviceService.direction);
    }
  }

  // ^ Connect to Service Method ^ //
  Future<void> connectNewUser(Contact contact, String username) async {
    // Get Data
    var pos = await DeviceService.currentLocation();

    // Create Node
    _node = await SonrCore.initialize(pos.latitude, pos.longitude, UserService.username, UserService.contact.value);
    _node.onStatus = _handleStatus;
    _node.onRefreshed = Get.find<LobbyService>().handleRefresh;
    _node.onInvited = _handleInvited;
    _node.onReplied = _handleResponded;
    _node.onProgressed = _handleProgress;
    _node.onReceived = _handleReceived;
    _node.onTransmitted = _handleTransmitted;
    _node.onError = _handleError;

    // Connect Node
    _node.connect();
    _node.update(direction: DeviceService.direction);
  }

  // ^ Join a New Group ^
  static Future<RemoteInfo> createRemote() async {
    var data = await to._node.createRemote();
    return data;
  }

  // ^ Join a New Group ^
  static Future<RemoteInfo> joinRemote(List<String> words) async {
    // Extract Data
    var display = "${words[0]} ${words[1]} ${words[2]}";
    var topic = "${words[0]}-${words[1]}-${words[2]}";

    // Perform Routine
    var remote = RemoteInfo(isJoin: true, topic: topic, display: display, words: words);
    await to._node.joinRemote(remote);
    return remote;
  }

  // ^ Leave a Remote Group ^
  static void leaveRemote(RemoteInfo info) async {
    // Perform Routine
    await to._node.leaveRemote(info);
  }

  // ^ Sets Properties for Node ^
  static void setFlatMode(bool isFlatMode) async {
    if (to._properties.value.isFlatMode != isFlatMode) {
      to._properties(Peer_Properties(hasPointToShare: UserService.pointShareEnabled, isFlatMode: isFlatMode));
      await to._node.update(properties: to._properties.value);
    }
  }

  // ^ Sets Contact for Node ^
  static void setProfile(Contact contact) async {
    await to._node.update(contact: contact);
  }

  // ^ Set Payload for Contact ^ //
  static void queueContact({bool isFlat = false}) async {
    // - Check Connected -
    to.addToQueue(TransferQueueItem.contact(isFlat: isFlat));
  }

  // ^ Set Payload for URL Link ^ //
  static void queueCapture(MediaFile media) async {
    // - Check Connected -
    to.addToQueue(TransferQueueItem.capture(media));
  }

  // ^ Set Payload for URL Link ^ //
  static void queueMedia(MediaItem media) async {
    // - Check Connected -
    to.addToQueue(TransferQueueItem.media(await media.getMetadata()));
  }

  // ^ Set Payload for URL Link ^ //
  static void queueUrl(String url) async {
    // - Check Connected -
    to.addToQueue(TransferQueueItem.url(url));
  }

  // ^ Direct Message a Peer ^
  static void message(Peer peer, String content) {
    to._node.message(peer, content);
  }

  // ^ Invite Peer with Built Request ^ //
  static void invite(InviteRequest request, {BubbleController c}) async {
    // Set Controller if Valid
    c ?? to.currentInvited(c);

    // Send Invite
    await to._node.invite(request);
  }

  // ^ Invite-Peer Event ^
  static void inviteWithPeer(Peer p, {RemoteInfo info}) async {
    // Set Peer Controller
    to.currentInvitedFromList(p);

    // File Payload
    if (to.payload == Payload.MEDIA) {
      assert(to.currentTransfer.media != null);
      await to._node.inviteFile(p, to.currentTransfer.media, info: info);
    }

    // Contact Payload
    else if (to.payload == Payload.CONTACT) {
      await to._node.inviteContact(p, isFlat: to.currentTransfer.isFlat, info: info);
    }

    // Link Payload
    else if (to.payload == Payload.URL) {
      assert(to.currentTransfer.url != null);
      await to._node.inviteLink(p, to.currentTransfer.url, info: info);
    }

    // No Payload
    else {
      SonrSnack.error("No media, contact, or link provided");
    }
  }

  // ^ Respond-Peer Event ^
  static void respond(bool decision, {RemoteInfo info}) async {
    await to._node.respond(decision, info: info);
  }

  // ^ Async Function notifies transfer complete ^ //
  static Future<TransferCard> completed() async {
    return to.received.future;
  }

  // **************************
  // ******* Callbacks ********
  // **************************
  // ^ Handle Bootstrap Result ^ //
  void _handleStatus(StatusUpdate data) {
    // Check for Homescreen Controller
    if (Get.isRegistered<DeviceService>() && data.value == Status.BOOTSTRAPPED) {
      // Update Status
      _isReady(true);
      _status(data.value);
      DeviceService.playSound(type: UISoundType.Connected);

      // Handle Available
      _node.update(direction: DeviceService.direction);
    }
  }

  // ^ Node Has Been Invited ^ //
  void _handleInvited(AuthInvite data) async {
    if (data.hasRemote() && _remoteCallback != null) {
      _remoteCallback(data);
    }

    // Present Overlay
    if (SonrOverlay.isNotOpen) {
      await HapticFeedback.heavyImpact();
      // Check for Flat
      if (data.isFlat && data.payload == Payload.CONTACT) {
        FlatMode.invite(data.card);
      } else {
        SonrOverlay.invite(data);
      }
    }
  }

  // ^ Node Has Been Accepted ^ //
  void _handleResponded(AuthReply data) async {
    if (data.type == AuthReply_Type.FlatContact) {
      await HapticFeedback.heavyImpact();
      FlatMode.response(data.card);
    }

    if (data.type == AuthReply_Type.Contact) {
      await HapticFeedback.vibrate();
      SonrOverlay.reply(data);
    }
    // For Cancel
    else if (data.type == AuthReply_Type.Cancel) {
      await HapticFeedback.vibrate();
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
    await currentCompleted();
    DeviceService.playSound(type: UISoundType.Transmitted);
  }

  // ^ Mark as Received File ^ //
  Future<void> _handleReceived(TransferCard data) async {
    await HapticFeedback.heavyImpact();

    // Save Card to Gallery
    CardService.addCard(data);
    DeviceService.playSound(type: UISoundType.Received);
  }

  // ^ An Error Has Occurred ^ //
  void _handleError(ErrorMessage data) async {
    print(data.toString());
    if (data.severity != ErrorMessage_Severity.LOG) {
      SonrSnack.error("", error: data);
    }
  }
}
