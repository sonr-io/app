import 'repository.dart';
import 'package:sonar_app/core/core.dart';

// *******************
// * Signaling Enum **
// *******************
enum SignalingState {
  CallStateNew,
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
typedef void OverrideSignalingStateCallback(SignalingState state);
typedef void StreamStateCallback(MediaStream stream);
typedef void OtherEventCallback(dynamic event);
typedef void DataChannelMessageCallback(
    RTCDataChannel dc, RTCDataChannelMessage data);
typedef void DataChannelCallback(RTCDataChannel dc);

// *******************
// * Initialization **
// *******************
class RTCSession {
  // Session Id
  String id;

  // WebRTC
  Map peerConnections = new Map<String, RTCPeerConnection>();
  Map dataChannels = new Map<String, RTCDataChannel>();
  var remoteCandidates = [];

  // Callbacks
  OverrideSignalingStateCallback onStateChange;
  OtherEventCallback onPeersUpdate;
  DataChannelMessageCallback onDataChannelMessage;
  DataChannelCallback onDataChannel;

// ****************************
// ** WebRTC Object Methods ***
// ****************************
  addDataChannel(id, RTCDataChannel channel) {
    // Send Callback to DataBloc
    channel.onDataChannelState = (e) {};

    // Add Message as Callback
    channel.onMessage = (RTCDataChannelMessage data) {
      if (this.onDataChannelMessage != null)
        this.onDataChannelMessage(channel, data);
    };

    // Add Channel to List
    dataChannels[id] = channel;

    // Subscribe to Callback
    if (this.onDataChannel != null) this.onDataChannel(channel);
  }

  createDataChannel(id, RTCPeerConnection pc, {label: 'fileTransfer'}) async {
    RTCDataChannelInit dataChannelDict = new RTCDataChannelInit();
    RTCDataChannel channel = await pc.createDataChannel(label, dataChannelDict);
    addDataChannel(id, channel);
  }

  initializePeer(Role role, RTCPeerConnection pc, Peer match,
      {RTCSessionDescription description}) async {
    // Listen to ICE Connection
    pc.onIceConnectionState = (state) {};

    // Add Data Channel
    pc.onDataChannel = (channel) {
      this.addDataChannel(match.id, channel);
    };

    // Set Values
    this.peerConnections[match.id] = pc;

    // Check if Receiving
    if (role == Role.Receiver) {
      // Validate Description Data
      if (description != null) {
        // Set Remote Description
        await pc.setRemoteDescription(description);
      }
      // Log Error
      else {
        log.e("Description Data not Provided for Receiver");
      }
    }
    // Peer is Sending
    else {
      // Create New DataChannel
      this.createDataChannel(match.id, pc);
    }
  }

  peersUpdated(data) {
    List<dynamic> peers = data;
    if (this.onPeersUpdate != null) {
      Map<String, dynamic> event = new Map<String, dynamic>();
      event['self'] = this.id;
      event['peers'] = peers;
      this.onPeersUpdate(event);
    }
  }

  setRemoteCandidates(RTCPeerConnection pc) async {
    if (this.remoteCandidates.length > 0) {
      this.remoteCandidates.forEach((candidate) async {
        await pc.addCandidate(candidate);
      });
      this.remoteCandidates.clear();
    }
  }

  updateState(SignalingState state, {String newId}) {
    // Validate Existence
    if (this.onStateChange != null) {
      // Check if New Call
      if (state == SignalingState.CallStateNew) {
        // Set Session Id
        this.id = newId;
      }
      // Check if End Call
      else if (state == SignalingState.CallStateBye) {
        this.id = null;
      }

      // Set New State
      this.onStateChange(state);
    }
  }
}
