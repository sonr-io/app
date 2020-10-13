part of 'web_bloc.dart';

abstract class WebState extends Equatable {
  const WebState();
  @override
  List<Object> get props => [];
}

// ********************
// ** Preload State ***
// ********************
class Disconnected extends WebState {
  const Disconnected();
}

// ***************************
// ** Between Server Reads ***
// ***************************
class Loading extends WebState {
  const Loading();
}

// ***************************
// ** Active for Receiving ***
// ***************************
class Active extends WebState {
  const Active();
}

// *****************************************
// ** Searching for Peer Sender/Receiver ***
// *****************************************
class Searching extends WebState {
  final PathFinder pathfinder;
  const Searching({this.pathfinder});
}

// **********************************************
// ** After Request Pending Receiver Decision ***
// **********************************************
class Pending extends WebState {
  final Peer match;
  final Metadata fileMeta;
  final dynamic offer;

  const Pending({
    this.offer,
    this.match,
    this.fileMeta,
  });
}

// *********************************************
// ** In WebRTC Transfer or Contact Transfer ***
// *********************************************
class Transferring extends WebState {
  const Transferring();
}

// *************************
// ** Transfer Succesful ***
// *************************
class Completed extends WebState {
  // Sender/Receiver
  final String deviceStatus;
  final File file;

  const Completed(
    this.deviceStatus, {
    this.file,
  });
}

// *******************************************
// ** Post Authorization Receiver Declined ***
// *******************************************
class Failed extends WebState {
  const Failed();
}
