import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:flutter_sensor_compass/flutter_sensor_compass.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:logger/logger.dart';
import 'package:sensors/sensors.dart';
import 'package:sonar_app/models/models.dart';
import 'package:soundpool/soundpool.dart';
import '../bloc.dart';
import 'package:sonar_app/core/core.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

// *********************
// ** Initialization ***
// *********************
Socket socket = io('http://match.sonr.io', <String, dynamic>{
  'transports': ['websocket'],
});

var logger = Logger();

class SonarBloc extends Bloc<SonarEvent, SonarState> {
  // Data Provider
  Direction _lastDirection;
  Motion _currentMotion = Motion.create();
  Circle _circle = new Circle();
  Soundpool _soundpool = new Soundpool(streamType: StreamType.music);

  // Transfer Variables
  bool initialized = false;
  bool requested = false;
  bool offered = false;
  dynamic _fileData;
  dynamic _profileData;

  // WebRTC
  RTCPeerConnection _peerConnection;
  bool _inCalling = false;

  RTCDataChannelInit _dataChannelDict = null;
  RTCDataChannel _dataChannel;

  String _sdp;

  // Constructer
  SonarBloc() {
    // ** SOCKET::Connected **
    socket.on('connect', (_) {
      logger.v("Connected to Socket");
    });

    // ** SOCKET::INFO **
    socket.on('INFO', (data) {
      add(Refresh(newDirection: _lastDirection));
      // Add to Process
      logger.v("Lobby Id: " + data);
    });

    // ** SOCKET::NEW_SENDER **
    socket.on('NEW_SENDER', (data) {
      // Send Last Recorded Direction to New Sender
      socket.emit("RECEIVING", [_lastDirection.toReceiveMap()]);
      add(Refresh(newDirection: _lastDirection));
      // Add to Process
      logger.i("NEW_SENDER: " + data);
    });

    // ** SOCKET::SENDER_UPDATE **
    socket.on('SENDER_UPDATE', (data) {
      _circle.update(_lastDirection, data);
      add(Refresh(newDirection: _lastDirection));
    });

    // ** SOCKET::SENDER_EXIT **
    socket.on('SENDER_EXIT', (id) {
      // Remove Sender from Circle
      _circle.exit(id);
      add(Refresh(newDirection: _lastDirection));

      // Add to Process
      logger.w("SENDER_EXIT: " + id);
    });

    // ** SOCKET::NEW_RECEIVER **
    socket.on('NEW_RECEIVER', (data) {
      // Send Last Recorded Direction to New Receiver
      socket.emit("SENDING", [_lastDirection.toReceiveMap()]);
      add(Refresh(newDirection: _lastDirection));

      // Add to Process
      logger.i("NEW_RECEIVER: " + data);
    });

    // ** SOCKET::RECEIVER_UPDATE **
    socket.on('RECEIVER_UPDATE', (data) {
      //print("RECEIVER_UPDATE: " + data.toString());
      _circle.update(_lastDirection, data);
      add(Refresh(newDirection: _lastDirection));
    });

    // ** SOCKET::RECEIVER_EXIT **
    socket.on('RECEIVER_EXIT', (id) {
      // Remove Receiver from Circle
      _circle.exit(id);
      add(Refresh(newDirection: _lastDirection));

      // Add to Process
      logger.w("RECEIVER_EXIT: " + id);
    });

    // ** SOCKET::SENDER_OFFERED **
    socket.on('SENDER_OFFERED', (data) {
      logger.i("SENDER_OFFERED: " + data.toString());

      _profileData = data[0];
      _fileData = data[1];

      // Remove Sender from Circle
      add(Offered(profileData: _circle.closest(), fileData: data[1]));

      // Add to Process
    });

    // ** SOCKET::RECEIVER_AUTHORIZED **
    socket.on('RECEIVER_AUTHORIZED', (data) {
      dynamic matchId = data[0];

      add(Accepted(_circle.closest(), matchId));
      // Add to Process
      logger.i("RECEIVER_AUTHORIZED: " + data.toString());
    });

    // ** SOCKET::RECEIVER_DECLINED **
    socket.on('RECEIVER_DECLINED', (data) {
      dynamic matchId = data[0];

      add(Declined(_circle.closest(), matchId));
      // Add to Process
      logger.w("RECEIVER_DECLINED: " + data.toString());
    });

    // ** SOCKET::RECEIVER_COMPLETED **
    socket.on('RECEIVER_COMPLETED', (data) {
      dynamic matchId = data[0];

      add(Completed(_circle.closest(), matchId));
      // Add to Process
      logger.i("RECEIVER_COMPLETED: " + data.toString());
    });

    // ** SOCKET::TRANSFERRED**
    socket.on('SENDER_TRANSFERRED', (data) async {
      dynamic type = data[0];
      dynamic file = data[1].cast<int>();

      Uint8List outputAsUint8List = new Uint8List.fromList(file);
      add(Received(type, outputAsUint8List));

      logger.i("SENDER_TRANSFERRED: " +
          type.toString() +
          " fileData: " +
          file.toString());
    });

    // ** SOCKET::ERROR **
    socket.on('ERROR', (error) {
      // Add to Process
      logger.e("ERROR: " + error);
    });

    // ** Accelerometer Events **
    accelerometerEvents.listen((newData) {
      // Update Motion Var
      _currentMotion = Motion.create(a: newData);
    });

    // ** Directional Events **
    Compass()
        .compassUpdates(interval: Duration(milliseconds: 300))
        .listen((newData) {
      // Check Status
      if (!offered && !requested) {
        // Initialize Direction
        var newDirection = Direction.create(
            degrees: newData, accelerometerX: _currentMotion.accelX);

        // Check Sender Threshold
        if (_currentMotion.state == Orientation.Tilt) {
          // Set Sender
          _circle.status = "Sender";

          // Check Valid
          if (_lastDirection != null) {
            // Generate Difference
            var difference = newDirection.degrees - _lastDirection.degrees;

            // Threshold
            if (difference.abs() > 5) {
              // Modify Circle
              _circle.modify(newDirection);

              // Refresh Inputs
              add(Refresh(newDirection: newDirection));
            }
          }
          add(Refresh(newDirection: newDirection));
        }
        // Check Receiver Threshold
        else if (_currentMotion.state == Orientation.LandscapeLeft ||
            _currentMotion.state == Orientation.LandscapeRight) {
          // Set Receiver
          _circle.status = "Receiver";

          // Check Valid
          if (_lastDirection != null) {
            // Generate Difference
            var difference = newDirection.degrees - _lastDirection.degrees;
            if (difference.abs() > 10) {
              // Modify Circle
              _circle.modify(newDirection);
              // Refresh Inputs
              add(Refresh(newDirection: newDirection));
            }
          }
          add(Refresh(newDirection: newDirection));
        }
      }
    });
  }

  // Initial State
  @override
  SonarState get initialState => Initial();
// *********************************
// ** Map Events to State Method ***
// *********************************
  @override
  Stream<SonarState> mapEventToState(
    SonarEvent event,
  ) async* {
    // Device Can See Updates
    if (event is Initialize) {
      yield* _mapInitializeToState(event, _lastDirection, _currentMotion);
    } else if (event is Send) {
      yield* _mapSendToState(event, _lastDirection, _currentMotion);
    } else if (event is Receive) {
      yield* _mapReceiveToState(event, _lastDirection, _currentMotion);
    } else if (event is Update) {
      yield* _mapUpdateToState(event, _lastDirection, _currentMotion);
    } else if (event is Refresh) {
      yield* _mapRefreshInputToState(event);
    } else if (event is Request) {
      yield* _mapRequestToState(event);
    } else if (event is Offered) {
      yield* _mapOfferedToState(event);
    } else if (event is Authorize) {
      yield* _mapAuthorizeToState(event);
    } else if (event is Accepted) {
      yield* _mapAcceptedToState(event);
    } else if (event is Declined) {
      yield* _mapDeclinedToState(event);
    } else if (event is Transfer) {
      yield* _mapTransferToState(event);
    } else if (event is Received) {
      yield* _mapReceivedToState(event);
    } else if (event is Completed) {
      yield* _mapCompletedToState(event);
    } else if (event is Reset) {
      yield* _mapResetToState(event);
    }
  }

// ***********************
// ** Initialize Event ***
// ***********************
  Stream<SonarState> _mapInitializeToState(
      Initialize initializeEvent, Direction direction, Motion motion) async* {
    // Check Status
    if (!initialized) {
// Initialize Variables
      Location fakeLocation = Location.fakeLocation();
      _makeCall();

      // Emit to Socket.io
      socket.emit("INITIALIZE",
          [fakeLocation.toMap(), initializeEvent.userProfile.toMap()]);
      initialized = true;

      // Device Pending State
      yield Ready();
    }
  }

// *****************
// ** Send Event ***
// *****************
  Stream<SonarState> _mapSendToState(
      Send sendEvent, Direction direction, Motion motion) async* {
    // Check Init Status
    if (initialized && !requested) {
      // Emit Send
      const delay = const Duration(milliseconds: 500);
      new Timer(
          delay,
          () => {
                socket.emit("SENDING", [_lastDirection.toSendMap()])
              });
    }

    // Set Suspend state with lastState
    if (sendEvent.map != null) {
      yield Sending(
          matches: sendEvent.map,
          currentMotion: motion,
          currentDirection: _lastDirection);
    } else {
      yield Sending(currentMotion: motion, currentDirection: _lastDirection);
    }
  }

// ********************
// ** Receive Event ***
// ********************
  Stream<SonarState> _mapReceiveToState(
      Receive receiveEvent, Direction direction, Motion motion) async* {
    // Check Init Status
    if (initialized && !offered) {
      const delay = const Duration(milliseconds: 750);
      new Timer(
          delay,
          () => {
                // Emit Receive
                socket.emit("RECEIVING", [_lastDirection.toReceiveMap()])
              });
    }

    // Set Suspend state with lastState
    if (receiveEvent.map != null) {
      yield Receiving(
          matches: receiveEvent.map,
          currentMotion: motion,
          currentDirection: _lastDirection);
    } else {
      yield Receiving(currentMotion: motion, currentDirection: _lastDirection);
    }
  }

// ***********************
// ** Request Event ***
// ***********************
  Stream<SonarState> _mapRequestToState(Request requestEvent) async* {
    // Check Status
    if (initialized && !requested) {
      var dummyFileData = {"type": "Image", "size": 20};
      // Emit to Socket.io
      socket.emit("REQUEST", [requestEvent.id, dummyFileData]);
      requested = true;

      // Device Pending State
      yield Pending("SENDER", match: _circle.closest());
    }
  }

// ***********************
// ** Offered Event ***
// ***********************
  Stream<SonarState> _mapOfferedToState(Offered offeredEvent) async* {
    // Check Status
    if (initialized & !offered) {
      // Set Offered
      offered = true;

      // Device Pending State
      yield Pending("RECEIVER",
          match: offeredEvent.profileData, file: offeredEvent.fileData);
    }
  }

// **********************
// ** Authorize Event ***
// **********************
  Stream<SonarState> _mapAuthorizeToState(Authorize authorizeEvent) async* {
    // Check Status
    if (initialized) {
      // Send To Server
      socket
          .emit("AUTHORIZE", [authorizeEvent.matchId, authorizeEvent.decision]);

      // Yield Receiver Decision
      if (authorizeEvent.decision) {
        yield Transferring();
      }
      // Receiver Declined
      else {
        add(Reset(0));
      }
    }
  }

// **********************
// ** Accepted Event ***
// **********************
  Stream<SonarState> _mapAcceptedToState(Accepted acceptedEvent) async* {
    // Check Status
    if (initialized) {
      // Emit Decision to Server
      yield PreTransfer(
          profile: acceptedEvent.profile, matchId: acceptedEvent.matchId);
    }
  }

// **********************
// ** Declined Event ***
// **********************
  Stream<SonarState> _mapDeclinedToState(Declined declinedEvent) async* {
    // Check Status
    if (initialized) {
      // Emit Decision to Server
      yield Failed(
          profile: declinedEvent.profile, matchId: declinedEvent.matchId);
    }
  }

// *********************
// ** Transfer Event ***
// *********************
  Stream<SonarState> _mapTransferToState(Transfer transferEvent) async* {
    // Check Status
    if (initialized) {
      // Audio as bytes
      ByteData asset = await rootBundle.load('assets/audio/truck.mp3');
      socket.emit("TRANSFER",
          ["AUDIO", _circle.closest()["id"], asset.buffer.asUint8List()]);
      // Emit Decision to Server
      yield Transferring();
    }
  }

// *********************
// ** Received Event ***
// *********************
  Stream<SonarState> _mapReceivedToState(Received receivedEvent) async* {
    // Check Status
    if (initialized) {
      // Read Data
      var buffer = receivedEvent.file.buffer;
      var bdata = new ByteData.view(buffer);
      int soundId = await _soundpool.load(bdata);
      _soundpool.play(soundId);

      // Emit Completed
      socket.emit(
          "COMPLETE", [_circle.closest()["id"], _circle.closest()["profile"]]);

      // Emit Decision to Server
      yield Complete();
    }
  }

// *********************
// ** Completed Event ***
// *********************
  Stream<SonarState> _mapCompletedToState(Completed completedEvent) async* {
    // Check Status
    if (initialized) {
      // Emit Decision to Server
      yield Complete();
    }
  }

// *********************
// ** Reset Event ***
// *********************
  Stream<SonarState> _mapResetToState(Reset resetEvent) async* {
    // Check Status
    if (initialized) {
      // Reset Vars
      offered = false;
      requested = false;

      // Reset circle
      socket.emit("RESET");
      _circle.status = "Default";

      // Set Delay
      await new Future.delayed(Duration(seconds: resetEvent.secondDelay));

      // Yield Ready
      yield Ready();
    } else {
      add(Initialize());
    }
  }

  _makeCall() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };

    final Map<String, dynamic> offer_sdp_constraints = {
      "mandatory": {
        "OfferToReceiveAudio": false,
        "OfferToReceiveVideo": false,
      },
      "optional": [],
    };

    final Map<String, dynamic> loopback_constraints = {
      "mandatory": {},
      "optional": [
        {"DtlsSrtpKeyAgreement": true},
      ],
    };

    if (_peerConnection != null) return;

    try {
      _peerConnection =
          await createPeerConnection(configuration, loopback_constraints);

      _peerConnection.onSignalingState = _onSignalingState;
      _peerConnection.onIceGatheringState = _onIceGatheringState;
      _peerConnection.onIceConnectionState = _onIceConnectionState;
      _peerConnection.onIceCandidate = _onCandidate;
      _peerConnection.onRenegotiationNeeded = _onRenegotiationNeeded;

      _dataChannelDict = new RTCDataChannelInit();
      _dataChannelDict.id = 1;
      _dataChannelDict.ordered = true;
      _dataChannelDict.maxRetransmitTime = -1;
      _dataChannelDict.maxRetransmits = -1;
      _dataChannelDict.protocol = "sctp";
      _dataChannelDict.negotiated = false;

      _dataChannel = await _peerConnection.createDataChannel(
          'dataChannel', _dataChannelDict);
      _peerConnection.onDataChannel = _onDataChannel;

      RTCSessionDescription description =
          await _peerConnection.createOffer(offer_sdp_constraints);
      print(description.sdp);
      _peerConnection.setLocalDescription(description);

      _sdp = description.sdp;
      //change for loopback.
      description.type = 'answer';
      _peerConnection.setRemoteDescription(description);
    } catch (e) {
      print(e.toString());
    }
    _inCalling = true;
  }

  _hangUp() async {
    try {
      await _dataChannel.close();
      await _peerConnection.close();
      _peerConnection = null;
    } catch (e) {
      print(e.toString());
    }
    _inCalling = false;
  }

  _onSignalingState(RTCSignalingState state) {
    print(state);
  }

  _onIceGatheringState(RTCIceGatheringState state) {
    print(state);
  }

  _onIceConnectionState(RTCIceConnectionState state) {
    print(state);
  }

  _onCandidate(RTCIceCandidate candidate) {
    print('onCandidate: ' + candidate.candidate);
    _peerConnection.addCandidate(candidate);
    _sdp += candidate.candidate;
  }

  _onRenegotiationNeeded() {
    print('RenegotiationNeeded');
  }

  _onDataChannel(RTCDataChannel dataChannel) {}

// ********************
// ** Update Event ***
// ********************
  Stream<SonarState> _mapUpdateToState(
      Update updateEvent, Direction direction, Motion motion) async* {
    if (updateEvent.map.status == "Sender") {
      add(Send(map: updateEvent.map));
    } else {
      add(Receive(map: updateEvent.map));
    }
    yield Loading();
  }

// **************************
// ** Refresh Input Event ***
// **************************
  Stream<SonarState> _mapRefreshInputToState(Refresh updateSensors) async* {
// Check Status
    if (!offered && !requested) {
      // Check State
      if (_currentMotion.state == Orientation.Tilt ||
          _currentMotion.state == Orientation.LandscapeLeft ||
          _currentMotion.state == Orientation.LandscapeRight) {
        // Check Directions
        if (_lastDirection != updateSensors.newDirection) {
          // Set as new direction
          _lastDirection = updateSensors.newDirection;
        }
        // Check State
        if (_currentMotion.state == Orientation.Tilt) {
          // Post Update
          add(Update(
              currentDirection: _lastDirection,
              currentMotion: _currentMotion,
              map: _circle));
        }
        // Receive State
        else if (_currentMotion.state == Orientation.LandscapeLeft ||
            _currentMotion.state == Orientation.LandscapeRight) {
          // Post Update
          add(Update(
              currentDirection: _lastDirection,
              currentMotion: _currentMotion,
              map: _circle));
        }
        // Pending State
      } else {
        yield Ready(
            currentDirection: updateSensors.newDirection,
            currentMotion: _currentMotion);
      }
    }
  }

  // ********************************
  // ** Read Local Data of Assets ***
  // ********************************
  Future<Uint8List> readFileByte(String filePath) async {
    Directory appDir = await getApplicationDocumentsDirectory();
    // appDir.path + '/' +
    Uri myUri = Uri.parse(filePath);
    File audioFile = new File.fromUri(myUri);
    Uint8List bytes;
    await audioFile.readAsBytes().then((value) {
      bytes = Uint8List.fromList(value);
      print('reading of bytes is completed');
    }).catchError((onError) {
      print('Exception Error while reading audio from path:' +
          onError.toString());
    });
    return bytes;
  }

  // ********************************
  // ** Write Local Data of Assets **
  // ********************************
  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    return new File(tempPath + "/" + path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}
