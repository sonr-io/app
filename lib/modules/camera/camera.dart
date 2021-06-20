import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sonr_app/modules/camera/views/capture.dart';
import 'package:sonr_app/modules/camera/views/preview.dart';
import 'package:sonr_app/modules/camera/views/tools.dart';
import 'package:sonr_app/modules/camera/widgets/video_duration.dart';
import 'package:sonr_app/style.dart';
import 'camera_controller.dart';

class CameraView extends StatelessWidget {
  // Properties
  final Function(SonrFile file) onMediaSelected;
  CameraView({required this.onMediaSelected});

  static void open({required Function(SonrFile file) onMediaSelected}) {
    Get.to(
      CameraView(onMediaSelected: onMediaSelected),
      fullscreenDialog: true,
      transition: Transition.downToUp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetX<CameraController>(
        init: CameraController(onMediaSelected),
        global: false,
        autoRemove: false,
        builder: (controller) => Stack(
              children: [
                // Camera Window
                AnimatedSlider.fade(child: _buildWindowView(controller.status.value, controller)),

                // Button Tools View
                CameraToolsView(controller: controller),
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(left: 14, top: Get.statusBarHeight / 2),
                  child: PlainIconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: SonrIcons.Close.gradient(value: SonrGradients.PhoenixStart)),
                ),

                // Video Duration
                VideoDuration(controller: controller)
              ],
            ));
  }

  Widget _buildWindowView(CameraViewStatus status, CameraController controller) {
    if (status == CameraViewStatus.Default) {
      return CaptureWindow(controller: controller, key: ValueKey(true));
    } else {
      return PreviewView(controller: controller, key: ValueKey(false));
    }
  }
}