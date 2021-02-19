import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sonr_app/modules/media/camera_binding.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:sonr_app/theme/theme.dart';
import 'package:sonr_app/service/device_service.dart';
import 'package:sonr_app/service/sonr_service.dart';
import 'package:sonr_core/sonr_core.dart';
import 'package:sonr_core/models/models.dart';
import 'package:better_player/better_player.dart';

class MediaPreviewView extends GetView<PreviewController> {
  @override
  Widget build(BuildContext context) {
    // @ Build View
    return SafeArea(
      top: false,
      bottom: false,
      child: Obx(() {
        return Stack(
          children: [
            // Preview
            controller.isVideo.value
                ? _VideoCapturePlayer(file: File(controller.videoPath))
                : Positioned.fill(child: _PhotoCaptureView(path: controller.photoPath)),

            // Buttons
            _CaptureToolsView()
          ],
        );
      }),
    );
  }
}

class _CaptureToolsView extends GetView<PreviewController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: NeumorphicBackground(
        backendColor: Colors.transparent,
        child: Neumorphic(
          padding: EdgeInsets.only(top: 20, bottom: 40),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            // Left Button - Cancel and Retake
            SonrButton.circle(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  controller.clear();
                },
                icon: SonrIcon.close),

            // Right Button - Continue and Accept
            SonrButton.circle(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  controller.continueMedia();
                },
                icon: SonrIcon.accept),
          ]),
        ),
      ),
    );
  }
}

// ** Captured Photo View ** //
class _PhotoCaptureView extends StatelessWidget {
  final String path;

  const _PhotoCaptureView({Key key, @required this.path}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: Get.height,
      child: Image.file(File(path)),
    );
  }
}

// ** Captured Video View ** //
class _VideoCapturePlayer extends StatelessWidget {
  final File file;
  const _VideoCapturePlayer({Key key, @required this.file}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        width: Get.width,
        height: Get.height,
        child: AspectRatio(
            aspectRatio: 9 / 16,
            child: BetterPlayer.file(file.path,
                betterPlayerConfiguration: BetterPlayerConfiguration(
                  controlsConfiguration: BetterPlayerControlsConfiguration(),
                  allowedScreenSleep: false,
                  autoPlay: true,
                  looping: true,
                  aspectRatio: 9 / 16,
                ))));
  }
}

// ** Preview Capture View Controller ** //
class PreviewController extends GetxController {
  // Properties
  final isVideo = false.obs;

  // References
  String photoPath = "";
  String videoPath = "";

  // ^ Clear Current Photo ^ //
  clear() async {
    // Reset Properties
    isVideo(false);
    photoPath = "";
    videoPath = "";

    // Get Temp Directories
    Directory temp = await getTemporaryDirectory();
    var videoDir = Directory('${temp.path}/videos');
    var photoDir = Directory('${temp.path}/photos');

    // Clear Temp Photo Directory
    if (await photoDir.exists()) {
      await photoDir.delete(recursive: true);
    }

    // Clear Temp Video Directory
    if (await videoDir.exists()) {
      await videoDir.delete(recursive: true);
    }
    MediaScreenController.ready();
  }

  // ^ Video Completed Recording ^ //
  setVideo(String path) async {
    videoPath = path;
    isVideo(true);
  }

  // ^ Set Photo and Capture Ready ^ //
  setPhoto(String path) {
    photoPath = path;
    isVideo(false);
  }

  // ^ Continue with Media Capture ^ //
  continueMedia() async {
    if (isVideo.value) {
      // Save Video
      Get.find<DeviceService>().savePhotoFromCamera(videoPath);
      Get.find<SonrService>().setPayload(Payload.MEDIA, path: videoPath);

      // Go to Transfer
      Get.offNamed("/transfer");
    } else {
      // Save Photo
      Get.find<DeviceService>().savePhotoFromCamera(photoPath);
      Get.find<SonrService>().setPayload(Payload.MEDIA, path: photoPath);

      // Go to Transfer
      Get.offNamed("/transfer");
    }
  }
}