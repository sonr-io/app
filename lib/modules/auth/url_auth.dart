import 'package:sonr_app/modules/card/url/link_view.dart';
import 'package:sonr_app/modules/peer/profile_view.dart';
import 'package:sonr_app/style/style.dart';
import 'package:sonr_plugin/sonr_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

/// @ URL Invite from AuthInvite Proftobuf
class URLAuthView extends StatelessWidget {
  final AuthInvite invite;
  URLAuthView(this.invite);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Neumorphic.floating(
        theme: Get.theme,
      ),
      child: Column(mainAxisSize: MainAxisSize.max, children: [
        // @ Header
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Build Profile Pic
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 8, right: 8),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: Neumorphic.floating(theme: Get.theme, shape: BoxShape.circle),
              child: invite.from.profile.hasPicture()
                  ? Image.memory(Uint8List.fromList(invite.from.profile.picture))
                  : Icon(
                      Icons.insert_emoticon,
                      size: 60,
                      color: SonrColor.Black.withOpacity(0.5),
                    ),
            ),
          ),

          // From Information
          Column(mainAxisSize: MainAxisSize.min, children: [
            ProfileName(profile: invite.from.profile, isHeader: true),
            Center(child: "Website Link".gradient(value: SonrGradients.PlumBath, size: 22)),
          ]),
        ]),
        Divider(),

        // @ URL Information
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Container(child: URLLinkView(data: invite.url))),
          ],
        ),

        // @ Actions
        Divider(),
        Padding(padding: EdgeInsets.all(4)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorButton.neutral(onPressed: () => SonrOverlay.back(), text: "Dismiss"),
            Padding(padding: EdgeInsets.all(8)),
            ColorButton.primary(
              onPressed: () => _launchURL(),
              text: "Open",
              icon: SonrIcons.Discover,
            ),
          ],
        ),
        Padding(padding: EdgeInsets.only(top: 14))
      ]),
    );
  }

  Future<void> _launchURL() async {
    if (await canLaunch(invite.url.url)) {
      await launch(invite.url.url);
    } else {
      SonrSnack.error("Could not launch the URL.");
    }
  }
}
