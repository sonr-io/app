import 'package:get/get.dart';
import 'package:sonar_app/modules/peer/peer_controller.dart';
import 'transfer_controller.dart';
export 'transfer_screen.dart';

class TransferBinding implements Bindings {
  @override
  void dependencies() {
    Get.create<PeerController>(() => PeerController());
    Get.put<CompassController>(CompassController());
  }
}