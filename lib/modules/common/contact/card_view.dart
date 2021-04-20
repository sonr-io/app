import 'dart:ui';
import 'package:sonr_app/data/database/cards_db.dart';
import 'package:sonr_app/service/device/cards.dart';
import 'package:sonr_app/theme/theme.dart';
import 'package:sonr_app/data/data.dart';
import 'contact.dart';

enum ContactOrientation { Portrait, Landscape }

// ^ TransferCard Contact Item Details ^ //
class ContactCardView extends StatelessWidget {
  final TransferCardItem card;
  final ContactOrientation orientation;
  ContactCardView(this.card, {Key key, this.orientation}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      decoration: Neumorph.floating(),
      child: Hero(
        tag: card.id,
        child: Container(
          height: 75,
          decoration: BoxDecoration(
              image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black26, BlendMode.luminosity),
            fit: BoxFit.cover,
            image: AssetController.randomCard.image,
          )),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Padding(padding: EdgeInsets.all(4)),
            // Build Profile Pic
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Container(
                decoration: Neumorph.indented(shape: BoxShape.circle),
                padding: EdgeInsets.all(10),
                child: card.contact.profilePicture,
              ),
            ),

            // Build Name
            card.contact.fullName,
            Divider(),
            Padding(padding: EdgeInsets.all(4)),

            // Quick Actions
            Container(
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ActionButton(
                  onPressed: () {},
                  label: "Mobile",
                  icon: SonrIcons.Call.gradientNamed(
                    name: FlutterGradientNames.highFlight,
                    size: 36,
                  ),
                  size: 72,
                ),
                Padding(padding: EdgeInsets.all(6)),
                ActionButton(
                  onPressed: () {},
                  label: "Text",
                  icon: SonrIcons.Mail.gradientNamed(name: FlutterGradientNames.teenParty, size: 36),
                  size: 72,
                ),
                Padding(padding: EdgeInsets.all(6)),
                ActionButton(
                  onPressed: () {},
                  label: "Video",
                  size: 72,
                  icon: SonrIcons.Video_Camera.gradientNamed(name: FlutterGradientNames.deepBlue, size: 36),
                ),
              ]),
            ),

            Divider(),
            Padding(padding: EdgeInsets.all(4)),

            // Brief Contact Card Info
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List<Widget>.generate(card.contact.socials.length, (index) {
                  return card.contact.socials[index].provider.gradient(size: 35);
                }))
          ]),
        ),
      ),
    );
  }
}
