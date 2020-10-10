part of 'transfer.dart';

class SendingView extends StatefulWidget {
  final PathFinder pathfinder;
  final UserBloc user;

  SendingView({this.pathfinder, this.user});

  @override
  _SendingViewState createState() => _SendingViewState();
}

class _SendingViewState extends State<SendingView> {
  @override
  Widget build(BuildContext context) {
    //if (!pathfinder.isEmpty) {
    // Get Closest Peer
    //Peer closest = pathfinder.getClosestNeighbor();

    return SafeArea(
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Flexible(child: CompassView()),
          ),
        ],
      ),
    );
  }
}
