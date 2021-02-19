import 'package:get/get.dart';
import 'package:sonr_app/modules/media/camera_view.dart';
import 'package:sonr_app/modules/media/picker_sheet.dart';
import 'package:sonr_app/modules/media/preview_view.dart';
import 'media_screen.dart';
export 'media_screen.dart';

class CameraBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MediaScreenController>(MediaScreenController(), permanent: true);
    Get.put<CameraController>(CameraController(), permanent: true);
    Get.put<MediaPickerController>(MediaPickerController(), permanent: true);
    Get.lazyPut<PreviewController>(() => PreviewController());
  }
}