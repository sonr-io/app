import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:sonr_app/service/user.dart';
import '../theme.dart';
import 'style.dart';

enum _ButtonType { Icon, Text, IconText, DisabledIcon, DisabledText, DisabledIconText }

class SonrButton extends StatelessWidget {
  final bool hasIcon;
  final _ButtonType type;
  final SonrText text;
  final Color color;
  final Color shadowLightColor;
  final Color shadowDarkColor;
  final SonrIcon icon;
  final WidgetPosition iconPosition;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final NeumorphicShape shape;
  final double intensity;
  final Function onPressed;
  final Function onLongPressed;
  final NeumorphicBoxShape boxShape;
  final double depth;
  final Widget child;

  // * Constructer * //
  const SonrButton(
    this.hasIcon,
    this.text,
    this.color,
    this.margin,
    this.shape,
    this.intensity,
    this.depth,
    this.boxShape,
    this.onPressed, {
    this.onLongPressed,
    this.icon,
    this.iconPosition,
    Key key,
    this.shadowLightColor,
    this.shadowDarkColor,
    this.type,
    this.padding,
    this.child,
  });

  // * Rectangle Button * //
  factory SonrButton.rectangle(
      {@required Function onPressed,
      Function onLongPressed,
      SonrText text,
      Widget child,
      SonrIcon icon,
      Color shadowLightColor,
      Color shadowDarkColor,
      Color color = SonrColor.White,
      double depth = 8,
      double radius = 20,
      double intensity = 0.85,
      bool isDisabled = false,
      EdgeInsets margin = EdgeInsets.zero,
      NeumorphicShape shape = NeumorphicShape.concave,
      WidgetPosition iconPosition = WidgetPosition.Left,
      EdgeInsets padding = EdgeInsets.zero}) {
    // Child Provided
    if (child != null) {
      return SonrButton(
        true,
        text,
        color,
        margin,
        shape,
        intensity,
        depth,
        NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
        onPressed,
        onLongPressed: onLongPressed,
        child: child,
        padding: padding,
      );
    } else {
      // Icon AND Text
      if (icon != null && text != null) {
        var type = isDisabled ? _ButtonType.DisabledIconText : _ButtonType.IconText;
        return SonrButton(
          true,
          text,
          color,
          margin,
          shape,
          intensity,
          depth,
          NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
          onPressed,
          onLongPressed: onLongPressed,
          icon: icon,
          iconPosition: iconPosition,
          type: type,
          padding: padding,
        );
      }
      // Icon ONLY
      else if (icon != null && text == null) {
        var type = isDisabled ? _ButtonType.DisabledIcon : _ButtonType.Icon;
        return SonrButton(
          true,
          text,
          color,
          margin,
          shape,
          intensity,
          depth,
          NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
          onPressed,
          onLongPressed: onLongPressed,
          icon: icon,
          iconPosition: WidgetPosition.Center,
          type: type,
          padding: padding,
        );
      }
      // TEXT ONLY
      else {
        var type = isDisabled ? _ButtonType.DisabledText : _ButtonType.Text;
        return SonrButton(
          false,
          text,
          color,
          margin,
          shape,
          intensity,
          depth,
          NeumorphicBoxShape.roundRect(BorderRadius.circular(radius)),
          onPressed,
          onLongPressed: onLongPressed,
          type: type,
          padding: padding,
        );
      }
    }
  }

  // * Flat Button * //
  factory SonrButton.flat({
    @required Function onPressed,
    Function onLongPressed,
    SonrText text,
    Widget child,
    SonrIcon icon,
    Color color = SonrColor.White,
    bool isDisabled = false,
    WidgetPosition iconPosition = WidgetPosition.Left,
  }) {
    // Child Provided
    if (child != null) {
      return SonrButton(
        true,
        text,
        color,
        const EdgeInsets.all(0),
        NeumorphicShape.flat,
        0,
        0,
        NeumorphicBoxShape.rect(),
        onPressed,
        onLongPressed: onLongPressed,
        child: child,
      );
    } else {
      // Icon AND Text
      if (icon != null && text != null) {
        var type = isDisabled ? _ButtonType.DisabledIconText : _ButtonType.IconText;
        return SonrButton(
          true,
          text,
          color,
          const EdgeInsets.all(0),
          NeumorphicShape.flat,
          0,
          0,
          NeumorphicBoxShape.rect(),
          onPressed,
          onLongPressed: onLongPressed,
          icon: icon,
          iconPosition: iconPosition,
          type: type,
        );
      }
      // Icon ONLY
      else if (icon != null && text == null) {
        var type = isDisabled ? _ButtonType.DisabledIcon : _ButtonType.Icon;
        return SonrButton(
          true,
          text,
          color,
          const EdgeInsets.all(0),
          NeumorphicShape.flat,
          0,
          0,
          NeumorphicBoxShape.rect(),
          onPressed,
          onLongPressed: onLongPressed,
          icon: icon,
          iconPosition: WidgetPosition.Center,
          type: type,
        );
      }
      // TEXT ONLY
      else {
        var type = isDisabled ? _ButtonType.DisabledText : _ButtonType.Text;
        return SonrButton(
          false,
          text,
          color,
          const EdgeInsets.all(0),
          NeumorphicShape.flat,
          0,
          0,
          NeumorphicBoxShape.rect(),
          onPressed,
          onLongPressed: onLongPressed,
          type: type,
        );
      }
    }
  }

  // * Circle Style Button * //
  factory SonrButton.circle({
    @required Function onPressed,
    Function onLongPressed,
    SonrIcon icon,
    SonrText text,
    Widget child,
    Color shadowLightColor,
    Color shadowDarkColor,
    Color color = SonrColor.White,
    bool isDisabled = false,
    double depth = 8,
    double intensity = 0.85,
    EdgeInsets margin = EdgeInsets.zero,
    EdgeInsets padding = EdgeInsets.zero,
    NeumorphicShape shape = NeumorphicShape.flat,
    WidgetPosition iconPosition = WidgetPosition.Left,
  }) {
    // Child Provided
    if (child != null) {
      return SonrButton(
        true,
        text,
        color,
        margin,
        shape,
        intensity,
        depth,
        NeumorphicBoxShape.circle(),
        onPressed,
        onLongPressed: onLongPressed,
        child: child,
        padding: padding,
      );
    } else {
      // Icon AND Text
      if (icon != null && text != null) {
        var type = isDisabled ? _ButtonType.DisabledIconText : _ButtonType.IconText;
        return SonrButton(
          true,
          text,
          color,
          margin,
          shape,
          intensity,
          depth,
          NeumorphicBoxShape.circle(),
          onPressed,
          onLongPressed: onLongPressed,
          icon: icon,
          iconPosition: iconPosition,
          type: type,
          padding: padding,
        );
      }
      // Icon ONLY
      else if (icon != null && text == null) {
        var type = isDisabled ? _ButtonType.DisabledIcon : _ButtonType.Icon;
        return SonrButton(
          true,
          null,
          color,
          margin,
          shape,
          intensity,
          depth,
          NeumorphicBoxShape.circle(),
          onPressed,
          onLongPressed: onLongPressed,
          icon: icon,
          iconPosition: WidgetPosition.Center,
          type: type,
          padding: padding,
        );
      }
      // TEXT ONLY
      else {
        var type = isDisabled ? _ButtonType.DisabledText : _ButtonType.Text;
        return SonrButton(
          false,
          text,
          color,
          margin,
          shape,
          intensity,
          depth,
          NeumorphicBoxShape.circle(),
          onPressed,
          onLongPressed: onLongPressed,
          type: type,
          padding: padding,
        );
      }
    }
  }

  // * Stadium Style Button * //
  factory SonrButton.stadium({
    @required Function onPressed,
    Function onLongPressed,
    SonrIcon icon,
    SonrText text,
    Widget child,
    Color shadowLightColor,
    Color shadowDarkColor,
    Color color = SonrColor.White,
    bool isDisabled = false,
    double intensity = 0.85,
    double depth = 8,
    EdgeInsets margin = EdgeInsets.zero,
    EdgeInsets padding = EdgeInsets.zero,
    NeumorphicShape shape = NeumorphicShape.flat,
    WidgetPosition iconPosition = WidgetPosition.Left,
  }) {
    // Child Provided
    if (child != null) {
      return SonrButton(
        true,
        text,
        color,
        margin,
        shape,
        intensity,
        depth,
        NeumorphicBoxShape.stadium(),
        onPressed,
        onLongPressed: onLongPressed,
        child: child,
        padding: padding,
      );
    } else {
      // Icon AND Text
      if (icon != null && text != null) {
        var type = isDisabled ? _ButtonType.DisabledIconText : _ButtonType.IconText;
        return SonrButton(
          true,
          text,
          color,
          margin,
          shape,
          intensity,
          depth,
          NeumorphicBoxShape.stadium(),
          onPressed,
          onLongPressed: onLongPressed,
          icon: icon,
          iconPosition: iconPosition,
          type: type,
          padding: padding,
        );
      }
      // Icon ONLY
      else if (icon != null && text == null) {
        var type = isDisabled ? _ButtonType.DisabledIcon : _ButtonType.Icon;
        return SonrButton(
          true,
          null,
          color,
          margin,
          shape,
          intensity,
          depth,
          NeumorphicBoxShape.stadium(),
          onPressed,
          icon: icon,
          onLongPressed: onLongPressed,
          iconPosition: WidgetPosition.Center,
          type: type,
          padding: padding,
        );
      }
      // TEXT ONLY
      else {
        var type = isDisabled ? _ButtonType.DisabledText : _ButtonType.Text;
        return SonrButton(
          false,
          text,
          color,
          margin,
          shape,
          intensity,
          depth,
          NeumorphicBoxShape.stadium(),
          onPressed,
          onLongPressed: onLongPressed,
          type: type,
          padding: padding,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If Child Provided
    if (child != null) {
      return NeumorphicButton(
        margin: margin,
        style: NeumorphicStyle(
          depth: UserService.isDarkMode.value ? 4 : 8,
          color: UserService.isDarkMode.value ? SonrColor.Dark : SonrColor.White,
          boxShape: boxShape,
          intensity: UserService.isDarkMode.value ? 0.6 : 0.85,
        ),
        padding: const EdgeInsets.all(12.0),
        onPressed: () {
          if (onPressed != null) {
            HapticFeedback.mediumImpact();
            onPressed();
          }
        },
        child: GestureDetector(
          onLongPress: () {
            if (onLongPressed != null) {
              HapticFeedback.heavyImpact();
              onLongPressed();
            }
          },
          child: Container(child: child),
        ),
      );
    }
    // If Child Not Provided
    else {
      // Initialize
      bool isDisabled;
      var iconChild;
      var textChild;

      // Update Children
      switch (type) {
        case _ButtonType.DisabledIcon:
          iconChild = SonrIcon.normal(icon.data, size: icon.size, color: SonrColor.Grey);
          isDisabled = true;
          break;
        case _ButtonType.DisabledText:
          textChild = SonrText.medium(text.text, size: text.size, color: SonrColor.Grey);
          isDisabled = true;
          break;
        case _ButtonType.DisabledIconText:
          iconChild = SonrIcon.normal(icon.data, size: icon.size, color: SonrColor.Grey);
          textChild = SonrText.medium(text.text, size: text.size, color: SonrColor.Grey);
          isDisabled = true;
          break;
        default:
          iconChild = icon;
          textChild = text;
          isDisabled = false;
          break;
      }

      // Create View
      if (isDisabled) {
        var child = Animated(child: hasIcon ? _buildIconView(iconChild, textChild) : textChild);
        return NeumorphicButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            onPressed();
            child.shake();
          },
          margin: margin,
          style: NeumorphicStyle(
            depth: 0,
            color: color,
            boxShape: boxShape,
            intensity: 0,
          ),
          padding: const EdgeInsets.all(12.0),
          child: child,
        );
      } else {
        return NeumorphicButton(
          margin: margin,
          style: NeumorphicStyle(
            depth: UserService.isDarkMode.value ? 4 : 8,
            color: UserService.isDarkMode.value ? SonrColor.Dark : SonrColor.White,
            boxShape: boxShape,
            intensity: UserService.isDarkMode.value ? 0.6 : 0.85,
          ),
          padding: const EdgeInsets.all(12.0),
          onPressed: () {
            if (onPressed != null) {
              HapticFeedback.mediumImpact();
              onPressed();
            }
          },
          child: GestureDetector(
            onLongPress: () {
              if (onLongPressed != null) {
                HapticFeedback.heavyImpact();
                onLongPressed();
              }
            },
            child: hasIcon ? _buildIconView(iconChild, textChild) : textChild,
          ),
        );
      }
    }
  }

  _buildIconView(Widget iconWidget, Widget textWidget) {
    switch (iconPosition) {
      case WidgetPosition.Left:
        return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [iconWidget, textWidget]);
        break;
      case WidgetPosition.Right:
        return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [textWidget, iconWidget]);
        break;
      case WidgetPosition.Top:
        return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [iconWidget, textWidget]);
        break;
      case WidgetPosition.Bottom:
        return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [textWidget, iconWidget]);
        break;
      case WidgetPosition.Center:
        return iconWidget;
        break;
    }
    return Container();
  }
}

enum ColorButtonType { Primary, Secondary, Neutral, Critical }

class SonrColorButton extends StatefulWidget {
  static const double PRESSED_SCALE = 0.95;
  static const double UNPRESSED_SCALE = 1.0;
  static const double K_BORDER_RADIUS = 8;

  final EdgeInsets margin;
  final EdgeInsets padding;
  final Widget child;
  final Decoration decoration;
  final Function onPressed;
  final Function onLongPressed;
  final String tooltip;
  final bool isEnabled;

  const SonrColorButton({
    Key key,
    @required this.onPressed,
    @required this.child,
    @required this.decoration,
    this.margin,
    this.padding,
    this.onLongPressed,
    this.tooltip,
    this.isEnabled = true,
  }) : super(key: key);

  // @ Primary Button //
  factory SonrColorButton.primary({
    @required Function onPressed,
    Gradient gradient,
    Function onLongPressed,
    Widget child,
    String tooltip,
    EdgeInsets padding,
    EdgeInsets margin,
    Icon icon,
    String text,
    WidgetPosition iconPosition = WidgetPosition.Left,
  }) {
    // Build Decoration
    BoxDecoration decoration = BoxDecoration(
        gradient: gradient != null ? gradient : SonrPalete.primary(),
        borderRadius: BorderRadius.circular(K_BORDER_RADIUS),
        boxShadow: [BoxShadow(offset: Offset(0, 4), color: SonrPalete.Primary.withOpacity(0.4), blurRadius: 12, spreadRadius: 4)]);

    // Build Child
    return SonrColorButton(
        decoration: decoration,
        onPressed: onPressed,
        child: _buildChild(iconPosition, icon, text, child),
        tooltip: tooltip,
        padding: padding,
        margin: margin,
        onLongPressed: onLongPressed);
  }

  // @ Secondary Button //
  factory SonrColorButton.secondary({
    @required Function onPressed,
    Color color,
    Function onLongPressed,
    Widget child,
    String tooltip,
    EdgeInsets padding,
    EdgeInsets margin,
    Icon icon,
    String text,
    WidgetPosition iconPosition = WidgetPosition.Left,
  }) {
    // Decoration
    BoxDecoration decoration = BoxDecoration(
      color: color != null ? color : SonrPalete.Secondary,
      borderRadius: BorderRadius.circular(K_BORDER_RADIUS),
    );

    // Build Child
    return SonrColorButton(
        decoration: decoration,
        onPressed: onPressed,
        child: _buildChild(iconPosition, icon, text, child),
        tooltip: tooltip,
        padding: padding,
        margin: margin,
        onLongPressed: onLongPressed);
  }

  // @ Neutral Button //
  factory SonrColorButton.neutral({
    @required Function onPressed,
    Function onLongPressed,
    Widget child,
    String tooltip,
    EdgeInsets padding,
    EdgeInsets margin,
    Icon icon,
    String text,
    WidgetPosition iconPosition = WidgetPosition.Left,
  }) {
    // Decoration
    BoxDecoration decoration = BoxDecoration(
      color: SonrColor.Neutral,
      borderRadius: BorderRadius.circular(K_BORDER_RADIUS),
    );

    // Build Child
    return SonrColorButton(
        decoration: decoration,
        onPressed: onPressed,
        child: _buildChild(iconPosition, icon, text, child),
        tooltip: tooltip,
        padding: padding,
        margin: margin,
        onLongPressed: onLongPressed);
  }

  // @ Helper Method to Build Icon View //
  static Widget _buildChild(WidgetPosition iconPosition, Widget icon, String text, Widget child) {
    if (child != null) {
      return child;
    } else if (icon != null && text == null) {
      return Container(padding: EdgeInsets.all(8), child: icon);
    } else if (text != null && icon == null) {
      return Container(padding: EdgeInsets.all(8), child: _buildText(text));
    } else if (text != null && icon != null) {
      switch (iconPosition) {
        case WidgetPosition.Left:
          return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [icon, _buildText(text)]);
        case WidgetPosition.Right:
          return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildText(text), icon]);
        case WidgetPosition.Top:
          return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [icon, _buildText(text)]);
        case WidgetPosition.Bottom:
          return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildText(text), icon]);
        case WidgetPosition.Center:
          return icon;
        default:
          return Container();
      }
    } else {
      return Container();
    }
  }

  static Widget _buildText(String text) {
    return Text(text,
        overflow: TextOverflow.fade,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 4, color: SonrColor.Black.withOpacity(0.5))]));
  }

  @override
  _SonrColorButtonState createState() => _SonrColorButtonState();
}

class _SonrColorButtonState extends State<SonrColorButton> {
  bool hasFinishedAnimationDown = false;
  bool hasFinishedLongAnimationDown = false;
  bool hasTapUp = false;
  bool hasLongTapUp = false;
  bool pressed = false;
  bool longPressed = false;
  bool hasDisposed = false;

  static const K_BUTTON_DURATION = Duration(milliseconds: 100);
  static const K_BUTTON_PADDING = const EdgeInsets.symmetric(horizontal: 24, vertical: 8);

  @override
  void dispose() {
    super.dispose();
    hasDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    final result = _build(context);
    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip,
        child: result,
      );
    } else {
      return result;
    }
  }

  Widget _build(BuildContext context) {
    return GestureDetector(
      onTapDown: (detail) {
        hasTapUp = false;
        if (!pressed && !longPressed) {
          _handlePress();
        }
      },
      onTapUp: (details) {
        widget.onPressed();
        hasTapUp = true;
        _resetIfTapUp();
      },
      onLongPressStart: (details) {
        hasLongTapUp = false;
        if (!longPressed) {
          _handleLongPress();
        }
      },
      onLongPressUp: () {
        if (widget.onLongPressed != null) {
          widget.onLongPressed();
        }
        hasLongTapUp = true;
        _resetIfLongTapUp();
      },
      onTapCancel: () {
        hasTapUp = true;
        _resetIfTapUp();
      },
      child: ControlAnimated(
        scale: this.pressed ? SonrColorButton.PRESSED_SCALE : SonrColorButton.UNPRESSED_SCALE,
        child: AnimatedContainer(
          decoration: widget.decoration,
          margin: widget.margin ?? const EdgeInsets.all(0),
          duration: K_BUTTON_DURATION,
          curve: Curves.ease,
          padding: K_BUTTON_PADDING,
          child: widget.child,
        ),
      ),
    );
  }

  Future<void> _handlePress() async {
    hasFinishedAnimationDown = false;
    setState(() {
      pressed = true;
    });

    await Future.delayed(K_BUTTON_DURATION); //wait until animation finished
    hasFinishedAnimationDown = true;

    //haptic vibration
    HapticFeedback.mediumImpact();
    _resetIfTapUp();
  }

  //used to stay pressed if no tap up
  void _resetIfTapUp() {
    if (hasFinishedAnimationDown == true && hasTapUp == true && !hasDisposed) {
      setState(() {
        pressed = false;

        hasFinishedAnimationDown = false;
        hasTapUp = false;
      });
    }
  }

  Future<void> _handleLongPress() async {
    hasFinishedLongAnimationDown = false;
    setState(() {
      longPressed = true;
    });

    await Future.delayed(K_BUTTON_DURATION); //wait until animation finished
    hasFinishedLongAnimationDown = true;

    //haptic vibration
    HapticFeedback.heavyImpact();
    _resetIfLongTapUp();
  }

  void _resetIfLongTapUp() {
    if (hasFinishedLongAnimationDown == true && hasLongTapUp == true && !hasDisposed) {
      setState(() {
        longPressed = false;

        hasFinishedLongAnimationDown = false;
        hasLongTapUp = false;
      });
    }
  }
}
