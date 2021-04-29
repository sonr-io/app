import 'package:flutter/material.dart';
import 'data/data.dart';
import 'package:sonr_app/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SonrRouting.initServices(isDesktop: true);
  runApp(DesktopApp());
}

class DesktopApp extends StatefulWidget {
  const DesktopApp({Key key}) : super(key: key);

  @override
  _DesktopAppState createState() => _DesktopAppState();
}

class _DesktopAppState extends State<DesktopApp> {
  @override
  void initState() {
    super.initState();

    // Shift Page
    DeviceService.shiftPage(delay: 3.seconds);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: SonrRouting.pages,
      initialBinding: InitialBinding(),
      title: 'Sonr Desktop',
      navigatorKey: Get.key,
      navigatorObservers: [GetObserver()],
      themeMode: UserService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            alignment: Alignment.topCenter,
            children: [
              // @ Rive Animation
              RiveContainer(
                type: RiveBoard.Splash,
                width: Get.width,
                height: Get.height,
                placeholder: SizedBox(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent))),
              ),

              // @ Fade Animation of Text
              Positioned(
                bottom: 100,
                child: OpacityAnimatedWidget(enabled: true, duration: 350.milliseconds, delay: 2222.milliseconds, child: "Sonr".hero),
              ),
            ],
          )),
    );
  }
}