import 'dart:async';
import 'package:get/get.dart' hide Node;
import 'package:motion_sensors/motion_sensors.dart';
import 'package:sonr_app/theme/theme.dart';
import 'package:sonr_core/sonr_core.dart';

class LobbyService extends GetxService {
  // Accessors
  static bool get isRegistered => Get.isRegistered<LobbyService>();
  static LobbyService get to => Get.find<LobbyService>();

  // @ Set Properties
  final _flatModeCancelled = false.obs;
  final _lastIsFacingFlat = false.obs;
  final _isFlatMode = false.obs;
  final _lobbies = RxMap<String, Lobby>();
  final _local = Rx<Lobby>();
  final _localFlatPeers = RxMap<String, Peer>();
  final _localSize = 0.obs;
  final _position = Rx<VectorPosition>();
  final counter = 0.0.obs;
  final flatOverlayIndex = (-1).obs;

  // @ Routing to Reactive
  static RxBool get isFlatMode => Get.find<LobbyService>()._isFlatMode;
  static RxMap<String, Lobby> get lobbies => Get.find<LobbyService>()._lobbies;
  static Rx<Lobby> get local => Get.find<LobbyService>()._local;
  static RxMap<String, Peer> get localFlatPeers => Get.find<LobbyService>()._localFlatPeers;
  static RxInt get localSize => Get.find<LobbyService>()._localSize;
  static Rx<VectorPosition> get userPosition => to._position;

  // @ References
  bool get _flatModeEnabled => !_flatModeCancelled.value && UserService.flatModeEnabled && Get.currentRoute != "/transfer";
  StreamSubscription<AccelerometerEvent> _accelStream;
  StreamSubscription<CompassEvent> _compassStream;
  Timer _timer;

  // # Initialize Service Method ^ //
  Future<LobbyService> init() async {
    _accelStream = DeviceService.accelerometer.listen(_handleAccelStream);
    _compassStream = DeviceService.compass.listen(_handleCompassStream);
    return this;
  }

  // # On Service Close //
  @override
  void onClose() {
    _accelStream.cancel();
    _compassStream.cancel();
    super.onClose();
  }

  // ^ Method to Cancel Flat Mode ^ //
  void cancelFlatMode() {
    // Reset Timers
    _flatModeCancelled(true);
    _resetTimer();
    Get.back();
    Future.delayed(25.seconds, () {
      _flatModeCancelled(false);
    });
  }

  // ^ Method to Listen to Specified Lobby ^ //
  static StreamSubscription<Lobby> listenToLobby(String name, Function(Lobby) onData) {
    return _LobbyStream(name).stream.listen(onData);
  }

  // ^ Method to Listen to Specified Peer ^ //
  static StreamSubscription<Peer> listenToPeer(Peer peer, Function(Peer) onData, {Lobby lobby}) {
    return _PeerStream(peer, lobby != null ? lobby : local.value).stream.listen(onData);
  }

  // ^ Method to Cancel Flat Mode ^ //
  bool sendFlatMode(Peer peer) {
    // Send Invite
    SonrService.queueContact(isFlat: true);
    SonrService.inviteWithPeer(peer);

    // Reset Timers
    _flatModeCancelled(true);
    _resetTimer();
    Future.delayed(15.seconds, () {
      _flatModeCancelled(false);
    });

    SonrSnack.success("Sent Contact to ${LobbyService.localFlatPeers.values.first.profile.firstName}");
    Get.back();
    return true;
  }

  // # Handle Lobby Update //
  void handleRefresh(Lobby data) {
    // @ Update Local Topics
    if (data.isLocal) {
      // Update Local
      _handleFlatPeers(data);
      _local(data);
      _localSize(data.count);
      _local.refresh();
    }

    // @ Update Other Topics
    else {
      _lobbies[data.name] = data;
      _lobbies.refresh();
    }
  }

  // # Handle Lobby Flat Peers ^ //
  void _handleFlatPeers(Lobby data) {
    var flatPeers = <String, Peer>{};
    data.peers.forEach((id, peer) {
      if (peer.properties.isFlatMode) {
        flatPeers[id] = peer;
      }
    });
    _localFlatPeers(flatPeers);
    _localFlatPeers.refresh();
  }

  // # Handle Incoming Acceleromter Stream
  void _handleAccelStream(AccelerometerEvent data) {
    if (_flatModeEnabled) {
      var newIsFacingFlat = data.y < 2.75;
      if (newIsFacingFlat != _lastIsFacingFlat.value) {
        if (newIsFacingFlat) {
          _startTimer();
          _lastIsFacingFlat(data.y < 2.75);
        } else {
          _resetTimer();
        }
      }
    }
  }

  void _handleCompassStream(CompassEvent data) {
    // Set Vector Position
    _position(VectorPosition.fromQuadruple(DeviceService.direction));
  }

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
          SonrService.setFlatMode(true);

          // Present View
          if (_localFlatPeers.length > 0 && !_flatModeCancelled.value) {
            FlatMode.outgoing();
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
    SonrService.setFlatMode(false);
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
      _lastIsFacingFlat(false);
      counter(0);
    }
  }
}

class _LobbyStream {
  final String name;

  _LobbyStream(this.name) {
    LobbyService.lobbies.listen((Map<String, Lobby> map) {
      if (map[name] != null) {
        _controller.sink.add(map[name]);
      }
    });
  }

  // ignore: close_sinks
  final _controller = StreamController<Lobby>();
  Stream<Lobby> get stream => _controller.stream;
}

class _PeerStream {
  final Peer peer;
  final Lobby lobby;

  _PeerStream(this.peer, this.lobby) {
    LobbyService.lobbies.listen((Map<String, Lobby> map) {
      if (map[lobby.name] != null) {
        if (map[lobby.name].peers[peer.id.peer] != null) {
          _controller.sink.add(map[lobby.name].peers[peer.id.peer]);
        }
      }
    });
  }

  // ignore: close_sinks
  final _controller = StreamController<Peer>();
  Stream<Peer> get stream => _controller.stream;
}