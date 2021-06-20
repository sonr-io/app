import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sonr_app/modules/share/views/external_sheet.dart';
import 'package:sonr_app/style.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonr_app/data/services/services.dart';

// @ Enum defines Type of Permission
class MobileService extends GetxService {
  // Accessors
  static bool get isRegistered => Get.isRegistered<MobileService>();
  static MobileService get to => Get.find<MobileService>();

  // Permissions
  final _hasCamera = false.obs;
  final _hasLocation = false.obs;
  final _hasLocalNetwork = false.obs;
  final _hasMicrophone = false.obs;
  final _hasNotifications = false.obs;
  final _hasPhotos = false.obs;
  final _hasStorage = false.obs;

  // Mobile Platform Controllers/Properties
  final _audioPlayer = AudioCache(prefix: 'assets/sounds/', respectSilence: true);
  final _position = RxPosition();
  final _incomingMedia = <SharedMediaFile>[].obs;
  final _incomingText = "".obs;

  // Getters for Device/Location References
  static RxPosition get position => to._position;
  static RxBool get hasCamera => to._hasCamera;
  static RxBool get hasLocation => to._hasLocation;
  static RxBool get hasLocalNetwork => to._hasLocalNetwork;
  static RxBool get hasMicrophone => to._hasMicrophone;
  static RxBool get hasNotifications => to._hasNotifications;
  static RxBool get hasPhotos => to._hasPhotos;
  static RxBool get hasStorage => to._hasStorage;

  static RxBool get hasGallery {
    if (DeviceService.isIOS) {
      return to._hasPhotos;
    } else {
      return to._hasStorage;
    }
  }

  // References
  late StreamSubscription _externalMediaStream;
  late StreamSubscription _externalTextStream;

  // References

  MobileService() {
    Timer.periodic(250.milliseconds, (timer) {
      if (AppServices.areServicesRegistered && isRegistered && NodeService.isRegistered) {
        NodeService.update(position.value);
      }
    });
  }

  // * Device Service Initialization * //
  Future<MobileService> init() async {
    // @ Bind Sensors for Mobile


    // Audio Player
    await _audioPlayer.loadAll(List<String>.generate(UISoundType.values.length, (index) => UISoundType.values[index].file));

    // Update Device Values
    await updatePermissionsStatus();

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile>? data) {
      if (data != null) {
        _incomingMedia(data);
        _incomingMedia.refresh();
      }
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? text) {
      if (text != null) {
        _incomingText(text);
        _incomingText.refresh();
      }
    });

    // Listen to Incoming Text/File
    _externalTextStream = ReceiveSharingIntent.getTextStream().listen(_handleSharedText);
    _externalMediaStream = ReceiveSharingIntent.getMediaStream().listen(_handleSharedFiles);
    return this;
  }

  // * Close Streams * //
  @override
  void onClose() {
    _position.cancel();
    _externalMediaStream.cancel();
    _externalTextStream.cancel();
    super.onClose();
  }

  /// @ Checks for Initial Media/Text to Share
  static checkInitialShare() async {
    if (DeviceService.isMobile && isRegistered) {
      // @ Check for Media
      if (to._incomingMedia.length > 0 && !Get.isBottomSheetOpen!) {
        // Open Sheet
        await Get.bottomSheet(ShareSheet.media(to._incomingMedia), isDismissible: false);

        // Reset Incoming
        to._incomingMedia.clear();
        to._incomingMedia.refresh();
      }

      // @ Check for Text
      if (to._incomingText.value != "" && GetUtils.isURL(to._incomingText.value) && !Get.isBottomSheetOpen!) {
        var data = await NodeService.getURL(to._incomingText.value);
        // Open Sheet
        await Get.bottomSheet(ShareSheet.url(data), isDismissible: false);

        // Reset Incoming
        to._incomingText("");
        to._incomingText.refresh();
      }
    }
  }

  /// @ Method Plays a UI Sound
  static void playSound(UISoundType type) async {
    if (DeviceService.isMobile && isRegistered) {
      // await to._audioPlayer.play(type.file);
    }
  }

  /// @ Saves Photo to Gallery
  static Future<bool> saveCapture(String path, bool isVideo) async {
    if (DeviceService.isMobile && isRegistered) {
      // Validate Path
      var file = File(path);
      var exists = await file.exists();
      if (!exists) {
        AppRoute.snack(SnackArgs.error("Unable to save Captured Media to your Gallery"));
        return false;
      } else {
        if (isVideo) {
          // Set Video File
          File videoFile = File(path);
          var asset = await (PhotoManager.editor.saveVideo(videoFile) as FutureOr<AssetEntity>);
          var result = await asset.exists;

          // Visualize Result
          if (result) {
            AppRoute.snack(SnackArgs.error("Unable to save Captured Photo to your Gallery"));
          }
          return result;
        } else {
          // Save Image to Gallery
          var asset = await (PhotoManager.editor.saveImageWithPath(path) as FutureOr<AssetEntity>);
          var result = await asset.exists;
          if (!result) {
            AppRoute.snack(SnackArgs.error("Unable to save Captured Video to your Gallery"));
          }
          return result;
        }
      }
    }
    return false;
  }

  /// @ Saves Received Media to Gallery
  static Future<SaveTransferEntry> saveTransfer(SonrFile_Item meta) async {
    if (DeviceService.isMobile && isRegistered) {
      // Initialize
      AssetEntity? asset;

      // Get Data from Media
      if (meta.mime.isImage && MobileService.hasGallery.value) {
        asset = await PhotoManager.editor.saveImageWithPath(meta.path);

        // Visualize Result
        if (asset != null) {
          return await SaveTransferEntry.fromAssetEntity(meta, asset);
        }
      }

      // Save Video to Gallery
      else if (meta.mime.isVideo && MobileService.hasGallery.value) {
        // Set Video File
        asset = await PhotoManager.editor.saveVideo(meta.file);

        // Visualize Result
        if (asset != null) {
          return await SaveTransferEntry.fromAssetEntity(meta, asset);
        }
      }
    }
    // Return Status
    return SaveTransferEntry.fail();
  }

  /// @ Update Method
  Future<void> updatePermissionsStatus() async {
    _hasCamera(await Permission.camera.isGranted);
    _hasLocation(await Permission.location.isGranted);
    _hasMicrophone(await Permission.microphone.isGranted);
    _hasNotifications(await Permission.notification.isGranted);
    _hasPhotos(await Permission.photos.isGranted);
    _hasStorage(await Permission.storage.isGranted);
  }

  /// @ Request Camera optional overlay
  Future<bool> requestCamera() async {
    if (DeviceService.isMobile) {
      // Present Overlay
      if (await AppRoute.question(
          title: 'Requires Permission',
          description: 'Sonr Needs to Access your Camera in Order to send Pictures through the app.',
          acceptTitle: "Allow",
          declineTitle: "Decline")) {
        if (await Permission.camera.request().isGranted) {
          updatePermissionsStatus();
          return true;
        } else {
          updatePermissionsStatus();
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  /// @ Request Gallery optional overlay
  Future<bool> requestGallery({String description = 'Sonr needs your Permission to access your phones Gallery.'}) async {
    if (DeviceService.isMobile) {
      // Present Overlay
      if (await AppRoute.question(title: 'Photos', description: description, acceptTitle: "Allow", declineTitle: "Decline")) {
        if (DeviceService.isAndroid) {
          if (await Permission.storage.request().isGranted) {
            updatePermissionsStatus();
            return true;
          } else {
            updatePermissionsStatus();
            return false;
          }
        } else {
          if (await Permission.photos.request().isGranted) {
            updatePermissionsStatus();
            return true;
          } else {
            updatePermissionsStatus();
            return false;
          }
        }
      } else {
        updatePermissionsStatus();
        return false;
      }
    } else {
      updatePermissionsStatus();
      return false;
    }
  }

  /// @ Request Location optional overlay
  Future<bool> requestLocation() async {
    if (DeviceService.isMobile) {
      // Present Overlay
      if (await AppRoute.question(
          title: 'Location',
          description: 'Sonr requires location in order to find devices in your area.',
          acceptTitle: "Allow",
          declineTitle: "Decline")) {
        if (await Permission.location.request().isGranted) {
          updatePermissionsStatus();
          return true;
        } else {
          updatePermissionsStatus();
          return false;
        }
      } else {
        updatePermissionsStatus();
        return false;
      }
    } else {
      updatePermissionsStatus();
      return false;
    }
  }

  /// @ Request Microphone optional overlay
  Future<bool> requestMicrophone() async {
    if (DeviceService.isMobile) {
      // Present Overlay
      if (await AppRoute.question(
          title: 'Microphone',
          description: 'Sonr uses your microphone in order to communicate with other devices.',
          acceptTitle: "Allow",
          declineTitle: "Decline")) {
        if (await Permission.microphone.request().isGranted) {
          updatePermissionsStatus();
          return true;
        } else {
          updatePermissionsStatus();
          return false;
        }
      } else {
        updatePermissionsStatus();
        return false;
      }
    } else {
      updatePermissionsStatus();
      return false;
    }
  }

  /// @ Request Notifications optional overlay
  Future<bool> requestNotifications() async {
    // Present Overlay
    if (DeviceService.isMobile) {
      if (await AppRoute.question(
          title: 'Requires Permission',
          description: 'Sonr would like to send you Notifications for Transfer Invites.',
          acceptTitle: "Allow",
          declineTitle: "Decline")) {
        if (await Permission.notification.request().isGranted) {
          updatePermissionsStatus();
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  /// @ Trigger iOS Local Network with Alert
  Future triggerNetwork() async {
    if (!_hasLocalNetwork.value && DeviceService.isIOS) {
      await AppRoute.alert(
          title: 'Requires Permission',
          description: 'Sonr requires local network permissions in order to maximize transfer speed.',
          buttonText: "Grant",
          dismissible: false);

      NodeService.to.node.requestLocalNetwork();
      updatePermissionsStatus();
    }
    return true;
  }

  // # Saves Received Media to Gallery
  _handleSharedFiles(List<SharedMediaFile> data) async {
    if (!Get.isBottomSheetOpen!) {
      await Get.bottomSheet(ShareSheet.media(data), isDismissible: false);
    }
  }

  // # Saves Received Media to Gallery
  _handleSharedText(String text) async {
    if (!Get.isBottomSheetOpen! && GetUtils.isURL(text)) {
      // Get Data
      var data = await NodeService.getURL(text);

      // Open Sheet
      await Get.bottomSheet(ShareSheet.url(data), isDismissible: false);
    }
  }
}