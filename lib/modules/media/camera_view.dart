import 'dart:async';
import 'dart:io';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/models/orientations.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonr_app/modules/media/picker_sheet.dart';
import 'package:sonr_app/theme/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'media_screen.dart';
import 'package:sonr_app/data/constants.dart';

class CameraView extends GetView<CameraController> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onDoubleTap: () {
            // Update Double Zoomed
            controller.doubleZoomed(!controller.doubleZoomed.value);

            // Set Zoom Level
            if (controller.doubleZoomed.value) {
              controller.zoomLevel(0.25);
            } else {
              controller.zoomLevel(0.0);
            }
          },
          onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
            // Calculate Scale
            var factor = 1.0 / scaleDetails.scale;
            var adjustedScale = 1 - factor;

            // Set Zoom Level
            if (scaleDetails.pointerCount > 1) {
              controller.zoomLevel(adjustedScale);
            }
          },
          onHorizontalDragUpdate: (details) {
            print("Drag Horizontal: ${details.delta}");
          },
          child: CameraAwesome(
            onPermissionsResult: (bool result) {},
            onCameraStarted: () {
              MediaController.ready();
            },
            onOrientationChanged: (CameraOrientations newOrientation) {},
            sensor: controller.sensor,
            zoom: controller.zoomNotifier,
            photoSize: controller.photoSize,
            switchFlashMode: controller.switchFlash,
            captureMode: controller.captureMode,
            brightness: controller.brightness,
          ),
        ),
        // Button Tools View
        _CameraToolsView(),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(left: 14, top: Get.statusBarHeight / 2),
          child: SonrButton.circle(
              intensity: 0.5,
              onPressed: () {
                Get.offNamed("/home");
              },
              icon: SonrIcon.close),
        ),
        Obx(() {
          if (controller.videoInProgress.value) {
            return Container(
              alignment: Alignment.topRight,
              padding: EdgeInsets.only(left: 14, top: Get.statusBarHeight / 2),
              child: Neumorphic(
                style: SonrStyle.timeStamp,
                child: SonrText.duration(controller.videoDuration.value),
                padding: EdgeInsets.all(10),
              ),
            );
          } else {
            return Container();
          }
        })
      ],
    );
  }
}

class _CameraToolsView extends GetView<CameraController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: NeumorphicBackground(
        backendColor: Colors.transparent,
        child: Neumorphic(
          padding: EdgeInsets.only(top: 20, bottom: 40),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            // Switch Camera
            Obx(() => GestureDetector(
                child: SonrIcon.neumorphic(controller.isFlipped.value ? Icons.camera_front_rounded : Icons.swap_vertical_circle_sharp,
                    size: 36, style: NeumorphicStyle(color: Colors.grey)),
                onTap: () async {
                  HapticFeedback.heavyImpact();
                  controller.toggleCameraSensor();
                })),

            // Neumorphic Camera Button Stack
            _CaptureButton(),

            // Media Gallery Picker
            GestureDetector(
                child: SonrIcon.neumorphic(Icons.perm_media, size: 36, style: NeumorphicStyle(color: Colors.grey)),
                onTap: () async {
                  HapticFeedback.heavyImpact();
                  // Check for Permssions
                  if (await Permission.photos.request().isGranted) {
                    // Display Bottom Sheet
                    Get.bottomSheet(PickerSheet(), isDismissible: true);
                  } else {
                    // Display Error
                    SonrSnack.error("Sonr isnt permitted to access your media.");
                  }
                }),
          ]),
        ),
      ),
    );
  }
}

class _CaptureButton extends GetView<CameraController> {
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(
        width: 150,
        height: 150,
        child: AspectRatio(
          aspectRatio: 1,
          child: Neumorphic(
            margin: EdgeInsets.all(14),
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.circle(),
            ),
            child: Neumorphic(
              style: NeumorphicStyle(
                depth: 14,
                boxShape: NeumorphicBoxShape.circle(),
              ),
              margin: EdgeInsets.all(10),
              child: Neumorphic(
                style: NeumorphicStyle(
                  depth: -8,
                  boxShape: NeumorphicBoxShape.circle(),
                ),
                margin: EdgeInsets.all(14),
                child: GestureDetector(
                  onTap: () {
                    controller.capturePhoto();
                  },
                  onLongPressStart: (LongPressStartDetails tapUpDetails) {
                    if (GetPlatform.isIOS) {
                      controller.startCaptureVideo();
                    }
                  },
                  onLongPressEnd: (LongPressEndDetails tapUpDetails) {
                    if (GetPlatform.isIOS) {
                      controller.stopCaptureVideo();
                    }
                  },
                  child: Obx(
                    () => Neumorphic(
                        style: NeumorphicStyle(
                            color: SonrColor.base,
                            depth: 14,
                            intensity: 0.85,
                            boxShape: NeumorphicBoxShape.circle(),
                            border: controller.videoInProgress.value
                                ? NeumorphicBorder(color: Colors.redAccent, width: 4)
                                : NeumorphicBorder(color: Colors.black, width: 2))),
                  ),
                ),
                // Interior Compass
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ** Camera View Controller ** //
class CameraController extends GetxController {
  // Properties
  final doubleZoomed = false.obs;
  final isFlipped = false.obs;
  final videoDuration = 0.obs;
  final videoInProgress = false.obs;
  final zoomLevel = 0.0.obs;

  // Notifiers
  ValueNotifier<double> brightness = ValueNotifier(1);
  ValueNotifier<CaptureModes> captureMode = ValueNotifier(CaptureModes.PHOTO);
  ValueNotifier<Size> photoSize = ValueNotifier(Size(Get.width, Get.height));
  ValueNotifier<Sensors> sensor = ValueNotifier(Sensors.BACK);
  ValueNotifier<CameraFlashes> switchFlash = ValueNotifier(CameraFlashes.NONE);
  ValueNotifier<double> zoomNotifier = ValueNotifier(0);

  // Controllers
  PictureController pictureController = new PictureController();
  VideoController videoController = new VideoController();

  // Video Duration Handling
  Stopwatch _stopwatch = new Stopwatch();
  Timer _timer;

  // ** Constructer ** //
  CameraController() {
    zoomLevel.listen((value) {
      zoomNotifier.value = 1.0 / value;
    });
  }

  // ^ Captures Photo ^ //
  capturePhoto() async {
    // Set Path
    var temp = await getTemporaryDirectory();
    var photoDir = await Directory('${temp.path}/photos').create(recursive: true);
    var path = '${photoDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Capture Photo
    await pictureController.takePicture(path);
    MediaController.setPhoto(path);
  }

  // ^ Captures Video ^ //
  startCaptureVideo() async {
    // Set Path
    var temp = await getTemporaryDirectory();
    var videoDir = await Directory('${temp.path}/videos').create(recursive: true);
    var path = '${videoDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
    MediaController.recording(path);

    // Capture Photo
    captureMode.value = CaptureModes.VIDEO;
    await videoController.recordVideo(path);
    videoInProgress(true);

    _stopwatch.start();
    _timer = new Timer.periodic(new Duration(milliseconds: 50), (timer) {
      videoDuration(_stopwatch.elapsedMilliseconds);
    });
  }

  // ^ Stops Video Capture ^ //
  stopCaptureVideo() async {
    // Save Video
    await videoController.stopRecordingVideo();
    var duration = videoDuration.value;

    // Reset Duration Management
    _stopwatch.reset();
    _timer.cancel();
    videoDuration(0);
    videoInProgress(false);

    // Update State
    captureMode.value = CaptureModes.PHOTO;
    MediaController.completeVideo(duration);
  }

  // ^ Flip Camera ^ //
  toggleCameraSensor() async {
    // Toggle
    isFlipped(!isFlipped.value);

    if (isFlipped.value) {
      sensor.value = Sensors.FRONT;
    } else {
      sensor.value = Sensors.BACK;
    }
  }
}
