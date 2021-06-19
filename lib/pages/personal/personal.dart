export 'views/add/add_social.dart';
export 'personal.dart';
export 'models/options.dart';
export 'models/status.dart';
export 'controllers/editor_controller.dart';
export 'controllers/personal_controller.dart';
export 'controllers/tile_controller.dart';

import 'package:sonr_app/modules/search/social_search.dart';
import 'package:sonr_app/pages/personal/widgets/tile_item.dart';
import 'package:sonr_app/style.dart';
import 'models/status.dart';
import 'views/editor/general/fields.dart';
import 'package:sonr_app/pages/personal/controllers/personal_controller.dart';

class PersonalView extends GetView<PersonalController> {
  PersonalView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: _DefaultProfileView(key: ValueKey<PersonalViewStatus>(PersonalViewStatus.Viewing)),
    );
  }
}

class _DefaultProfileView extends GetView<PersonalController> {
  _DefaultProfileView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      primary: true,
      slivers: [
        // @ Builds Profile Header
        SliverToBoxAdapter(child: Center(child: ProfileAvatarField())),
        SliverToBoxAdapter(child: _ProfileContactButtons()),
        SliverToBoxAdapter(child: _ProfileInfoView()),
        SliverPadding(padding: EdgeInsets.all(14)),

        // @ Builds List of Social Tile
        GetBuilder<PersonalController>(
            id: 'social-grid',
            builder: (_) {
              return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var socialsList = UserService.contact.value.socials.values.toList();
                      return SocialTileItem(socialsList[index], index);
                    },
                    childCount: UserService.contact.value.socials.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 12.0, crossAxisSpacing: 6.0));
            })
      ],
    );
  }
}

class _ProfileInfoView extends GetView<PersonalController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      width: Get.width,
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(top: 12)),
          Divider(color: SonrTheme.dividerColor, indent: 16, endIndent: 16),
          Padding(padding: EdgeInsets.only(top: 12)),

          // First/Last Name
          UserService.contact.value.fullName.subheading(color: SonrTheme.itemColor, fontSize: 32),

          // Username
          SNameField(),
          Padding(padding: EdgeInsets.all(12)),

          // Bio/ LastTweet
          _buildBio(),
        ],
      ),
    );
  }

  Widget _buildBio() {
    if (UserService.contact.value.hasBio()) {
      return '"${UserService.contact.value.bio}"'.paragraph();
    }
    return Container();
  }

  // ignore: unused_element
  Widget _buildLastTweet() {
    return ObxValue<RxBool>((isLinkingTwitter) {
      if (isLinkingTwitter.value) {
        return SocialUserSearchField.twitter(value: "");
      } else {
        return Container(
          width: Get.width,
          height: 72,
          child: UserService.contact.value.hasSocialMedia(Contact_Social_Media.Twitter)
              ? Text("Last Tweet")
              : GestureDetector(
                  onTap: () => isLinkingTwitter(true),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [SonrIcons.Twitter.gradient(size: 32), Padding(padding: EdgeInsets.all(8)), "Tap to Link Twitter".paragraph()],
                    ),
                  ),
                ),
        );
      }
    }, false.obs);
  }
}

class _ProfileContactButtons extends GetView<PersonalController> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 48),
        padding: EdgeInsets.only(top: 24),
        height: 86,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children: [
          ActionButton(
            onPressed: () {},
            iconData: SonrIcons.Call,
            label: "Call",
          ),
          ActionButton(
            onPressed: () {},
            iconData: SonrIcons.Message,
            label: "SMS",
          ),
          ActionButton(
            onPressed: () {},
            iconData: SonrIcons.Video,
            label: "Video",
          ),
          ActionButton(
            onPressed: () {},
            iconData: SonrIcons.ATSign,
            label: "Me",
          ),
        ]),
      ),
    );
  }
}