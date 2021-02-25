import 'dart:typed_data';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:sonr_app/theme/theme.dart';
import 'package:sonr_app/widgets/overlay.dart';
import 'package:sonr_core/sonr_core.dart';
import 'package:sonr_app/data/constants.dart';
import 'card_controller.dart';

class ContactCard extends GetWidget<TransferCardController> {
  // References
  final CardType type;
  final AuthInvite invite;
  final AuthReply reply;
  final TransferCard card;

  // ** Factory -> Invite Dialog View ** //
  factory ContactCard.invite(AuthInvite invite) {
    return ContactCard(CardType.Invite, invite: invite, card: invite.card);
  }

  // ** Factory -> Invite Dialog View ** //
  factory ContactCard.reply(AuthReply reply) {
    return ContactCard(CardType.Reply, reply: reply, card: reply.card);
  }

  // ** Factory -> Grid Item View ** //
  factory ContactCard.item(TransferCard card) {
    return ContactCard(CardType.GridItem, card: card);
  }

  // ** Constructer ** //
  const ContactCard(this.type, {Key key, this.invite, this.reply, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case CardType.Invite:
        return _ContactInviteView(card, controller, false);
        break;
      case CardType.Reply:
        return _ContactInviteView(card, controller, true);
        break;
      case CardType.GridItem:
        return Neumorphic(
          style: SonrStyle.normal,
          margin: EdgeInsets.all(4),
          child: GestureDetector(
            onTap: () {
              // Push to Page
              Get.to(_ContactCardExpanded(card), transition: Transition.fadeIn);
            },
            child: Hero(
              tag: card.id,
              child: Container(
                height: 75,
                decoration: card.payload == Payload.MEDIA && card.metadata.mime.type == MIME_Type.image
                    ? BoxDecoration(
                        image: DecorationImage(
                        colorFilter: ColorFilter.mode(Colors.black26, BlendMode.luminosity),
                        fit: BoxFit.cover,
                        image: MemoryImage(card.metadata.thumbnail),
                      ))
                    : null,
                child: _ContactItemView(card),
              ),
            ),
          ),
        );
        break;
      default:
        return Container();
        break;
    }
  }
}

// ^ Contact Invite from AuthInvite Proftobuf ^ //
class _ContactInviteView extends StatelessWidget {
  final TransferCardController controller;
  final TransferCard card;
  final bool isReply;
  _ContactInviteView(this.card, this.controller, this.isReply);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(6),
      child: Column(children: [
        Row(children: [
          // @ Photo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 8),
              child: Neumorphic(
                padding: EdgeInsets.all(4),
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: -10,
                ),
                child: card.contact.profilePicture,
              ),
            ),
          ),
          VerticalDivider(),
          Padding(padding: EdgeInsets.all(4)),
          // @ Content
          Container(
            margin: EdgeInsets.only(right: 8),
            child: Column(children: [
              // Name
              card.contact.headerName,

              // Phone/ Website
              Row(children: [
                card.platform.icon(IconType.Neumorphic, color: Colors.grey[700], size: 20),
                // Hide PhoneNumber
                Padding(padding: EdgeInsets.all(10)),
                card.contact.phoneNumber,
                card.contact.webSite,
              ]),
            ]),
          ),
        ]),
        // Social Media
        Container(
          margin: EdgeInsets.only(top: 8, left: 40, right: 40, bottom: 8),
          child: Row(
              children: List.generate(card.contact.socials.length, (index) {
            return card.contact.socials[index].provider.icon(IconType.Gradient, size: 32);
          })),
        ),
        Divider(),
        Padding(padding: EdgeInsets.all(4)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children: [
          // Decline Button
          TextButton(
              onPressed: () => SonrOverlay.back(),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SonrText.medium("Decline", color: Colors.redAccent, size: 18),
              )),
          // Accept Button
          Container(
            width: Get.width / 2.75,
            child: SonrButton.stadium(
              onPressed: () {
                SonrOverlay.back();
                if (!isReply) {
                  controller.promptSendBack(card);
                } else {
                  controller.acceptContact(card, sendBackContact: false);
                }
              },
              icon: SonrIcon.accept,
              text: SonrText.medium("Accept", size: 18, color: Colors.black.withOpacity(0.85)),
            ),
          ),
        ])
      ]),
    );
  }
}

// ^ TransferCard Contact Item Details ^ //
class _ContactItemView extends StatelessWidget {
  final TransferCard card;

  _ContactItemView(this.card);
  @override
  Widget build(BuildContext context) {
    Contact contact = card.contact;
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Padding(padding: EdgeInsets.all(4)),
      // Build Profile Pic
      Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Neumorphic(
          padding: EdgeInsets.all(10),
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.circle(),
            depth: -10,
          ),
          child: contact.hasPicture()
              ? Image.memory(Uint8List.fromList(contact.picture))
              : Icon(
                  Icons.insert_emoticon,
                  size: 120,
                  color: Colors.black.withOpacity(0.5),
                ),
        ),
      ),

      // Build Name
      contact.fullName,
      Divider(),
      Padding(padding: EdgeInsets.all(4)),

      // Quick Actions
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 78,
          height: 78,
          child: SonrButton.circle(
              depth: 4,
              onPressed: () {},
              text: SonrText.medium("Mobile", size: 12, color: Colors.black45),
              icon: SonrIcon.gradient(Icons.phone, FlutterGradientNames.highFlight, size: 36),
              iconPosition: WidgetPosition.Top),
        ),
        Padding(padding: EdgeInsets.all(6)),
        SizedBox(
          width: 78,
          height: 78,
          child: SonrButton.circle(
              depth: 4,
              onPressed: () {},
              text: SonrText.medium("Text", size: 12, color: Colors.black45),
              icon: SonrIcon.gradient(Icons.mail, FlutterGradientNames.teenParty, size: 36),
              iconPosition: WidgetPosition.Top),
        ),
        Padding(padding: EdgeInsets.all(6)),
        SizedBox(
            width: 78,
            height: 78,
            child: SonrButton.circle(
                depth: 4,
                onPressed: () {},
                text: SonrText.medium("Video", size: 12, color: Colors.black45),
                icon: SonrIcon.gradient(Icons.video_call_rounded, FlutterGradientNames.deepBlue, size: 36),
                iconPosition: WidgetPosition.Top)),
      ]),

      Divider(),
      Padding(padding: EdgeInsets.all(4)),

      // Brief Contact Card Info
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List<Widget>.generate(contact.socials.length, (index) {
            return contact.socials[index].provider.icon(IconType.Gradient, size: 35);
          }))
    ]);
  }
}

// ^ Widget for Expanded Contact Card View
class _ContactCardExpanded extends StatelessWidget {
  final TransferCard card;
  const _ContactCardExpanded(this.card);
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
            tag: card.id,
            child: Material(
              color: Colors.transparent,
              child: Container(color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }
}
