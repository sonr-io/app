import 'package:get/get.dart';
import 'package:media_gallery/media_gallery.dart';
import 'package:sonr_app/theme/theme.dart';
import 'package:sonr_core/sonr_core.dart';

class SonrForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

// ^ Builds Overlay Based Positional Dropdown Menu ^ //
class SonrDropdown extends StatelessWidget {
  // Properties
  final ValueChanged<int> onChanged;
  final EdgeInsets margin;
  final double width;
  final double height;

  // Overlay Properties
  final double overlayHeight;
  final double overlayWidth;
  final EdgeInsets overlayMargin;
  final WidgetPosition selectedIconPosition;

  // References
  final List<SonrDropdownItem> items;
  final String title;
  final RxInt index = (-1).obs;

  // * Builds Social Media Dropdown * //
  factory SonrDropdown.social(List<Contact_SocialTile_Provider> data,
      {@required ValueChanged<int> onChanged, EdgeInsets margin = const EdgeInsets.only(left: 14, right: 14), double width, double height = 60}) {
    var items = List<SonrDropdownItem>.generate(data.length, (index) {
      return SonrDropdownItem(true, data[index].toString(), icon: SonrIcon.social(IconType.Gradient, data[index]));
    });
    return SonrDropdown(items, "Choose", onChanged, margin, width ?? Get.width - 250, height);
  }

  // * Builds Albums Dropdown * //
  factory SonrDropdown.albums(List<MediaCollection> data,
      {@required ValueChanged<int> onChanged, EdgeInsets margin = const EdgeInsets.only(left: 14, right: 14), double width, double height = 60}) {
    var items = List<SonrDropdownItem>.generate(data.length, (index) {
      // Initialize
      var collection = data[index];
      var hasIcon = false;
      var icon;

      // Set Icon for Generated Albums
      switch (collection.name.toLowerCase()) {
        case "all":
          hasIcon = true;
          icon = SonrIcon.gradient(Icons.all_inbox_rounded, FlutterGradientNames.premiumDark, size: 20);
          break;
        case "sonr":
          hasIcon = true;
          icon = SonrIcon.sonr;
          break;
        case "download":
          hasIcon = true;
          icon = SonrIcon.gradient(Icons.download_rounded, FlutterGradientNames.orangeJuice, size: 20);
          break;
        case "screenshots":
          hasIcon = true;
          icon = SonrIcon.screenshots;
          break;
        case "movies":
          hasIcon = true;
          icon = SonrIcon.gradient(Icons.movie_creation_outlined, FlutterGradientNames.lilyMeadow, size: 20);
          break;
        case "panoramas":
          hasIcon = true;
          icon = SonrIcon.panorama;
          break;
        case "favorites":
          hasIcon = true;
          icon = SonrIcon.gradient(Icons.star_half_rounded, FlutterGradientNames.fruitBlend, size: 20);
          break;
        case "recents":
          hasIcon = true;
          icon = SonrIcon.gradient(Icons.timelapse, FlutterGradientNames.crystalline, size: 20);
          break;
      }

      // Return Item
      return SonrDropdownItem(hasIcon, collection.name, icon: icon);
    });
    return SonrDropdown(items, "All", onChanged, margin, width ?? Get.width - 250, height, selectedIconPosition: WidgetPosition.Left);
  }

  SonrDropdown(this.items, this.title, this.onChanged, this.margin, this.width, this.height,
      {this.overlayHeight, this.overlayWidth, this.overlayMargin, this.selectedIconPosition = WidgetPosition.Right});
  @override
  Widget build(BuildContext context) {
    GlobalKey _dropKey = LabeledGlobalKey("Sonr_Dropdown");
    return ObxValue<RxInt>((selectedIndex) {
      return Container(
          key: _dropKey,
          width: width,
          margin: margin,
          height: height,
          child: Obx(
            () => NeumorphicButton(
                margin: EdgeInsets.symmetric(horizontal: 5),
                style: SonrStyle.flat,
                child: Center(child: _buildSelected(selectedIndex.value, Get.find<SonrPositionedOverlay>().overlays.length > 0)),
                onPressed: () {
                  SonrPositionedOverlay.dropdown(items, _dropKey, (newIndex) {
                    selectedIndex(newIndex);
                    onChanged(newIndex);
                  }, height: overlayHeight, width: overlayWidth, margin: overlayMargin);
                }),
          ));
    }, index);
  }

  _buildSelected(int idx, bool isOpen) {
    // @ Default Widget
    if (idx == -1) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SonrText.medium(title, color: Colors.black87, size: height / 3),
        isOpen
            ? SonrIcon.normal(Icons.arrow_upward_rounded, color: Colors.black)
            : SonrIcon.normal(Icons.arrow_downward_rounded, color: Colors.black),
      ]);
    }

    // Selected Widget
    else {
      var item = items[idx];
      if (selectedIconPosition == WidgetPosition.Left) {
        return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          item.hasIcon ? item.icon : Container(),
          SonrText.medium(item.text, color: Colors.black87, size: height / 3),
        ]);
      } else {
        return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SonrText.medium(item.text, color: Colors.black87, size: height / 3),
          item.hasIcon ? item.icon : Container(),
        ]);
      }
    }
  }
}

// ^ Builds Dropdown Menu Item Widget ^ //
class SonrDropdownItem extends StatelessWidget {
  final Widget icon;
  final String text;
  final bool hasIcon;

  const SonrDropdownItem(this.hasIcon, this.text, {this.icon, Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (hasIcon) {
      return Row(children: [
        Neumorphic(
          child: icon,
          style: SonrStyle.indented,
          padding: EdgeInsets.all(10),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SonrText.medium(text),
        )
      ]);
    } else {
      return Row(children: [Padding(padding: EdgeInsets.all(4)), SonrText.medium(text, color: Colors.black)]);
    }
  }
}