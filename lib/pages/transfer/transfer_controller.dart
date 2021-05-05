import 'dart:async';
import 'dart:math';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:sonr_app/data/data.dart';
import 'package:sonr_app/service/device/mobile.dart';
import 'package:sonr_app/theme/theme.dart';

class TransferController extends GetxController {
  // @ Accessors
  Payload get currentPayload => inviteRequest.value.payload;

  // @ Properties
  final title = "Nobody Here".obs;
  final isNotEmpty = false.obs;
  final isFacingPeer = false.obs;
  final inviteRequest = InviteRequest().obs;
  final sonrFile = Rx<SonrFile>(null);

  // @ Remote Properties
  final counter = 0.obs;
  final remote = Rx<RemoteInfo>(null);

  // @ Direction Properties
  final angle = 0.0.obs;
  final degrees = 0.0.obs;
  final direction = 0.0.obs;
  final isShiftingEnabled = true.obs;

  // @ View Properties
  final directionTitle = "".obs;
  final cardinalTitle = "".obs;

  // References
  StreamSubscription<int> _lobbySizeStream;
  StreamSubscription<Position> _positionStream;
  CarouselController carouselController = CarouselController();

  // ^ Controller Constructer ^
  void onInit() {
    // Set Initial Value
    _handlePositionUpdate(MobileService.position.value);
    _handleLobbySizeUpdate(LobbyService.localSize.value);

    // Add Stream Handlers
    _positionStream = MobileService.position.listen(_handlePositionUpdate);
    _lobbySizeStream = LobbyService.localSize.listen(_handleLobbySizeUpdate);

    super.onInit();
  }

  // ^ On Dispose ^ //
  @override
  void onClose() {
    _positionStream.cancel();
    _lobbySizeStream.cancel();
    super.onClose();
  }

  // ^ Send Invite with Peer ^ //
  void invitePeer(Peer peer) {
    setFacingPeer(false);
    isShiftingEnabled(false);

    // Update Request
    inviteRequest.update((val) {
      val.to = peer;
    });

    // Send Invite
    SonrService.invite(inviteRequest.value);
  }

  // ^ Set Transfer Payload ^ //
  void setPayload(dynamic args) {
    // Validate Args
    if (args is TransferArguments) {
      // Contact
      if (args.payload == Payload.CONTACT) {
        inviteRequest.update((val) {
          val.payload = args.payload;
          val.contact = args.contact;
          val.payload = Payload.CONTACT;
        });
      }
      // URL
      else if (args.payload == Payload.URL) {
        inviteRequest.update((val) {
          val.payload = args.payload;
          val.url = args.url;
          val.payload = Payload.URL;
        });
      }
      // File
      else {
        // Set File Item
        sonrFile(args.file);
        inviteRequest.update((val) {
          val.file = args.file;
          val.payload = args.file.payload;
        });
      }
    } else {
      print("Invalid Arguments Provided for Transfer");
    }
  }

  // ^ User is Facing or No longer Facing a Peer ^ //
  void setFacingPeer(bool value) {
    isFacingPeer(value);
    isFacingPeer.refresh();
  }

  // ^ Toggles Peer Shifting ^ //
  void toggleShifting() {
    isShiftingEnabled(!isShiftingEnabled.value);
  }

  // # Handle Compass Update ^ //
  _handlePositionUpdate(Position pos) {
    // Update String Elements
    if (pos != null && !isClosed) {
      directionTitle(_stringForDirection(pos.facing.direction));
      cardinalTitle(_cardinalStringForDirection(pos.facing.direction));

      // Reference
      direction(pos.facing.direction);
      angle(((pos.facing.direction ?? 0) * (pi / 180) * -1));

      // Calculate Degrees
      if (pos.facing.direction + 90 > 360) {
        degrees(pos.facing.direction - 270);
      } else {
        degrees(pos.facing.direction + 90);
      }
    }
  }

  // # Handle Lobby Size Update ^ //
  _handleLobbySizeUpdate(int size) {
    if (size == 0) {
      isNotEmpty(false);
      title("Nobody Here");
    } else if (size == 1) {
      isNotEmpty(true);
      title("1 Person");
    } else {
      isNotEmpty(true);
      title("$size People");
    }
  }

  // # Return String Value for Direction ^ //
  _stringForDirection(double dir) {
    // Calculated
    var adjustedDegrees = dir.round();
    final unit = "°";

    // @ Convert To String
    if (adjustedDegrees >= 0 && adjustedDegrees <= 9) {
      return "0" + "0" + adjustedDegrees.toString() + unit;
    } else if (adjustedDegrees > 9 && adjustedDegrees <= 99) {
      return "0" + adjustedDegrees.toString() + unit;
    } else {
      return adjustedDegrees.toString() + unit;
    }
  }

  // # Return Cardinal Value for Direction ^ //
  _cardinalStringForDirection(double dir) {
    var adjustedDesignation = ((dir.round() / 11.25) + 0.25).toInt();
    var compassEnum = Cardinal.values[(adjustedDesignation % 32)];
    return compassEnum.toString().substring(compassEnum.toString().indexOf('.') + 1);
  }
}
