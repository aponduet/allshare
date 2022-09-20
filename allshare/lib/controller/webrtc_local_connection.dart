import 'package:allshare/controller/receiver.dart';
import 'package:allshare/controller/resetter.dart';
import 'package:allshare/data/app_states.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebRtcLocalConnection {
  //bool isFirstUserInfoSet = false;
  late RTCPeerConnection localConnection;
  late RTCDataChannel localDataChannel;
  late RTCDataChannelInit _dataChannelDict;
  bool offer = false;
  String localstate = "Connect";
  LocalReceiver localReceiverInstance = LocalReceiver();

  //Configaration of WEBRTC connection
  final Map<String, dynamic> configuration = {
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
      {
        "url": 'turn:192.158.29.39:3478?transport=udp',
        "credential": 'JZEOEt2V3Qb0y27GRntt2u2PAYA=',
        "username": '28224511:1379330808'
      }
    ]
  };

  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true, //for video call
    },
    "optional": [],
  };

  // Local Peer Connection

  //****** WEBRTC Connection Start Here ******** */
  createLocalConnection(
      IO.Socket socket, AppStates appStates, Resetter reSetter) async {
    localConnection =
        await createPeerConnection(configuration, offerSdpConstraints);

    // local data channel
    _dataChannelDict = RTCDataChannelInit();
    _dataChannelDict.id = 1;
    _dataChannelDict.ordered = true;
    _dataChannelDict.maxRetransmitTime = -1;
    _dataChannelDict.maxRetransmits = -1;
    _dataChannelDict.protocol = 'sctp';
    _dataChannelDict.negotiated = false;
    localDataChannel = await localConnection.createDataChannel(
        "localDataChannel", _dataChannelDict);

    //Create Offer
    RTCSessionDescription description =
        await localConnection.createOffer({'offerToReceiveAudio': 1});
    print("Local Session Description ${description.sdp}");
    localConnection.setLocalDescription(description);
    var session = parse(description.sdp.toString());
    socket.emit("createOffer", {"session": session});
    offer = true;
    appStates.isSender.value = true;

    //Sending Caller Ice Candidate
    localConnection.onIceCandidate = (e) {
      print("On-ICE Candidate is Finding");
      //Transmitting candidate data from answerer to caller
      if (e.candidate != null) {
        socket.emit("sendCandidateToRemote", {
          "candidate": {
            'candidate': e.candidate.toString(),
            'sdpMid': e.sdpMid.toString(),
            'sdpMlineIndex': e.sdpMLineIndex,
          },
        });
      }
    };

    //Check WebRTC Connection
    localConnection.onConnectionState = (state) {
      print("Local Connection State is : $state");
    };

    localConnection.onIceConnectionState = (e) {
      print("Ice Connection State is : $e");
    };

    // Checking Connection State

    localConnection.onConnectionState = (state) async {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        appStates.localState.value = "Disconnected";
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        appStates.localState.value = "Connection Closed";
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        appStates.localState.value = "Connected";
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateNew ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateConnecting) {
        appStates.localState.value = "Connecting..";
      }
    };

    //Receiving Files and Messages
    localReceiverInstance.localreceiver(localDataChannel, appStates, reSetter);
  }

  addRemoteSdp(data) async {
    String sdp = write(data["session"], null);
    print('Sring SDP is : $sdp');
    RTCSessionDescription description = RTCSessionDescription(sdp, 'answer');
    await localConnection.setRemoteDescription(description);
  }

  addIceCandidate(var data) async {
    print("Remote Candidate received $data");
    dynamic candidate = RTCIceCandidate(data['candidate']['candidate'],
        data['candidate']['sdpMid'], data['candidate']['sdpMlineIndex']);
    await localConnection.addCandidate(candidate);
  }

  //Loca Receive Channel codes here

}






  // Socket Connection Start

  //Search Receiver

  //Update Maximum Size
  // int maximumMessageSize = 16000;
  // Future updateMaximumMessageSize() async {
  //   RTCSessionDescription? local = await localConnection!.getLocalDescription();
  //   RTCSessionDescription? remote =
  //       await remoteConnection!.getRemoteDescription();

  //   int localMaximumSize = parseMaximumSize(local!);
  //   int remoteMaximumSize = parseMaximumSize(remote);
  //   int messageSize = min(localMaximumSize, remoteMaximumSize);

  //   print(
  //       'SENDER: Updated max message size: $messageSize Local: $localMaximumSize Remote: $remoteMaximumSize ');
  //   maximumMessageSize = messageSize;
  // }

  // //Set Max Cunk Size
  // int parseMaximumSize(RTCSessionDescription? description) {
  //   var remoteLines = description?.sdp?.split('\r\n') ?? [];

  //   int remoteMaximumSize = 0;
  //   for (final line in remoteLines) {
  //     if (line.startsWith('a=max-message-size:')) {
  //       var string = line.substring('a=max-message-size:'.length);
  //       remoteMaximumSize = int.parse(string);
  //       break;
  //     }
  //   }

  //   if (remoteMaximumSize == 0) {
  //     print('SENDER: No max message size session description');
  //   }

  //   // 16 kb should be supported on all clients so we can use it
  //   // even if no max message is set
  //   return max(remoteMaximumSize, maximumMessageSize);
  // }