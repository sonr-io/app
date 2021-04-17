import 'package:get/get.dart';
import 'package:rive/rive.dart';
import 'package:sonr_app/modules/common/peer/peer.dart';
import 'package:sonr_app/modules/grid/grid_controller.dart';
import 'package:sonr_app/modules/profile/profile.dart';
import 'package:sonr_app/modules/profile/tile/tile_controller.dart';
import 'package:sonr_app/pages/home/home_controller.dart';
import 'package:sonr_app/modules/remote/remote_controller.dart';
import 'package:sonr_app/modules/share/share_controller.dart';
import 'package:sonr_app/pages/register/register_controller.dart';
import 'package:sonr_app/pages/transfer/transfer_controller.dart';
import 'package:sonr_app/theme/theme.dart';

// ^ Initial Controller Bindings ^ //
class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AssetController>(AssetController(), permanent: true);
    Get.lazyPut<CameraController>(() => CameraController());
  }
}

// ^ Profile Controller Bindings ^ //
class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<ShareController>(ShareController(), permanent: true);
    Get.put<GridController>(GridController(), permanent: true);
    Get.lazyPut<RemoteController>(() => RemoteController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<ProfilePictureController>(() => ProfilePictureController());
    Get.create<TileController>(() => TileController());
  }
}

// ^ Register Page Bindings ^ //
class RegisterBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<RegisterController>(RegisterController());
  }
}

// ^ Transfer Screen Bindings ^ //
class TransferBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<TransferController>(TransferController(), permanent: true);
    Get.create<PeerController>(() => PeerController(_getRiveDataFile()));
  }

  // Get Rive File for Peer Bubble
  Future<RiveFile> _getRiveDataFile() async {
    var data = await rootBundle.load('assets/rive/peer_bubble.riv');
    return RiveFile.import(data);
  }
}
