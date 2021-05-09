import 'dart:io';
import 'package:get/get.dart';
import 'package:sonr_app/style/style.dart';

/// @ Widget for Details Media View
class MetaDetailsView extends StatelessWidget {
  final SonrFile_Metadata card;
  final File? mediaFile;
  const MetaDetailsView(this.card, this.mediaFile);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: Get.back,
      child: SizedBox(
        width: Get.width,
        child: GestureDetector(
          onTap: () {
            Get.back(closeOverlays: true);
          },
          child: Hero(
            tag: card.path,
            child: Material(
              color: Colors.transparent,
              child: InteractiveViewer(child: Image.file(mediaFile!)),
            ),
          ),
        ),
      ),
    );
  }
}