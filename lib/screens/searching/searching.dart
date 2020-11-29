import 'package:sonar_app/screens/screens.dart';
import 'package:sonr_core/sonr_core.dart';
import 'bubble/bubble.dart';
import 'compass/compass.dart';

class SearchingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = NeumorphicTheme.currentTheme(context);
    // Return Widget
    return AppTheme(Scaffold(
        appBar: exitAppBar(context, Icons.close, onPressed: () {
          Get.offAllNamed("/home");
        }),
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: SafeArea(
            child: Stack(
          children: <Widget>[
            // @ Range Lines
            Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: CustomPaint(
                  size: Size(Get.width, Get.height),
                  painter: ZonePainter(),
                  child: Container(),
                )),

            // @ Bubble View
            BlocBuilder<LobbyCubit, Lobby>(
                cubit: context.getCubit(CubitType.Lobby),
                builder: (context, state) {
                  if (state.peers.length > 0) {
                    // Initialize Widget List
                    List<Widget> stackWidgets = new List<Widget>();

                    // Init Stack Vars
                    int total = state.peers.length + 1;
                    int current = 0;
                    double mean = 1.0 / total;

                    // Create Bubbles
                    state.peers.values.forEach((peer) {
                      // Increase Count
                      current += 1;

                      // Place Bubble
                      Widget bubble = new PeerBubble(current * mean, peer);
                      stackWidgets.add(bubble);
                    });

                    // Return View
                    return Stack(children: stackWidgets);
                  }
                  return Container();
                }),

            // @ Have BLoC Builder Retrieve Directly from Compass
            BlocBuilder<DirectionCubit, double>(
                cubit: context.getCubit(CubitType.Direction),
                builder: (context, state) {
                  return Align(
                      alignment: Alignment.bottomCenter,
                      child: CompassView(direction: state));
                })
          ],
        ))));
  }
}
