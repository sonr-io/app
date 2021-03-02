import 'dart:io';
import 'package:get/get.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:sonr_app/core/core.dart';
import '../theme/theme.dart';
import 'package:sonr_core/sonr_core.dart';

const double S_CONTENT_HEIGHT_MODIFIER = 110;
const double E_CONTENT_WIDTH_MODIFIER = 20;

// ^ Share from External App BottomSheet View ^ //
class ShareSheet extends StatelessWidget {
  // Properties
  final Widget child;
  final Size size;
  final Payload payloadType;
  const ShareSheet({Key key, @required this.child, @required this.size, @required this.payloadType}) : super(key: key);

  // @ Bottom Sheet for Media
  factory ShareSheet.media(List<SharedMediaFile> sharedFiles) {
    // Get Sizing
    final Size window = Size(Get.width - 20, Get.height / 3 + 150);
    final Size content = Size(window.width - E_CONTENT_WIDTH_MODIFIER, window.height - S_CONTENT_HEIGHT_MODIFIER);

    // Build View
    return ShareSheet(child: _ShareItemMedia(sharedFiles: sharedFiles, size: content), size: window, payloadType: Payload.MEDIA);
  }

  // @ Bottom Sheet for URL
  factory ShareSheet.url(String value) {
    // Get Sizing
    final Size window = Size(Get.width - 20, Get.height / 5 + 40);
    final Size content = Size(window.width - E_CONTENT_WIDTH_MODIFIER, window.height - S_CONTENT_HEIGHT_MODIFIER);

    // Build View
    return ShareSheet(child: _ShareItemURL(urlText: value, size: content), size: window, payloadType: Payload.URL);
  }
  @override
  Widget build(BuildContext context) {
    return NeumorphicBackground(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        backendColor: Colors.transparent,
        child: Neumorphic(
            style: NeumorphicStyle(color: SonrColor.base),
            child: Container(
                width: size.width,
                height: size.height,
                padding: EdgeInsets.only(top: 6),
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  // @ Top Banner
                  Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    // Bottom Left Close/Cancel Button
                    SonrButton.circle(onPressed: () => Get.back(), icon: SonrIcon.close),

                    SonrText.header("Share", size: 40),

                    // @ Top Right Confirm Button
                    SonrButton.circle(onPressed: () => Get.offNamed("/transfer"), icon: SonrIcon.accept),
                  ]),

                  // @ Window Content
                  Spacer(),
                  Container(
                    width: size.width,
                    height: size.height,
                    child: Neumorphic(
                        margin: EdgeInsets.only(top: 4, bottom: 4, left: 8),
                        style: NeumorphicStyle(
                          color: SonrColor.base,
                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(10)),
                        ),
                        child: child),
                  ),
                  Spacer()
                ]))));
  }
}

// ^ Share Item Media View ^ //
class _ShareItemMedia extends StatelessWidget {
  final List<SharedMediaFile> sharedFiles;
  final Size size;

  const _ShareItemMedia({Key key, this.sharedFiles, this.size}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Get Shared File
    SharedMediaFile sharedIntent = sharedFiles.length > 1 ? sharedFiles.last : sharedFiles.first;
    SonrService.queueMedia(MediaFile.externalShare(sharedIntent));

    return Neumorphic(
        style: NeumorphicStyle(
          depth: -8,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        ),
        margin: EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: FittedBox(
              fit: BoxFit.fitWidth,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 1,
                  minHeight: 1,
                  maxHeight: size.height - 20,
                ),
                child: Image.file(File(sharedIntent.path)),
              )),
        ));
  }
}

// ^ Share Item URL View ^ //
class _ShareItemURL extends StatelessWidget {
  final String urlText;
  final Size size;
  const _ShareItemURL({Key key, this.urlText, this.size}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SonrService.queueUrl(urlText);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // @ Sonr Icon
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SonrIcon.url,
        ),

        // @ Indent View
        Expanded(
          child: Neumorphic(
              style: NeumorphicStyle(
                depth: -8,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
              ),
              margin: EdgeInsets.all(10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SonrText.url(urlText),
              )),
        ),
      ],
    );
  }
}