import 'package:introduction_screen/introduction_screen.dart';
import 'package:sonr_app/style.dart';

enum IntroPageType {
  Welcome,
  Universal,
  Secure,
  Start,
}

extension IntroPanelTypeUtils on IntroPageType {
  /// Returns Total Panels
  int get total => IntroPageType.values.length;

  /// Returns this Panels Index
  int get index => IntroPageType.values.indexOf(this);

  /// Returns this InfoPanels page value
  double get page => this.index.toDouble();

  /// Return Next Info Panel
  IntroPageType get next => IntroPageType.values[this.index + 1];

  /// Return Previous Info Panel
  IntroPageType get previous => IntroPageType.values[this.index - 1];

  /// Checks if this Panel is First Panel
  bool get isFirst => this.index == 0;

  /// Checks if this Panel is NOT First Panel
  bool get isNotFirst => this.index != 0;

  /// Checks if this Panel is Last Panel
  bool get isLast => this.index + 1 == this.total;

  /// Checks if this Panel is NOT Last Panel
  bool get isNotLast => this.index + 1 != this.total;

  /// Return Page Decoration for Type
  PageDecoration get pageDecoration {
    return PageDecoration(
      titlePadding: EdgeInsets.only(top: 64.0, bottom: 24.0),
    );
  }

  /// Return Image Path for Type
  String get imagePath {
    final basePath = "assets/illustrations/";
    switch (this) {
      case IntroPageType.Welcome:
        return basePath + "Welcome.png";
      case IntroPageType.Universal:
        return basePath + "Universal.png";
      case IntroPageType.Secure:
        return basePath + "Secure.png";
      case IntroPageType.Start:
        return basePath + "Start.png";
    }
  }

  /// Returns Decoration for Container Around Image
  BoxDecoration get imageDecoration {
    switch (this) {
      case IntroPageType.Welcome:
        return BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: SonrColor.Black,
              width: 2,
            ));
      case IntroPageType.Universal:
        return BoxDecoration();
      case IntroPageType.Secure:
        return BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: SonrColor.Black,
              width: 2,
            ));
      case IntroPageType.Start:
        return BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: SonrColor.Black.withOpacity(0.4),
              width: 2,
            ));
    }
  }

  /// Returns This Panels Page View Model
  PageViewModel pageViewModel() {
    return PageViewModel(
      decoration: this.pageDecoration,
      titleWidget: SlideInUp(
        animate: this.isFirst,
        child: this.title(),
        delay: 50.milliseconds,
        duration: 300.milliseconds,
      ),
      bodyWidget: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: SlideInUp(
          animate: this.isFirst,
          child: this.description(),
          duration: 300.milliseconds,
          delay: 250.milliseconds,
        ),
      ),
      image: Center(
          child: FadeIn(
        delay: 150.milliseconds,
        child: Container(
          margin: EdgeInsets.only(top: 72),
          decoration: this.imageDecoration,
          child: Image.asset(this.imagePath, height: 200.0, fit: BoxFit.fitHeight),
          padding: EdgeInsets.all(42),
        ),
      )),
    );
  }

  /// Returns this Panels Title as Heading Widget
  Widget title() {
    final color = SonrColor.Black;
    switch (this) {
      case IntroPageType.Welcome:
        return 'Welcome'.heading(color: color, fontSize: 36);
      case IntroPageType.Universal:
        return 'Universal'.heading(color: color, fontSize: 36);
      case IntroPageType.Secure:
        return 'Security First'.heading(color: color, fontSize: 36);
      case IntroPageType.Start:
        return 'Get Started'.heading(color: color, fontSize: 36);
    }
  }

  /// Returns this Panels Description as Rich Text
  Widget description() {
    final color = SonrColor.Grey;
    final size = 20.0;
    switch (this) {
      case IntroPageType.Welcome:
        return [
          'Sonr has '.lightSpan(fontSize: size, color: color),
          'NO '.subheadingSpan(fontSize: size, color: color),
          'File Size Limits. Works like Airdrop Nearby and like Email when nobody is around.'.lightSpan(
            fontSize: size,
            color: color,
          )
        ].rich();
      case IntroPageType.Universal:
        return ['Runs Natively on iOS, Android, MacOS, Windows and Linux.'.lightSpan(fontSize: size, color: color)].rich();
      case IntroPageType.Secure:
        return ['Completely Encrypted Communication. All data is verified and signed.'.lightSpan(fontSize: size, color: color)].rich();
      case IntroPageType.Start:
        return ['Lets Continue by selecting your Sonr Name.'.lightSpan(fontSize: size, color: color)].rich();
    }
  }
}
