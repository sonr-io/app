import 'package:firebase_analytics/observer.dart';
import 'package:get/get.dart';
import 'package:sonr_app/style.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:feedback/feedback.dart';

/// @ Main Method
Future<void> main() async {
  // Init Services
  WidgetsFlutterBinding.ensureInitialized();
  await SonrServices.init();

  // Check Platform
  if (DeviceService.isMobile) {
    await SentryFlutter.init(
      Logger.sentryOptions,
      appRunner: () => runApp(BetterFeedback(child: App(isDesktop: false))),
    );
  } else {
    runApp(App(isDesktop: true));
  }
}

/// @ Root App Widget
class App extends StatelessWidget {
  final bool isDesktop;
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  const App({Key? key, required this.isDesktop}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      onInit: () => _checkInitialPage(),
      themeMode: ThemeMode.system,
      theme: SonrDesign.LightTheme,
      darkTheme: SonrDesign.DarkTheme,
      getPages: Route.pages,
      initialBinding: InitialBinding(),
      navigatorKey: Get.key,
      navigatorObservers: [
        GetObserver(),
        observer,
      ],
      title: _title(),
      home: _buildScaffold(),
    );
  }

  String _title() {
    if (isDesktop) {
      return "Sonr Desktop";
    }
    return "";
  }

  Widget _buildScaffold() {
    if (isDesktop) {
      return Scaffold(
          backgroundColor: Get.theme.backgroundColor,
          body: Stack(
            alignment: Alignment.topCenter,
            children: [
              // @ Rive Animation
              Center(
                child: CircularProgressIndicator(),
              ),

              // @ Fade Animation of Text
              Positioned(
                bottom: 100,
                child: FadeInUp(child: "Sonr".hero()),
              ),
            ],
          ));
    }
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            // @ Rive Animation
            RiveContainer(
              type: RiveBoard.SplashPortrait,
              width: Get.width,
              height: Get.height,
              placeholder: SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent))),
            ),

            // @ Fade Animation of Text
            Positioned(
              bottom: 100,
              child: FadeInUp(delay: 2222.milliseconds, child: "Sonr".hero()),
            ),
          ],
        ));
  }

  Future<void> _checkInitialPage() async {
    await Future.delayed(3500.milliseconds);

    // # Check for User
    if (!UserService.hasUser.value) {
      // Anonymous Desktop
      if (isDesktop) {
        // Get Contact from Values
        var contact = Contact(
            profile: Profile(
          firstName: "Anonymous",
          lastName: DeviceService.platform.toString(),
        ));

        // Create User
        await UserService.newUser(contact);

        // Connect to Network
        SonrService.to.connect();
        await Get.offNamed("/home");
      }
      // Register Mobile
      else {
        Get.offNamed("/register");
      }
    }
    // # Handle Returning
    else {
      // Check Platform
      if (!isDesktop) {
        // All Valid
        if (MobileService.hasLocation.value) {
          Get.offNamed("/home", arguments: HomeArguments(isFirstLoad: true));
        }

        // No Location
        else {
          MobileService.to.requestLocation().then((value) {
            if (value) {
              Get.offNamed("/home", arguments: HomeArguments(isFirstLoad: true));
            }
          });
        }
      } else {
        Get.offNamed("/home", arguments: HomeArguments(isFirstLoad: true));
      }
    }
  }
}
