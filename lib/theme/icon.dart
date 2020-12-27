import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_gradients/flutter_gradients.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:sonr_core/sonr_core.dart';

import 'color.dart';
export 'package:flutter_gradients/flutter_gradients.dart';

enum IconType { Neumorphic, Normal, Gradient, Thumbnail }

class SonrIcon extends StatelessWidget {
  final IconData data;
  final IconType type;
  final double size;
  final FlutterGradientNames gradient;
  final Color color;
  final List<int> thumbnail;

  SonrIcon(this.data, this.type, this.color, this.gradient,
      {this.thumbnail, this.size});

  // ^ Gradient Icon with Provided Data
  factory SonrIcon.gradient(
    IconData data,
    FlutterGradientNames gradient, {
    double size = 40,
  }) {
    return SonrIcon(data, IconType.Gradient, Colors.white, gradient,
        size: size);
  }

  // ^ Gradient Icon with Provided Data
  factory SonrIcon.neumorphic(IconData data,
      {double size = 30, Color color = K_BASE_COLOR}) {
    return SonrIcon(data, IconType.Neumorphic, color, null, size: size);
  }

  // ^ Gradient Icon with Provided Data
  factory SonrIcon.normal(IconData data,
      {double size = 24, Color color = K_BASE_COLOR}) {
    return SonrIcon(data, IconType.Normal, color, null, size: size);
  }

  // ^ Social Type Icon
  factory SonrIcon.social(IconType type, Contact_SocialTile_Provider social,
      {double size = 24, Color color = Colors.black, bool alternate = false}) {
    // Init Icon Data
    _IconGradientWData result = _SonrIconData.socials[social];
    return SonrIcon(result.data(alternate), type, color, result.gradient,
        size: size);
  }

  // ^ Peer Data Platform to Icon
  factory SonrIcon.device(IconType type, Peer peer,
      {Color color, double size = 30}) {
    // Set Color
    if (type == IconType.Normal) {
      color = Colors.white;
    } else {
      color = K_BASE_COLOR;
    }
    _IconGradientWData result = _SonrIconData.devices[peer.device.platform];

    // Get Icon
    if (result != null) {
      return SonrIcon(
        result._data,
        type,
        color,
        result.gradient,
        size: size,
      );
    } else {
      return SonrIcon(
        Icons.device_unknown,
        type,
        color,
        FlutterGradientNames.viciousStance,
        size: size,
      );
    }
  }

  // ^ Payload Data File Type to Icon
  factory SonrIcon.file(IconType type, Payload payload,
      {double size = 30,
      Color color = Colors.black,
      FlutterGradientNames gradient = FlutterGradientNames.orangeJuice}) {
    // Contact
    if (payload.type == Payload_Type.CONTACT) {
      return SonrIcon(
        _SonrIconData.contact,
        type,
        color,
        gradient,
        thumbnail: payload.file.thumbnail,
        size: size,
      );
    }

    // File
    else if (payload.type == Payload_Type.FILE) {
      return SonrIcon(
        _SonrIconData.files[payload.file.mime.type],
        type,
        color,
        gradient,
        thumbnail: payload.file.thumbnail,
        size: size,
      );
    }

    // URL
    else {
      return SonrIcon(
        _SonrIconData.url,
        type,
        color,
        gradient,
        thumbnail: payload.file.thumbnail,
        size: size,
      );
    }
  }

  // ^ UI Icons ^ //
  static SonrIcon get success =>
      SonrIcon(_SonrIconData.success, IconType.Normal, Colors.black, null);

  static SonrIcon get missing =>
      SonrIcon(_SonrIconData.missing, IconType.Normal, Colors.black, null);

  static SonrIcon get error =>
      SonrIcon(_SonrIconData.error, IconType.Normal, Colors.black, null);

  static SonrIcon get cancel =>
      SonrIcon(_SonrIconData.cancel, IconType.Normal, Colors.black, null);

  static SonrIcon get info =>
      SonrIcon(_SonrIconData.info, IconType.Normal, Colors.black, null);

  static Padding socialBadge(Contact_SocialTile_Provider prov) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: SonrIcon.social(
            IconType.Gradient, Contact_SocialTile_Provider.Medium,
            size: 30),
      ),
    );
  }

  // ^ Build View of Icon ^ //
  @override
  Widget build(BuildContext context) {
    Widget result;
    switch (type) {
      // @ Creates Neumorphic Icon
      case IconType.Neumorphic:
        result = NeumorphicIcon((data),
            size: size, style: NeumorphicStyle(color: color));
        break;

      // @ Creates Normal Icon
      case IconType.Normal:
        result = Icon(data, size: size, color: color);
        break;

      // @ Creates Gradient Icon
      case IconType.Gradient:
        result = ShaderMask(
          shaderCallback: (bounds) {
            var grad = FlutterGradients.findByName(gradient);
            return grad.createShader(bounds);
          },
          child: Icon(
            data,
            size: size,
            color: Colors.white,
          ),
        );
        break;

      // @ Creates Thumbnail or Icon
      case IconType.Thumbnail:
        if (thumbnail != null) {
          result = ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
              child: FittedBox(
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: 1, minHeight: 1, maxWidth: 200), // here
                      child: Image.memory(thumbnail))));
        } else {
          result = Icon(data, size: size);
        }
        break;
    }
    return result;
  }
}

class _SonrIconData {
  _SonrIconData._();
  static const _kFontFam = 'SonrIcons';
  static const _kFontPkg = null;

  static const IconData spotify =
      IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData twitter_rt =
      IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData youtube_text =
      IconData(0xe802, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData tiktok =
      IconData(0xe803, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData iphone =
      IconData(0xe804, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData android =
      IconData(0xe805, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData url =
      IconData(0xe806, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData contact =
      IconData(0xe807, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData image =
      IconData(0xe80e, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData success =
      IconData(0xe815, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData cancel =
      IconData(0xe818, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData missing =
      IconData(0xe81e, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData info =
      IconData(0xe81f, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData github =
      IconData(0xf09b, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData text =
      IconData(0xf0f6, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData github_alt =
      IconData(0xf113, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData youtube =
      IconData(0xf167, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData instagram =
      IconData(0xf16d, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData audio =
      IconData(0xf1c7, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData medium_fill =
      IconData(0xf23a, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData snapchat =
      IconData(0xf2ac, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData snapchat_fill =
      IconData(0xf2ad, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData facebook =
      IconData(0xf300, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData facebook_fill =
      IconData(0xf301, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData twitter =
      IconData(0xf309, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData medium =
      IconData(0xf3c7, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData video =
      IconData(0xf87c, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData error =
      IconData(0xe808, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  // ^ SocialProvider to Icon Map ^ //
  static Map<Contact_SocialTile_Provider, _IconGradientWData> socials = {
    Contact_SocialTile_Provider.Spotify:
        _IconGradientWData(_SonrIconData.spotify, FlutterGradientNames.newLife),
    Contact_SocialTile_Provider.TikTok: _IconGradientWData(
        _SonrIconData.tiktok, FlutterGradientNames.premiumDark),
    Contact_SocialTile_Provider.Instagram: _IconGradientWData(
        _SonrIconData.instagram, FlutterGradientNames.ripeMalinka),
    Contact_SocialTile_Provider.Twitter: _IconGradientWData(
        _SonrIconData.twitter, FlutterGradientNames.partyBliss,
        alt: _SonrIconData.twitter_rt),
    Contact_SocialTile_Provider.YouTube: _IconGradientWData(
        _SonrIconData.youtube, FlutterGradientNames.loveKiss,
        alt: _SonrIconData.youtube_text),
    Contact_SocialTile_Provider.Medium: _IconGradientWData(
        _SonrIconData.medium, FlutterGradientNames.eternalConstance,
        alt: _SonrIconData.medium_fill),
    Contact_SocialTile_Provider.Facebook: _IconGradientWData(
        _SonrIconData.facebook, FlutterGradientNames.perfectBlue,
        alt: _SonrIconData.facebook_fill),
    Contact_SocialTile_Provider.Snapchat: _IconGradientWData(
        _SonrIconData.snapchat, FlutterGradientNames.sunnyMorning,
        alt: _SonrIconData.snapchat_fill),
    Contact_SocialTile_Provider.Github: _IconGradientWData(
        _SonrIconData.github, FlutterGradientNames.solidStone,
        alt: _SonrIconData.github_alt),
  };

  // ^ Device Platform to Icon Map ^ //
  static Map<String, _IconGradientWData> devices = {
    "Android": _IconGradientWData(
        _SonrIconData.android, FlutterGradientNames.dustyGrass),
    "iOS": _IconGradientWData(
        _SonrIconData.iphone, FlutterGradientNames.highFlight),
  };

  // ^ File Type to Icon Map ^ //
  static Map<MIME_Type, IconData> files = {
    MIME_Type.audio: _SonrIconData.audio,
    MIME_Type.image: _SonrIconData.image,
    MIME_Type.text: _SonrIconData.text,
    MIME_Type.video: _SonrIconData.video,
  };
}

class _IconGradientWData {
  final FlutterGradientNames gradient;
  final IconData _data;
  final IconData alt;
  const _IconGradientWData(this._data, this.gradient, {this.alt});

  IconData data(bool isAlt) {
    return isAlt ? alt : _data;
  }
}
