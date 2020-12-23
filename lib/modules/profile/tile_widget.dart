import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:sonar_app/modules/profile/social_view.dart';
import 'package:sonar_app/modules/profile/tile_controller.dart';
import 'package:sonar_app/theme/theme.dart';
import 'package:sonr_core/sonr_core.dart';
import 'tile_dialog.dart';

// ** Builds Social Tile ** //
class SocialTile extends GetView<TileController> {
  final Contact_SocialTile data;
  SocialTile(this.data) {}
  @override
  Widget build(BuildContext context) {
    // Initialize
    controller.setTile(data);

    return Obx(() {
      // @ Determine State
      bool isViewing = (controller.state.value != TileState.Editing);

      // @ Build View
      return GestureDetector(
          onLongPress: () async {
            print("Long tapped jiggle");
          },
          child: Neumorphic(
              style: isViewing
                  ? NeumorphicStyle(intensity: 0.85)
                  : NeumorphicStyle(
                      intensity: 0.85, shape: NeumorphicShape.flat, depth: 15),
              margin: EdgeInsets.all(4),
              child: Container(
                child: SocialView.fromTile(data),
              )));
    });
  }

}

// ** Builds Edit Tile ** //
class EditTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create View
    return NeumorphicButton(
      style: NeumorphicStyle(intensity: 0.85),
      child: SonrIcon.gradient(Icons.add, FlutterGradientNames.morpheusDen),
      onPressed: () {
        Get.dialog(TileDialog(), barrierColor: K_DIALOG_COLOR);
      },
    );
  }
}
