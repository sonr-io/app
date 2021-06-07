import 'package:sonr_app/style.dart';

class ShapeButton extends StatelessWidget {
  /// Function called on Tap Up
  final Function onPressed;

  /// Widget for Action Icon: Max Size 32
  final String path;

  /// String for Text Below Button
  final String label;

  final BoxFit fit;

  const ShapeButton({Key? key, required this.onPressed, required this.path, required this.label, this.fit = BoxFit.contain}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 150, maxWidth: 150),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ObxValue<RxBool>(
              (isPressed) => GestureDetector(
                  onTapDown: (details) => isPressed(true),
                  onTapCancel: () => isPressed(false),
                  onTapUp: (details) {
                    isPressed(false);
                    onPressed();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedScale(
                        scale: isPressed.value ? 1.0 : 0.9,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: SonrTheme.foregroundColor,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(24),
                        ),
                      ),
                      AnimatedScale(
                        scale: isPressed.value ? 1.1 : 1.0,
                        child: Container(
                          width: 100,
                          height: 100,
                          child: Image.asset(
                            path,
                            fit: fit,
                          ),
                        ),
                      )
                    ],
                  )),
              false.obs),

          // Build Label
          UserService.isDarkMode ? label.light(color: SonrColor.White.withOpacity(0.8)) : label.light(color: SonrColor.Black.withOpacity(0.8)),
        ],
      ),
    );
  }
}
