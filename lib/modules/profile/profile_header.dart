import 'package:sonr_app/modules/profile/profile_controller.dart';
import 'package:sonr_app/theme/theme.dart';

import 'create_tile.dart';
import 'edit_dialog.dart';

class ProfileHeaderBar extends StatelessWidget {
  // Sliver Attributes
  final bool automaticallyImplyLeading;
  final double expandedHeight;

  const ProfileHeaderBar({Key key, this.automaticallyImplyLeading, this.expandedHeight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.transparent,
      flexibleSpace: ProfileHeaderView(),
      expandedHeight: Get.height / 5,
      title: Container(
          alignment: Alignment.topCenter,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(
              padding: EdgeInsets.only(top: 0, bottom: 16, right: 8, left: 8),
              icon: SonrIcon.gradient(Icons.add, FlutterGradientNames.morpheusDen),
              onPressed: () => Get.dialog(CreateTileStepper()),
            ),
            IconButton(
              padding: EdgeInsets.only(top: 0, bottom: 16, right: 8, left: 8),
              icon: SonrIcon.more,
              onPressed: () => {},
            ),
          ])),
    );
  }
}

class ProfileHeaderView extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      //titlePadding: EdgeInsets.only(bottom: 24),
      centerTitle: true,
      background: GestureDetector(
        onLongPress: () async {
          print("Launch Color picker to change header");
          HapticFeedback.heavyImpact();
        },
        child: Container(
          height: Get.height / 5, // Same Header Color
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // @ Avatar
              _AvatarField(),
              GestureDetector(
                  onLongPress: () async => SonrOverlay.edit(
                        EditType.NameField,
                        EditDialog.nameField(),
                      ),
                  child: Obx(() =>
                      SonrText.medium(UserService.firstName.value + " " + UserService.lastName.value, color: SonrColor.fromHex("FFFDFA"), size: 24))),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarField extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        HapticFeedback.heavyImpact();
        Get.to(CameraView.withPreview(onMediaSelected: (file) async {
          UserService.setPicture(await file.toUint8List());
        }), transition: Transition.downToUp);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Neumorphic(
          padding: EdgeInsets.all(10),
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.circle(),
            depth: -10,
          ),
          child: Obx(() => UserService.contact.value.profilePicture),
        ),
      ),
    );
  }
}