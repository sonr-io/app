import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sonr_app/theme/theme.dart';
import 'package:rive/rive.dart';

enum AnimType { None, Shake, FadeIn, FadeOut, SlideIn }
enum AnimState { Instant, Controlled }
enum AnimSwitch { Fade, SlideUp, SlideDown, SlideLeft, SlideRight }
enum ArtboardType { Camera, Gallery, Contact, Feed }

class SonrAnimatedWidget extends GetWidget<AnimatedController> {
  final Widget child;
  final AnimState state;
  final AnimType animation;
  final Duration delay;
  final Duration duration;
  const SonrAnimatedWidget({
    @required this.child,
    @required this.state,
    this.animation = AnimType.FadeIn,
    this.duration = const Duration(seconds: 1),
    this.delay = const Duration(milliseconds: 0),
  });

  factory SonrAnimatedWidget.instant({@required AnimType animation, @required Widget child, Duration delay}) {
    return SonrAnimatedWidget(child: child, state: AnimState.Instant, animation: animation, delay: delay);
  }

  factory SonrAnimatedWidget.controlled({@required Widget child, Duration delay}) {
    return SonrAnimatedWidget(child: child, state: AnimState.Controlled, delay: delay);
  }

  @override
  Widget build(BuildContext context) {
    // @ Check Animation State for Switcher
    if (state == AnimState.Instant) {
      return _buildGeneralAnimation(animation);
    } else if (state == AnimState.Controlled) {
      return Obx(() {
        return _buildGeneralAnimation(controller.type.value);
      });
    } else {
      return child;
    }
  }

  Widget _buildGeneralAnimation(AnimType animation) {
    if (animation == AnimType.Shake) {
      return TweenAnimationBuilder<double>(
        key: key,
        tween: Tween(begin: 0.0, end: 1.0),
        duration: 1.seconds,
        builder: (context, animation, child) => Transform.translate(
          offset: controller.shakeOffset(animation),
          child: child,
        ),
        child: child,
      );
    } else if (animation == AnimType.FadeIn) {
      return PlayAnimation<double>(
          tween: (0.0).tweenTo(1.0),
          duration: 500.milliseconds,
          delay: delay,
          builder: (context, child, value) {
            return AnimatedOpacity(opacity: value, duration: 500.milliseconds, child: child);
          });
    } else if (animation == AnimType.FadeOut) {
      return PlayAnimation<double>(
          tween: (1.0).tweenTo(0.0),
          duration: 150.milliseconds,
          delay: delay,
          builder: (context, child, value) {
            return AnimatedOpacity(opacity: value, duration: 150.milliseconds, child: child);
          });
    } else if (animation == AnimType.SlideIn) {
      return TweenAnimationBuilder<Offset>(
        key: key,
        tween: Tween(begin: Offset.zero, end: Offset(0.0, 1.0)),
        duration: 1.seconds,
        builder: (context, animation, child) => Transform.translate(
          offset: animation,
          child: child,
        ),
        child: child,
      );
    }
    return child;
  }

  void animate(AnimType anim) {
    switch (anim) {
      case AnimType.Shake:
        controller.shake();
        break;
      case AnimType.FadeIn:
        controller.fadeIn();
        break;
      case AnimType.FadeOut:
        controller.fadeOut();
        break;
      default:
        break;
    }
  }

  void reset() {
    controller.type(AnimType.None);
    controller.type.refresh();
  }
}

class AnimatedController extends GetxController {
  // Properties
  final type = AnimType.None.obs;

  // ^ Duration Returners ^ //
  Duration get shakeDuration => 1000.milliseconds;
  Duration get fadeInDuration => 250.milliseconds;
  Duration get fadeOutDuration => 150.milliseconds;

  // ^ Method to Begin Shake ^ //
  void shake() {
    // Start Animation
    type(AnimType.Shake);
    type.refresh();

    // Reset
    Future.delayed(shakeDuration, () {
      type(AnimType.None);
    });
  }

  void fadeIn() {
    // Start Animation
    type(AnimType.FadeIn);
    type.refresh();

    // Reset
    Future.delayed(fadeInDuration, () {
      type(AnimType.None);
    });
  }

  void fadeOut() {
    // Start Animation
    type(AnimType.FadeOut);
    type.refresh();

    // Reset
    Future.delayed(fadeOutDuration, () {
      type(AnimType.None);
    });
  }

  // ^ Get Animated Offset for Shake Method ^ //
  Offset shakeOffset(double animation) {
    var shake = 2 * (0.5 - (0.5 - Curves.bounceOut.transform(animation)).abs());
    return Offset(18 * shake, 0);
  }
}

class SonrRiveWidget extends GetView<RiveWidgetController> {
  final double width;
  final double height;
  final Artboard artboard;
  const SonrRiveWidget(this.artboard, this.width, this.height);

  factory SonrRiveWidget.fromType({@required ArtboardType type, double width = 55, double height = 55}) {
    final controller = Get.find<RiveWidgetController>();
    return SonrRiveWidget(controller.getArtboard(type), width, height);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loaded.value) {
        return SizedBox(
          height: height,
          width: width,
          child: Center(child: Rive(artboard: artboard)),
        );
      } else {
        return Container();
      }
    });
  }
}

class RiveWidgetController extends GetxController {
  // References
  ByteData _riveFileData;
  final String path;
  final loaded = false.obs;

  RiveWidgetController(this.path) {
    // Load the RiveFile from the binary data.
    rootBundle.load(path).then((data) async {
      if (data != null) {
        _riveFileData = data;
      }
    });
  }

  // ^ Gets Pre Initialized Artboard by Type ^ //
  Artboard getArtboard(ArtboardType type) {
    // @ Initialize File
    final riveFile = RiveFile();
    riveFile.import(_riveFileData);
    final artboard = riveFile.mainArtboard;

    // @ Add Controller
    if (type == ArtboardType.Camera) {
      artboard.addController(SimpleAnimation('Camera'));
    }
    // Retreive Showcase Loop
    else if (type == ArtboardType.Gallery) {
      artboard.addController(SimpleAnimation('Showcase'));
    }
    // Retreive Showcase Loop
    else if (type == ArtboardType.Feed) {
      artboard.addController(SimpleAnimation('Feed'));
    }
    // Retreive Icon Loop
    else {
      artboard.addController(SimpleAnimation('Icon'));
    }

    // @ Return Board
    loaded(true);
    return artboard;
  }
}

class SonrAnimatedSwitcher extends StatelessWidget {
  final AnimSwitch _animation;
  final Widget child;
  final Duration duration;

  // * Constructer * //
  const SonrAnimatedSwitcher(this._animation, this.child, this.duration);

  // * Factory Fade * //
  factory SonrAnimatedSwitcher.fade({@required child, Duration duration = const Duration(seconds: 2, milliseconds: 500)}) {
    return SonrAnimatedSwitcher(AnimSwitch.Fade, child, duration);
  }

  // * Factory Slide Up * //
  factory SonrAnimatedSwitcher.slideUp({@required child, Duration duration = const Duration(seconds: 2, milliseconds: 500)}) {
    return SonrAnimatedSwitcher(AnimSwitch.SlideUp, child, duration);
  }

  // * Factory Slide Down * //
  factory SonrAnimatedSwitcher.slideDown({@required child, Duration duration = const Duration(seconds: 2, milliseconds: 500)}) {
    return SonrAnimatedSwitcher(AnimSwitch.SlideDown, child, duration);
  }

  // * Factory Slide Left * //
  factory SonrAnimatedSwitcher.slideLeft({@required child, Duration duration = const Duration(seconds: 2, milliseconds: 500)}) {
    return SonrAnimatedSwitcher(AnimSwitch.SlideLeft, child, duration);
  }

  // * Factory Slide Right * //
  factory SonrAnimatedSwitcher.slideRight({@required child, Duration duration = const Duration(seconds: 2, milliseconds: 500)}) {
    return SonrAnimatedSwitcher(AnimSwitch.SlideRight, child, duration);
  }

  // ^ Build View Method ^ //
  @override
  Widget build(BuildContext context) {
    // Initialize Transition Map
    Map<AnimSwitch, Widget Function(Widget, Animation<double>)> transitionMap = {
      AnimSwitch.Fade: AnimatedSwitcher.defaultTransitionBuilder,
      AnimSwitch.SlideDown: _slideTransition(0, -1),
      AnimSwitch.SlideUp: _slideTransition(0, 1),
      AnimSwitch.SlideLeft: _slideTransition(-1, 0),
      AnimSwitch.SlideRight: _slideTransition(1, 0),
    };

    // Return Switcher
    return AnimatedSwitcher(
        duration: duration,
        switchOutCurve: Curves.easeInOutSine,
        switchInCurve: Curves.fastLinearToSlowEaseIn,
        transitionBuilder: transitionMap[_animation],
        layoutBuilder: (Widget currentChild, List<Widget> previousChildren) {
          return currentChild;
        },
        child: child);
  }

  // ^ Method Builds Slide Transition ^ //
  Widget Function(Widget, Animation<double>) _slideTransition(double x, double y) {
    return (Widget child, Animation<double> animation) {
      final offsetAnimation = TweenSequence([
        TweenSequenceItem(tween: Tween<Offset>(begin: Offset(x, y), end: Offset(0.0, 0.0)), weight: 1),
        TweenSequenceItem(tween: ConstantTween(Offset(0.0, 0.0)), weight: 2),
      ]).animate(animation);
      return ClipRect(
        child: SlideTransition(
          position: offsetAnimation,
          child: child,
        ),
      );
    };
  }
}
