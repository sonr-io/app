import 'dart:ui';
import 'package:sonr_app/theme/theme.dart';

// ^ Standardized Uniform Scaffold ^ //
class SonrScaffold extends StatelessWidget {
  final Widget body;
  final Widget bottomSheet;
  final Widget floatingActionButton;
  final Widget bottomNavigationBar;
  final Widget shareView;
  final PreferredSizeWidget appBar;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  final bool resizeToAvoidBottomInset;
  final Function bodyAction;
  final FlutterGradientNames gradientName;

  SonrScaffold({
    Key key,
    this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset,
    this.bodyAction,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.shareView,
    this.gradientName = FlutterGradientNames.northMiracle,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PageBackground(
      gradientName: gradientName,
      scaffold: NeumorphicTheme(
        themeMode: UserService.isDarkMode ? ThemeMode.dark : ThemeMode.light, //or dark / system
        darkTheme: NeumorphicThemeData(
          defaultTextColor: Colors.white,
          baseColor: SonrColor.Black,
          lightSource: LightSource.topLeft,
        ),
        theme: NeumorphicThemeData(
          defaultTextColor: SonrColor.Black,
          baseColor: SonrColor.White,
          lightSource: LightSource.topLeft,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          body: body,
          appBar: appBar,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: shareView,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          bottomSheet: bottomSheet,
        ),
      ),
    );
  }
}

class PageBackground extends StatelessWidget {
  final Widget scaffold;
  final FlutterGradientNames gradientName;
  const PageBackground({Key key, this.scaffold, this.gradientName}) : super(key: key);
  @override
  Widget build(Object context) {
    return NeumorphicBackground(
      backendColor: Colors.transparent,
      child: Stack(
        children: [
          // Gradient
          _BackgroundGradient(gradientName: gradientName),

          // Overlay Color
          _BackgroundOverlay(),

          // Blue
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.1188, sigmaY: 5.1188),
            child: Container(width: Get.width, height: Get.height),
          ),
          scaffold
        ],
      ),
    );
  }
}

// ^ Animated Background Gradient ^ //
class _BackgroundGradient extends StatelessWidget {
  final FlutterGradientNames gradientName;
  const _BackgroundGradient({Key key, this.gradientName}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (gradientName != FlutterGradientNames.northMiracle) {
      return CustomAnimatedWidget(
          enabled: true,
          duration: Duration(seconds: 4),
          curve: Curves.easeOut,
          builder: (context, percent) {
            return Container(
              height: Get.height,
              width: Get.width,
              decoration: BoxDecoration(
                color: UserService.isDarkMode ? SonrColor.Black : SonrColor.White,
                gradient: FlutterGradients.northMiracle(type: GradientType.radial, center: Alignment.topLeft, radius: 2.5)
                    // ignore: invalid_use_of_protected_member
                    .lerpTo(FlutterGradients.findByName(gradientName), percent),
              ),
            );
          });
    } else {
      return Opacity(
        opacity: 0.5,
        child: Container(
          height: Get.height,
          width: Get.width,
          decoration: BoxDecoration(
            color: UserService.isDarkMode ? SonrColor.Black : SonrColor.White,
            gradient: FlutterGradients.northMiracle(type: GradientType.radial, center: Alignment.topLeft, radius: 2.5),
          ),
        ),
      );
    }
  }
}

class _BackgroundOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UserService.isDarkMode
        ? Container(
            height: Get.height,
            width: Get.width,
            color: SonrColor.Black.withOpacity(0.75),
          )
        : Container(
            height: Get.height,
            width: Get.width,
            color: SonrColor.White.withOpacity(0.75),
          );
  }
}
