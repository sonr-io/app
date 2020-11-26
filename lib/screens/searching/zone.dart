part of 'searching.dart';

// *************************** //
// ** Build Bubbles in List ** //
// *************************** //
class ZoneView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvailablePeers, List<Peer>>(
        cubit: context.getCubit(CubitType.Peers),
        builder: (context, state) {
          if (state.length > 0) {
            // Initialize Widget List
            List<Widget> stackWidgets = new List<Widget>();

            // Init Stack Vars
            int total = state.length + 1;
            int current = 0;
            double mean = 1.0 / total;

            // Create Bubbles
            for (Peer peer in state) {
              // Increase Count
              current += 1;

              // Place Bubble
              Widget bubble = new PeerBubble(current * mean, peer);
              stackWidgets.add(bubble);
            }
            // Return View
            return Stack(children: stackWidgets);
          }
          return Container();
        });
  }
}

Widget rangeLines() {
  // TODO: Add Device Size in Device Bloc
  // return Padding(
  //     padding: EdgeInsets.only(bottom: 5),
  //     child: CustomPaint(
  //       size: screenSize,
  //       painter: ZonePainter(),
  //       child: Container(),
  //     ));
}
