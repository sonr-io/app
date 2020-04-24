// *******************
// * Signaling Enum **
// *******************
import 'package:flutter_webrtc/webrtc.dart';

enum SignalingState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
  ConnectionOpen,
  ConnectionClosed,
  ConnectionError,
}

// *********************************
// * Callbacks for Signaling API. **
// *********************************
typedef void SignalingStateCallback(SignalingState state);
typedef void StreamStateCallback(MediaStream stream);
typedef void OtherEventCallback(dynamic event);
typedef void DataChannelMessageCallback(
    RTCDataChannel dc, RTCDataChannelMessage data);
typedef void DataChannelCallback(RTCDataChannel dc);

class Signaling {
// ICE RTCConfiguration Map
  final configuration = {
    'iceServers': [
      //{"url": "stun:stun.l.google.com:19302"},
      {
        'urls': 'stun:165.227.86.78:3478',
        'username': 'test',
        'password': 'test'
      }
    ]
  };

// Create DC Constraints
  final constraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  // WebRTC Variables
  var _selfId;
  var _sessionId;
  var _peerConnections = new Map<String, RTCPeerConnection>();
  var _dataChannels = new Map<String, RTCDataChannel>();
  var _remoteCandidates = [];
  var _turnCredential;

  MediaStream _localStream;
  List<MediaStream> _remoteStreams;
  SignalingStateCallback onStateChange;
  StreamStateCallback onLocalStream;
  StreamStateCallback onAddRemoteStream;
  StreamStateCallback onRemoveRemoteStream;
  OtherEventCallback onPeersUpdate;
  DataChannelMessageCallback onDataChannelMessage;
  DataChannelCallback onDataChannel;

  Signaling();

// *************************
// ** Socket.io Handlers ***
// *************************
  _handlePeerUpdate(data) {
    List<dynamic> peers = data;
    if (this.onPeersUpdate != null) {
      Map<String, dynamic> event = new Map<String, dynamic>();
      event['self'] = _selfId;
      event['peers'] = peers;
      this.onPeersUpdate(event);
    }
  }

  _handleOffer(data) async {
    var id = data['from'];
    var description = data['description'];
    var sessionId = data['session_id'];
    this._sessionId = sessionId;

    if (this.onStateChange != null) {
      this.onStateChange(SignalingState.CallStateNew);
    }

    var pc = await _createPeerConnection(id);
    _peerConnections[id] = pc;
    await pc.setRemoteDescription(
        new RTCSessionDescription(description['sdp'], description['type']));
    await _createAnswer(id, pc);
    if (this._remoteCandidates.length > 0) {
      _remoteCandidates.forEach((candidate) async {
        await pc.addCandidate(candidate);
      });
      _remoteCandidates.clear();
    }
  }

  _handleAnswer(data) async {
    var id = data['from'];
    var description = data['description'];

    var pc = _peerConnections[id];
    if (pc != null) {
      await pc.setRemoteDescription(
          new RTCSessionDescription(description['sdp'], description['type']));
    }
  }

  _handleCandidate(data) async {
    var id = data['from'];
    var candidateMap = data['candidate'];
    var pc = _peerConnections[id];
    RTCIceCandidate candidate = new RTCIceCandidate(candidateMap['candidate'],
        candidateMap['sdpMid'], candidateMap['sdpMLineIndex']);
    if (pc != null) {
      await pc.addCandidate(candidate);
    } else {
      _remoteCandidates.add(candidate);
    }
  }

  _handleLeave(data) {
    var id = data;
    var pc = _peerConnections.remove(id);
    _dataChannels.remove(id);

    if (_localStream != null) {
      _localStream.dispose();
      _localStream = null;
    }

    if (pc != null) {
      pc.close();
    }
    this._sessionId = null;
    if (this.onStateChange != null) {
      this.onStateChange(SignalingState.CallStateBye);
    }
  }

  _handleBye(data) {
    var to = data['to'];
    var sessionId = data['session_id'];
    print('bye: ' + sessionId);

    if (_localStream != null) {
      _localStream.dispose();
      _localStream = null;
    }

    var pc = _peerConnections[to];
    if (pc != null) {
      pc.close();
      _peerConnections.remove(to);
    }

    var dc = _dataChannels[to];
    if (dc != null) {
      dc.close();
      _dataChannels.remove(to);
    }

    this._sessionId = null;
    if (this.onStateChange != null) {
      this.onStateChange(SignalingState.CallStateBye);
    }
  }

  close() {
    if (_localStream != null) {
      _localStream.dispose();
      _localStream = null;
    }

    _peerConnections.forEach((key, pc) {
      pc.close();
    });
  }

// ********************
// ** Class Methods ***
// ********************
  void invite(String peerId) {
    this._sessionId = this._selfId + '-' + peerId;

    if (this.onStateChange != null) {
      this.onStateChange(SignalingState.CallStateNew);
    }

    _createPeerConnection(peerId).then((pc) {
      _peerConnections[peerId] = pc;
      _createDataChannel(peerId, pc);
      _createOffer(peerId, pc);
    });
  }

  void bye() {
    _send('bye', {
      'session_id': this._sessionId,
      'from': this._selfId,
    });
  }

// ****************************
// ** WebRTC Helper Methods ***
// ****************************
  _createPeerConnection(id) async {
    RTCPeerConnection pc =
        await createPeerConnection(configuration, constraints);
    pc.onIceCandidate = (candidate) {
      _send('candidate', {
        'to': id,
        'from': _selfId,
        'candidate': {
          'sdpMLineIndex': candidate.sdpMlineIndex,
          'sdpMid': candidate.sdpMid,
          'candidate': candidate.candidate,
        },
        'session_id': this._sessionId,
      });
    };

    pc.onIceConnectionState = (state) {};

    pc.onDataChannel = (channel) {
      _addDataChannel(id, channel);
    };

    return pc;
  }

  _addDataChannel(id, RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (RTCDataChannelMessage data) {
      if (this.onDataChannelMessage != null)
        this.onDataChannelMessage(channel, data);
    };
    _dataChannels[id] = channel;

    if (this.onDataChannel != null) this.onDataChannel(channel);
  }

  _createDataChannel(id, RTCPeerConnection pc, {label: 'fileTransfer'}) async {
    RTCDataChannelInit dataChannelDict = new RTCDataChannelInit();
    RTCDataChannel channel = await pc.createDataChannel(label, dataChannelDict);
    _addDataChannel(id, channel);
  }

  _createOffer(String id, RTCPeerConnection pc) async {
    try {
      RTCSessionDescription s = await pc.createOffer(constraints);
      pc.setLocalDescription(s);
      _send('offer', {
        'to': id,
        'from': _selfId,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': this._sessionId,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  _createAnswer(String id, RTCPeerConnection pc) async {
    try {
      RTCSessionDescription s = await pc.createAnswer(constraints);
      pc.setLocalDescription(s);
      _send('answer', {
        'to': id,
        'from': _selfId,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': this._sessionId,
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
