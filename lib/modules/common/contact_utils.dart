import 'package:sonr_app/style.dart';
import 'package:sonr_app/style/buttons/utility.dart';

class ContactSName extends StatelessWidget {
  /// Widget for Action Icon: Max Size 32
  const ContactSName({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ObxValue<RxBool>(
        (isPressed) => GestureDetector(
              onTapDown: (details) => isPressed(true),
              onTapCancel: () => isPressed(false),
              onTapUp: (details) async {
                isPressed(false);
                await HapticFeedback.mediumImpact();
                Future.delayed(ButtonUtility.K_BUTTON_DURATION, () {
                  Clipboard.setData(ClipboardData(text: ContactService.contact.value.sName));
                  AppRoute.snack(
                      SnackArgs.alert(title: "Copied!", message: "SName copied to clipboard", icon: Icon(SonrIcons.Copy, color: Colors.white)));
                });
              },
              child: AnimatedScale(
                  scale: isPressed.value ? 1.1 : 1.0,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: ContactService.contact.value.sName.size(DisplayTextStyle.Light, fontSize: 24).width + 75),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 24,
                          width: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: SonrColor.Primary.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            SonrIcons.ATSign,
                            color: SonrTheme.itemColorInversed,
                            size: 18,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 4),
                          child: [
                            "${ContactService.contact.value.sName}".lightSpan(color: SonrTheme.itemColor, fontSize: 24),
                            ".snr/".lightSpan(color: SonrTheme.greyColor, fontSize: 24),
                          ].rich(),
                        ),
                      ],
                    ),
                  )),
            ),
        false.obs);
  }
}