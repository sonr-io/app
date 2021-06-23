import 'dart:async';
import 'package:get/get.dart' hide Node;
import 'package:sonr_app/data/services/services.dart';
import 'package:sonr_app/style.dart';
import 'package:sonr_plugin/sonr_plugin.dart';

class LobbyService extends GetxService {
  // Accessors
  static bool get isRegistered => Get.isRegistered<LobbyService>();
  static LobbyService get to => Get.find<LobbyService>();
  static RxBool get isFlatMode => to._isFlatMode;
  static Rx<Lobby> get lobby => to._lobby;
  static Rx<Lobby_Status> get status => to._status;

  // Properties
  final counter = 0.0.obs;
  final _flatModeCancelled = false.obs;
  final _lastIsFacingFlat = false.obs;
  final _isFlatMode = false.obs;
  final _lobby = Lobby().obs;
  final _localFlatPeers = RxMap<String, Peer>();
  final _position = Position().obs;
  final _status = Rx<Lobby_Status>(Lobby_Status.Empty);

  // References
  late final Lobby_Info _localInfo;
  late StreamSubscription<Position>? _positionStream;
  late StreamSubscription<Lobby> _lobbyStream;
  late Timer? _timer;
  Map<Peer?, PeerCallback> _peerCallbacks = <Peer?, PeerCallback>{};

  // ^ Constructer ^ //
  Future<LobbyService> init() async {
    if (DeviceService.isMobile) {
      _positionStream = DeviceService.position.listen(_handlePosition);
    }
    _lobbyStream = _lobby.listen(_lobbyListener);
    return this;
  }

  // ^ Dispose Closer ^ //
  @override
  void onClose() {
    if (_positionStream != null) {
      _positionStream!.cancel();
    }
    _lobbyStream.cancel();
    super.onClose();
  }

// * ------------------- Methods ----------------------------
  /// @ Attaches Lobby Local Info to Invite Request
  static void attachLocalInfo(InviteRequest req) {
    if (isRegistered) {
      req.info = to._localInfo;
    }
  }

  /// @ Method to Cancel Flat Mode
  void cancelFlatMode() {
    // Reset Timers
    _flatModeCancelled(true);
    _resetTimer();
    Get.back();
    Future.delayed(25.seconds, () {
      _flatModeCancelled(false);
    });
  }

  /// @ Registers Peer to Callback
  static void registerPeerCallback(Peer peer, PeerCallback callback) {
    if (isRegistered) {
      to._peerCallbacks[peer] = callback;
    }
  }

  /// @ Removes Peer Callback
  static void unregisterPeerCallback(Peer? peer) {
    if (isRegistered) {
      if (to._peerCallbacks.containsKey(peer)) {
        to._peerCallbacks.remove(peer);
      }
    }
  }

  /// @ Set Local Lobby Info
  static void setLocalInfo(Lobby_Info info) {
    if (isRegistered) {
      to._localInfo = info;
    }
  }

  /// @ Method to Cancel Flat Mode
  bool sendFlatMode(Peer? peer) {
    // Send Invite
    NodeService.sendFlat(peer);

    // Reset Timers
    _flatModeCancelled(true);
    _resetTimer();
    Future.delayed(15.seconds, () {
      _flatModeCancelled(false);
    });
    var flatPeer = LobbyService.lobby.value.flatFirst()!;
    AppRoute.snack(SnackArgs.success("Sent Contact to ${flatPeer.profile.firstName}"));
    Get.back();
    return true;
  }

  // # Handle Individual user event
  void handleEvent(LobbyEvent data) => _lobby.handleEvent(data);

  // # Handle Incoming Position Stream
  void _handlePosition(Position data) {
    // Initialize
    bool flatModeEnabled = !_flatModeCancelled.value && Preferences.flatModeEnabled && AppRoute.isNotCurrent(AppPage.Transfer);

    // Update Orientation
    if (flatModeEnabled && _localFlatPeers.length > 0) {
      var newIsFacingFlat = data.accelerometer.y < 2.75;
      if (newIsFacingFlat != _lastIsFacingFlat.value) {
        if (newIsFacingFlat) {
          _startTimer();
          _lastIsFacingFlat(data.accelerometer.y < 2.75);
        } else {
          _resetTimer();
        }
      }
    }

    // Set Vector Position
    _position(data);
  }

// * ------------------- Helpers ----------------------------
  // # Begin Facing Invite Check
  void _startTimer() {
    _timer = Timer.periodic(500.milliseconds, (_) {
      // Add MS to Counter
      counter(counter.value += 500);

      // Check if Facing
      if (counter.value == 2000) {
        if (_lastIsFacingFlat.value) {
          // Update Refs
          _isFlatMode(true);
          Preferences.setFlatMode(true);

          // Present View
          if (_localFlatPeers.length == 0 && !_flatModeCancelled.value) {
            AppPage.Flat.outgoing();
          } else {
            _resetTimer();
          }
        } else {
          _resetTimer();
        }
      }
    });
  }

  // # Stop Timer for Facing Check
  void _resetTimer() {
    _isFlatMode(false);
    Preferences.setFlatMode(false);
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      _lastIsFacingFlat(false);
      counter(0);
    }
  }

// * ------------------- Callbacks ----------------------------
  // # Handle Lobby Update //
  void _lobbyListener(Lobby data) {
    // Handle Peer Callbacks
    data.peers.forEach((id, peer) {
      if (_peerCallbacks.containsKey(peer)) {
        var call = _peerCallbacks[peer]!;
        call(peer);
      }
    });

    // @ Update Local Topics
    if (data.type == TopicType.LOCAL) {
      // Update Status
      _status(LobbyStatusUtils.localStatusFromCount(data.count));

      // Update Flat Peers
      var flatPeers = <String, Peer>{};
      data.peers.forEach((id, peer) {
        if (peer.properties.isFlatMode) {
          flatPeers[id] = peer;
        }
      });
      _localFlatPeers(flatPeers);
      _localFlatPeers.refresh();
      ;
    }
  }
}
