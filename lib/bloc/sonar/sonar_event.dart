import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:sonar_app/controllers/controllers.dart';
import 'package:sonar_app/models/models.dart';
import 'package:sonar_app/models/transfer.dart';

abstract class SonarEvent extends Equatable {
  const SonarEvent();

  @override
  List<Object> get props => [];
}

// *********************
// ** Single Events ****
// *********************
// Connect to WS, Join/Create Lobby
class Initialize extends SonarEvent {
  const Initialize();
}

// Send to Server Sequence
class Send extends SonarEvent {
  final Map matches;

  const Send(
      {
      this.matches});
}

// Receive to Server Sequence
class Receive extends SonarEvent {
  final Map matches;

  const Receive(
      {this.matches});
}

// Tap Peer from List or Point to Receiver for 2s
class Select extends SonarEvent {
  final Client match;

    const Select(
      {
      @required this.match});
}

// Sender Requests Authorization
class Request extends SonarEvent {
  final Client match;

    const Request(
      {
      @required this.match});
}

// Receiver Offerred Sonar Transfer
class Offered extends SonarEvent {
  final bool decision;
  final Client sender;

  const Offered({@required this.sender, @required this.decision});
}

// Authentication Success
class StartTransfer extends SonarEvent {
  final Transfer transfer;

  const StartTransfer({@required this.transfer});
}

// Transfer Complete
class CompleteTransfer extends SonarEvent {
  final Transfer transfer;

  const CompleteTransfer({@required this.transfer});
}

// Cancel on Button Tap
class CancelSonar extends SonarEvent {
  const CancelSonar();
}

// On Cancel, On Done, On Zero
class ResetSonar extends SonarEvent {
  const ResetSonar();
}