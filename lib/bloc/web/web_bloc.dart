import 'package:sonar_app/bloc/bloc.dart';
import 'package:sonar_app/models/models.dart';
import 'package:sonar_app/repository/repository.dart';
import 'package:sonar_app/core/core.dart';
import 'package:equatable/equatable.dart';

part 'web_event.dart';
part 'web_state.dart';

// ***********************
// ** Sonar Bloc Class ***
// ***********************
class WebBloc extends Bloc<WebEvent, WebState> {
  // Data Providers
  StreamSubscription directionSubscription;

  // Required Blocs
  final DataBloc data;
  final DeviceBloc device;
  final UserBloc user;
  Peer _node;

  // Initial State
  WebState get initialState => Disconnected();

  // On Bloc Close
  void dispose() {
    directionSubscription.cancel();
  }

  // Constructer
  WebBloc(this.data, this.device, this.user) : super(null) {
    // Initialize Objects
    _node = user.node;

    // ** SocketClient Event Subscription ** //
    // -- USER CONNECTED TO SOCKET SERVER --
    socket.on('CONNECTED', (data) {
      // Log Event
      log.i("CONNECTED");

      // Update Status
      add(Update(Status.Active));
    });

    // -- UPDATE TO A NODE IN LOBBY --
    socket.on('UPDATED', (data) {
      // Log Event
      log.i("UPDATED: " + data.toString());

      // Get Peer
      Peer peer = Peer.fromMap(data["from"]);

      // Update Graph
      _node.updateGraph(peer);
    });

    // -- NODE EXITED LOBBY --
    socket.on('EXITED', (data) {
      // Log Event
      log.i("EXITED: " + data.toString());

      // Get Peer
      Peer peer = Peer.fromMap(data["from"]);

      // Update Graph
      _node.exitGraph(peer);
    });

    // -- OFFER REQUEST --
    socket.on('OFFERED', (data) {
      // Log Event
      log.i("OFFERED: " + data.toString());

      // Set Status
      _node.status = Status.Requested;

      // Handle Offer
      _node.handleOffer(data);
    });

    // -- MATCH ACCEPTED REQUEST --
    socket.on('ANSWERED', (data) {
      // Log Event
      log.i("ANSWERED: " + data.toString());

      // Set Status
      _node.status = Status.Transferring;

      // Handle Answer
      _node.handleAnswer(data);
    });

    // -- MATCH DECLINED REQUEST --
    socket.on('DECLINED', (data) {
      // Log Event
      log.i("DECLINED: " + data.toString());
    });

    // -- MATCH ICE CANDIDATES --
    socket.on('CANDIDATE', (data) {
      // Log Event
      log.i("CANDIDATE: " + data.toString());

      // Handle Candidate
      _node.handleCandidate(data);
    });

    // -- MATCH RECEIVED FILE --
    socket.on('COMPLETED', (data) {
      // Log Event
      log.i("COMPLETED: " + data.toString());
    });

    // -- ERROR OCCURRED (Cancelled, Internal) --
    socket.on('ERROR', (error) {
      // Log Event
      log.e("ERROR: " + data.toString());
    });

    // ** Device BLoC Subscription ** //
    directionSubscription = device.directionCubit.listen((direction) {
      // Check Diff Direction
      if (direction != _node.direction && this.state is! Loading) {
        // Device is Searching
        if (this.state is Searching) {
          add(Update(Status.Searching));
        }
        // Send with 500ms delay
        else if (this.state is Available) {
          add(Update(Status.Active));
        }
        _node.direction = direction;
      }
    });
  }

// *********************************
// ** Map Events to State Method ***
// *********************************
  @override
  Stream<WebState> mapEventToState(
    WebEvent event,
  ) async* {
    if (event is Connect) {
      yield* _mapConnectToState(event);
    } else if (event is Load) {
      yield* _mapLoadToState(event);
    } else if (event is Update) {
      yield* _mapUpdateToState(event);
    } else if (event is Authorize) {
      yield* _mapAuthorizeToState(event);
    } else if (event is End) {
      yield* _mapEndToState(event);
    }
  }

// ********************
// ** Connect Event ***
// ********************
  Stream<WebState> _mapConnectToState(Connect event) async* {
    // Check if Peer Node exists
    if (_node != null) {
      // Emit Peer Node
      _node.send(OutgoingEvent.CONNECT);

      // Device Pending State
      add(Load());
    }
    // No Peer Node in User Bloc
    else {
      log.e("Node Data not provided for WebBloc:Connect Event");
      yield Disconnected();
    }
  }

// *****************
// ** Load Event ***
// *****************
  Stream<WebState> _mapLoadToState(Load event) async* {
    // Device Pending State
    yield Loading();
  }

// *******************
// ** Update Event ***
// *******************
  Stream<WebState> _mapUpdateToState(Update event) async* {
    // Update Status
    _node.status = event.newStatus;

    // Emit to Server
    _node.send(OutgoingEvent.UPDATE);

    // Action by Status
    switch (_node.status) {
      case Status.Disconnected:
        yield Disconnected();
        break;
      case Status.Active:
        yield Available(_node);
        break;
      case Status.Searching:
        yield Searching(_node);
        break;
      case Status.Pending:
        yield Pending();
        break;
      case Status.Requested:
        yield Requested();
        break;
      case Status.Transferring:
        yield Transferring();
        break;
    }
  }

// **********************
// ** Authorize Event ***
// **********************
  Stream<WebState> _mapAuthorizeToState(Authorize event) async* {
    // User Agreed
    if (event.decision) {
      await _node.createAnswer(event.match.id, event.peerConnection);
    }
    // User Declined
    else {
      _node.send(OutgoingEvent.DECLINE);
    }
  }

// *******************************************
// ** End Event: Cancel/Complete/Exit/Fail ***
// *******************************************
  Stream<WebState> _mapEndToState(End event) async* {
    // TODO: Check Reset Connection
    //socket.emit("RESET");

    // TODO: Check Reset RTC Session
    //session.close();

    // Action By Type
    switch (event.type) {
      // ** Cancel in Transfer **
      case EndType.Cancel:
        log.i("Cancelled");
        break;

      // ** Transfer is Finished **
      case EndType.Complete:
        // Reset Node
        _node.status = Status.Active;

        // Set Delay
        await new Future.delayed(Duration(seconds: 1));

        // Yield Ready
        yield Completed(_node);
        break;

      // ** Exit Graph **
      case EndType.Exit:
        log.i("Exited");
        break;

      // ** Internal Fail **
      case EndType.Fail:
        // Set Delay
        await new Future.delayed(Duration(seconds: 1));

        // Yield Ready
        yield Failed();
        break;
    }
  }
}
