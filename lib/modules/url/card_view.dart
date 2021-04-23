import 'package:sonr_app/theme/theme.dart';
import 'package:sonr_core/sonr_core.dart';
import 'package:url_launcher/url_launcher.dart';

// ^ Widget for Expanded Media View
class URLCardView extends StatelessWidget {
  final TransferCardItem card;
  const URLCardView(this.card);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchURL(card.url.link),
      child: Container(
        decoration: Neumorph.floating(),
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
            child: Container(),
          ),
        ),
      ),
    );
  }

  // ^ Launch a URL Event ^ //
  Future launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      SonrSnack.error("Could not launch the URL.");
    }
  }
}