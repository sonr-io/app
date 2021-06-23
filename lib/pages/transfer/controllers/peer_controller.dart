import 'package:rive/rive.dart';
import 'package:sonr_app/data/services/services.dart';
import 'dart:async';
import 'package:sonr_app/style.dart';
import 'transfer_controller.dart';

/// @ Reactive Controller for Peer Bubble
class PeerController extends GetxController with SingleGetTickerProviderMixin {
  // Required Properties
  final Future<RiveFile> riveFile;

  // Reactive Elements
  final board = Rx<Artboard?>(null);
  final counter = 0.0.obs;
  final isReady = false.obs;
  final isVisible = true.obs;
  final isComplete = false.obs;
  final peer = Rx<Peer>(Peer());
  final status = SessionStatus.Default.obs;

  // Vector Properties
  final isHitting = false.obs;
  final relative = 0.0.obs;
  final relativePosition = RelativePosition.Center.obs;
  final borderWidth = 0.0.obs;
  final buttonData = DynamicSolidButtonData.invite().obs;

  // References
  late final AnimationController visibilityController;
  StreamSubscription<Position>? _userStream;
  bool _handlingHit = false;
  bool get isHittingValid => peer.value.isHitFrom(DeviceService.position.value) && status.value.isNone;

  // State Machine
  SMIInput<bool>? _isIdle;
  SMIInput<bool>? _isPending;
  SMIInput<bool>? _hasAccepted;
  SMIInput<bool>? _hasDenied;
  SMIInput<bool>? _isComplete;
  PeerController(this.riveFile);

  @override
  void onInit() {
    visibilityController = AnimationController(vsync: this);
    super.onInit();
  }

  /// @ Method that Initializes Peer and Streams
  void initalize(Peer data, {bool setAnimated = true}) async {
    // Set Initial
    peer(data);
    isVisible(true);

    // Add Stream Handlers
    LobbyService.registerPeerCallback(peer.value, _handlePeerUpdate);

    // Check for Mobile
    if (DeviceService.isMobile) {
      _userStream = DeviceService.position.listen(_handlePosition);
    }

    // Set If Animated
    if (setAnimated) {
      // Get Values
      final file = await riveFile;
      final artboard = file.mainArtboard;
      var controller = StateMachineController.fromArtboard(artboard, 'State');

      // @ Set Controller
      if (controller != null) {
        // Import State Machine
        artboard.addController(controller);
        _isIdle = controller.findInput('IsIdle');
        _isPending = controller.findInput('IsPending');
        _hasAccepted = controller.findInput('HasAccepted');
        _hasDenied = controller.findInput('HasDenied');
        _isComplete = controller.findInput('IsComplete');

        // Set Defaults
        _isComplete!.value = false;
        _isPending!.value = false;
        _hasAccepted!.value = false;
        _hasDenied!.value = false;
        _isIdle!.value = true;

        // Observable Artboard
        board(artboard);
        isReady(true);
      }

      // Handle Error
      else {
        Logger.error("Failed to find animation controller");
        isReady(false);
      }
    }
  }

  /// ** Dispose on Close ** //
  @override
  void onClose() {
    LobbyService.unregisterPeerCallback(peer.value);
    if (_userStream != null) {
      _userStream!.cancel();
    }
    super.onClose();
  }

  /// @ Handle User Invitation
  void invite() {
    // Check Animated
    if (isReady.value && DeviceService.isMobile) {
      // Check not already Pending
      if (!_isPending!.value) {
        // Perform Invite
        var invite = InviteRequestUtils.copyWithPeer(TransferController.invite, this.peer.value);

        var session = SenderService.invite(invite);

        // Listen to Session
        if (session != null) {
          session.status.listen(_handleTransferStatus);
        }
      }
    }
  }

  /// @ Handle Peer Position
  void _handlePeerUpdate(Peer data) {
    if (!isClosed && !isComplete.value) {
      // Update Direction
      if (data.id.peer == peer.value.id.peer && !_isPending!.value) {
        peer(data);
      }
    }
  }

  // @ Handle Peer Response
  _handleTransferStatus(SessionStatus data) {
    switch (data) {
      case SessionStatus.Pending:
        isVisible(true);
        _isPending!.value = true;
        buttonData(DynamicSolidButtonData.pending());
        buttonData.refresh();
        break;
      case SessionStatus.Accepted:
        isVisible(false);
        _hasAccepted!.value = true;
        buttonData(DynamicSolidButtonData.inProgress());
        buttonData.refresh();
        break;
      case SessionStatus.Denied:
        isVisible(false);
        _hasDenied!.value = true;
        break;
      case SessionStatus.InProgress:
        break;
      case SessionStatus.Completed:
        isVisible(false);
        _isComplete!.value = true;
        buttonData(DynamicSolidButtonData.complete());
        buttonData.refresh();
        // Reset Status
        Future.delayed(1200.milliseconds, () {
          isComplete(true);
          isVisible(true);
          _isComplete!.value = false;
          _isPending!.value = false;
          _hasAccepted!.value = false;
          _hasDenied!.value = false;
          _isIdle!.value = true;
        });
        break;
      default:
        isVisible(true);
        _isComplete!.value = false;
        _isPending!.value = false;
        _hasAccepted!.value = false;
        _hasDenied!.value = false;
        _isIdle!.value = true;
        buttonData(DynamicSolidButtonData.invite());
        break;
    }
  }

  // @ Handle User Position
  void _handlePosition(Position data) async {
    if (!isClosed && !isComplete.value) {
      // Find Offset
      if (peer.value.platform.isMobile) {
        isHitting(data.hasHitSphere(peer.value.position));
        relative(data.difference(peer.value.position));
        relativePosition(data.differenceRelative(peer.value.position));
      }

      // Feedback
      if (status.value.isNone) {
        // Vibration
        if (isHitting.value) {
          HapticFeedback.lightImpact();
        }

        // Border
        borderWidth(relative.value.clamp(0, 5));
      }

      // Check if Facing
      if (!_handlingHit) {
        await _handleHitting();
      }
    }
  }

  Future<void> _handleHitting({int milliseconds = 2750}) async {
    _handlingHit = true;
    if (isHitting.value) {
      await Future.delayed(Duration(milliseconds: milliseconds));

      if (isHittingValid) {
        invite();
      }
    }
    _handlingHit = false;
  }
}
