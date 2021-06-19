import 'package:sonr_app/style.dart';

/// Rive Board Options
enum RiveBoard { Splash, Documents, Bubble }

/// #### Extension For RiveBoard
extension RiveBoardUtils on RiveBoard {
  /// Returns Path for Lottie File
  String get path {
    switch (this) {
      case RiveBoard.Splash:
        return 'assets/animations/splash.riv';
      case RiveBoard.Documents:
        return 'assets/animations/documents.riv';
      case RiveBoard.Bubble:
        return 'assets/animations/bubble.riv';
    }
  }

  /// Loads Byte Data for Rive Board
  Future<ByteData> load() async {
    return await rootBundle.load(this.path);
  }
}

/// Lottie File Options
enum LottieFile { Loader, Celebrate }

/// #### Extension For Lottie File
extension LottieFileUtils on LottieFile {
  /// Returns Path for Lottie File
  String get path {
    switch (this) {
      case LottieFile.Loader:
        if (UserService.isDarkMode) {
          return 'assets/animations/loader-white.json';
        } else {
          return 'assets/animations/loader-black.json';
        }
      case LottieFile.Celebrate:
        return 'assets/animations/celebrate.json';
    }
  }
}

/// Animated Slide Switch
enum SwitchType { Fade, SlideUp, SlideDown, SlideLeft, SlideRight }

/// #### Extension For SwitchType
extension SwitchTypeUtils on SwitchType {
  /// Returns This Type X-Value
  double get x {
    switch (this) {
      case SwitchType.Fade:
        return 0;
      case SwitchType.SlideUp:
        return 0;
      case SwitchType.SlideDown:
        return 0;
      case SwitchType.SlideLeft:
        return -1;
      case SwitchType.SlideRight:
        return 1;
    }
  }

  /// Returns This Type Y-Value
  double get y {
    switch (this) {
      case SwitchType.Fade:
        return 0;
      case SwitchType.SlideUp:
        return 1;
      case SwitchType.SlideDown:
        return -1;
      case SwitchType.SlideLeft:
        return 0;
      case SwitchType.SlideRight:
        return 0;
    }
  }

  /// Returns This Type Animation Builder
  Widget Function(Widget, Animation<double>) get transition {
    if (this == SwitchType.Fade) {
      return AnimatedSwitcher.defaultTransitionBuilder;
    } else {
      return _buildTransition(this.x, this.y);
    }
  }

  /// Builds Transition for this Switch
  Widget Function(Widget, Animation<double>) _buildTransition(double x, double y) {
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