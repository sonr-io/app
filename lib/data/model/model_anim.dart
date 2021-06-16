import '../../style.dart';

/// Rive Board Options
enum RiveBoard { SplashPortrait, SplashLandscape, Documents }

/// Animated Bounce In Direction
enum BounceDirection { Left, Right, Up, Down }

extension BounceDirectionUtils on BounceDirection {
  /// Checks if Direction is `Left`
  bool get isLeft => this == BounceDirection.Left;

  /// Checks if Direction is `Right`
  bool get isRight => this == BounceDirection.Right;

  /// Checks if Direction is `Up`
  bool get isTop => this == BounceDirection.Up;

  /// Checks if Direction is `Down`
  bool get isDown => this == BounceDirection.Down;

  /// Returns In Animation for Widget based On Direction
  Widget inAnimation({required Widget child}) {
    // Initialize Parameters
    final duration = 350.milliseconds;
    final animate = true;
    final delay = 200.milliseconds;

    // Return Widget
    switch (this) {
      case BounceDirection.Left:
        return BounceInLeft(child: child, delay: delay, duration: duration, animate: animate);
      case BounceDirection.Right:
        return BounceInRight(child: child, delay: delay, duration: duration, animate: animate);
      case BounceDirection.Up:
        return BounceInUp(child: child, delay: delay, duration: duration, animate: animate);
      case BounceDirection.Down:
        return BounceInDown(child: child, delay: delay, duration: duration, animate: animate);
    }
  }

  /// Returns Out Animation for Widget based On Direction
  Widget outAnimation({required Widget child}) {
    // Initialize Parameters
    final duration = 200.milliseconds;
    final animate = true;

    // Return Widget
    switch (this) {
      case BounceDirection.Left:
        return FadeOutRight(child: child, animate: animate, duration: duration);
      case BounceDirection.Right:
        return FadeOutLeft(child: child, animate: animate, duration: duration);
      case BounceDirection.Up:
        return FadeOutDown(child: child, animate: animate, duration: duration);
      case BounceDirection.Down:
        return FadeOutUp(child: child, animate: animate, duration: duration);
    }
  }

  /// ### Initializer from Offest
  /// Returns Bounce Direction based on Offset
  static BounceDirection fromOffset({double? top, double? left, double? right, double? bottom}) {
    // Check Top
    if (top != null) {
      // Compare with Right
      if (right != null) {
        if (right > top) {
          return BounceDirection.Left;
        }
      }

      // Compare with Left
      if (left != null) {
        if (left > top) {
          return BounceDirection.Right;
        }
      }
      return BounceDirection.Down;
    }

    // Check Bottom
    else {
      // Compare with Right
      if (right != null) {
        if (right > bottom!) {
          return BounceDirection.Left;
        }
      }

      // Compare with Left
      if (left != null) {
        if (left > bottom!) {
          return BounceDirection.Right;
        }
      }
      return BounceDirection.Up;
    }
  }
}
