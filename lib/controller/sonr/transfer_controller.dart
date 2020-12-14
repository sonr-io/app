import 'dart:io';
import 'package:sonr_core/sonr_core.dart';
import 'package:get/get.dart' hide Node;
import 'package:sonar_app/controller/sonr/conn_controller.dart';

class TransferController extends GetxController {
  // @ Set Local Properties
  bool _isProcessed = false;

  // @ Set Peer Dependencies
  AuthReply reply;
  bool completed = false;
  Payload_Type payloadType;

  // ^ Assign Callbacks and Create Ref for Node ^ //
  void assign() {
    sonrNode.assignCallback(CallbackEvent.Queued, _handleQueued);
    sonrNode.assignCallback(CallbackEvent.Responded, _handleResponded);
    sonrNode.assignCallback(CallbackEvent.Transmitted, _handleTransmitted);
  }

  // ^ Queue-File Event ^
  void queue(Payload_Type payType, {File file}) async {
    // Queue File
    if (payType == Payload_Type.FILE) {
      sonrNode.queue(file.path);
    }
    // Set Payload Type
    payloadType = payType;
  }

  // ^ Invite-Peer Event ^
  void invitePeer(Peer p) async {
    // Update Data
    update(["Listener"]);

    // Send Invite for File
    if (payloadType == Payload_Type.FILE) {
      if (_isProcessed) {
        await sonrNode.invite(p, payloadType);
      }
    }
    // Send Invite for Contact
    else if (payloadType == Payload_Type.CONTACT) {
      await sonrNode.invite(p, payloadType);
    }
  }

  // **************************
  // ******* Callbacks ********
  // **************************
  // ^ File has Succesfully Queued ^ //
  void _handleQueued(dynamic data) async {
    if (data is Metadata) {
      // Update data
      _isProcessed = true;
    }
  }

  // ^ Node Has Been Accepted ^ //
  void _handleResponded(dynamic data) async {
    // Check Type
    if (data is AuthReply) {
      if (data.payload.type == Payload_Type.NONE) {
        // Set Message
        this.reply = data;

        // Report Replied
        update(["Listener"]);
      }
    }
  }

  // ^ Resets Peer Info Event ^
  void _handleTransmitted(dynamic data) async {
    this.completed = true;

    // Reset Peer/Auth
    this.reply = null;
    update(["Listener"]);
  }
}
