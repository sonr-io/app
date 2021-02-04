import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_dropdown/flutter_dropdown.dart';
import 'package:get/get.dart';
import 'package:sonar_app/service/sonr_service.dart';
import 'package:sonar_app/theme/theme.dart';
import 'package:sonr_core/models/models.dart';
import 'package:flutter/material.dart';
import 'package:media_gallery/media_gallery.dart';
import 'home_controller.dart';

// ** MediaPicker Dialog View ** //
class MediaPicker extends GetView<MediaPickerController> {
  @override
  Widget build(BuildContext context) {
    return NeumorphicBackground(
      borderRadius: BorderRadius.circular(40),
      backendColor: Colors.transparent,
      child: Neumorphic(
          style: NeumorphicStyle(color: K_BASE_COLOR),
          child: Column(children: [
            // Header Buttons
            _MediaDropdownDialogBar(
                onCancel: () => Get.back(),
                onAccept: () => controller.confirmSelectedFile()),
            Obx(() {
              if (controller.loaded.value) {
                return _MediaGrid();
              } else {
                return NeumorphicProgressIndeterminate();
              }
            }),
          ])),
    );
  }
}

// ** Create Media Album Dropdown Bar ** //
class _MediaDropdownDialogBar extends GetView<MediaPickerController> {
  // Properties
  final Function onCancel;
  final Function onAccept;

  // Constructer
  const _MediaDropdownDialogBar(
      {Key key, @required this.onCancel, @required this.onAccept})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight + 16 * 2,
      child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // @ Top Left Close/Cancel Button
            SonrButton.close(onCancel),

            // @ Drop Down
            Neumorphic(
                style: NeumorphicStyle(
                  depth: 8,
                  shape: NeumorphicShape.flat,
                  color: K_BASE_COLOR,
                ),
                margin: EdgeInsets.only(left: 14, right: 14),
                child: Container(
                    width: Get.width - 250,
                    margin: EdgeInsets.only(left: 12, right: 12),

                    // @ ValueBuilder for DropDown
                    child: ValueBuilder<MediaCollection>(
                      onUpdate: (value) {
                        controller.updateMediaCollection(value);
                      },
                      builder: (item, updateFn) {
                        return DropDown<MediaCollection>(
                          showUnderline: false,
                          isExpanded: true,
                          initialValue: controller.mediaCollection.value,
                          items: controller.allCollections.value,
                          customWidgets: List<Widget>.generate(
                              controller.allCollections.value.length,
                              (index) => _buildOptionWidget(index)),
                          onChanged: updateFn,
                        );
                      },
                    ))),

            // @ Top Right Confirm Button
            SonrButton.accept(onAccept)
          ]),
    );
  }

  // @ Builds option at index
  _buildOptionWidget(int index) {
    var item = controller.allCollections.value.elementAt(index);
    return Row(children: [
      Padding(padding: EdgeInsets.all(4)),
      SonrText.normal(
        item.name,
        color: Colors.black,
      )
    ]);
  }
}

// ** Create Media Grid ** //
class _MediaGrid extends GetView<MediaPickerController> {
  _MediaGrid();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        width: 330,
        height: 368,
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: controller.allMedias.length,
            itemBuilder: (context, index) {
              return _MediaPickerItem(controller.allMedias[index]);
            }),
      );
    });
  }
}

// ** MediaPicker Item Widget ** //
class _MediaPickerItem extends StatefulWidget {
  final Media mediaFile;
  _MediaPickerItem(this.mediaFile);

  @override
  _MediaPickerItemState createState() => _MediaPickerItemState();
}

// ** MediaPicker Item Widget State ** //
class _MediaPickerItemState extends State<_MediaPickerItem> {
  // Pressed Property
  bool isPressed = false;
  StreamSubscription<Media> selectedStream;

  // Listen to Selected File
  @override
  void initState() {
    selectedStream =
        Get.find<MediaPickerController>().selectedFile.listen((val) {
      if (widget.mediaFile == val) {
        if (!isPressed) {
          if (mounted) {
            setState(() {
              isPressed = true;
            });
          }
        }
      } else {
        if (isPressed) {
          if (mounted) {
            setState(() {
              isPressed = false;
            });
          }
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    selectedStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize Styles
    final defaultStyle = NeumorphicStyle(color: K_BASE_COLOR);
    final pressedStyle = NeumorphicStyle(
        color: K_BASE_COLOR,
        disableDepth: true,
        intensity: 0,
        border: NeumorphicBorder(
            isEnabled: true, width: 4, color: Colors.greenAccent));

    // Build Button
    return NeumorphicButton(
      style: isPressed ? pressedStyle : defaultStyle,
      onPressed: () {
        Get.find<MediaPickerController>().selectedFile(widget.mediaFile);
      },
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          FutureBuilder(
              future: widget.mediaFile.getThumbnail(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(
                    Uint8List.fromList(snapshot.data),
                    fit: BoxFit.cover,
                  );
                } else if (snapshot.hasError) {
                  return Icon(Icons.error, color: Colors.red, size: 24);
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          widget.mediaFile.mediaType == MediaType.video
              ? SonrIcon.video
              : const SizedBox()
        ],
      ),
    );
  }
}

// ** MediaPicker GetXController ** //
class MediaPickerController extends GetxController {
  final allCollections = Rx<List<MediaCollection>>();
  final mediaCollection = Rx<MediaCollection>();
  final allMedias = <Media>[].obs;
  final selectedFile = Rx<Media>();
  final hasGallery = false.obs;
  final loaded = false.obs;

  @override
  onInit() async {
    fetch();
    super.onInit();
  }

  // ^ Retreive Albums ^ //
  fetch() async {
    // Get Collections
    List<MediaCollection> collections = await MediaGallery.listMediaCollections(
      mediaTypes: [MediaType.image, MediaType.video],
    );

    allCollections(collections);

    // List Collections
    collections.forEach((element) {
      // Set Has Gallery
      if (element.count > 0) {
        hasGallery(true);
      }

      // Check for Master Collection
      if (element.isAllCollection) {
        // Assign Values
        mediaCollection(element);
      }
    });

    if (mediaCollection.value.count > 0) {
      // Get Images
      final MediaPage imagePage = await mediaCollection.value.getMedias(
        mediaType: MediaType.image,
        take: 500,
      );

      // Get Videos
      final MediaPage videoPage = await mediaCollection.value.getMedias(
        mediaType: MediaType.video,
        take: 500,
      );

      // Combine Media
      final List<Media> combined = [
        ...imagePage.items,
        ...videoPage.items,
      ]..sort((x, y) => y.creationDate.compareTo(x.creationDate));

      // Set All Media
      allMedias.assignAll(combined);
    }
    loaded(true);
  }

  // ^ Method Updates the Current Media Collection ^ //
  updateMediaCollection(MediaCollection collection) async {
    // Reset Loaded
    loaded(false);
    mediaCollection(collection);

    // Get Images
    final MediaPage imagePage = await mediaCollection.value.getMedias(
      mediaType: MediaType.image,
      take: 500,
    );

    // Get Videos
    final MediaPage videoPage = await mediaCollection.value.getMedias(
      mediaType: MediaType.video,
      take: 500,
    );

    // Combine Media
    final List<Media> combined = [
      ...imagePage.items,
      ...videoPage.items,
    ]..sort((x, y) => y.creationDate.compareTo(x.creationDate));

    // Set All Media
    allMedias.assignAll(combined);
    loaded(true);
  }

  // ^ Process Selected File ^ //
  confirmSelectedFile() async {
    // Retreive File and Process
    File mediaFile = await selectedFile.value.getFile();
    Get.find<SonrService>().process(Payload.FILE, file: mediaFile);

    // Close Share Button
    Get.find<HomeController>().toggleShareExpand();

    // Go to Transfer
    Get.offNamed("/transfer");
  }
}