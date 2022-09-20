import 'package:allshare/controller/receiver.dart';
import 'package:allshare/controller/resetter.dart';
import 'package:allshare/data/app_states.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebRtcRemoteConnection {
  late RTCPeerConnection remoteConnection;
  late RTCDataChannel remoteDataChannel;
  bool offer = false;
  String remotestate = "Connect";
  RemoteReceiver remoteReceiverInstance =
      RemoteReceiver(); // Remote Receiver Instance

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

  createRemoteConnection(var data, IO.Socket socket, AppStates appStates,
      Resetter reSetterInstance) async {
    print("Offer received $data");
    remoteConnection =
        await createPeerConnection(configuration, offerSdpConstraints);
    addRemoteSdp(data, socket);
    appStates.isSender.value = false;

    remoteConnection.onConnectionState = (state) {
      print("Remote Connection State is : $state");
    };

    //ICE Candidate
    remoteConnection.onIceCandidate = (e) {
      print("On-ICE Candidate is Finding");
      //Transmitting candidate data from answerer to caller
      if (e.candidate != null) {
        socket.emit("sendCandidateToLocal", {
          "candidate": {
            'candidate': e.candidate.toString(),
            'sdpMid': e.sdpMid.toString(),
            'sdpMlineIndex': e.sdpMLineIndex,
          },
        });
      }
    };
    remoteConnection.onIceConnectionState = (e) {
      print(e);
    };

    // Checking Connection State

    remoteConnection.onConnectionState = (state) async {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        appStates.remoteState.value = "Disconnected";
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        appStates.remoteState.value = "Connection Closed";
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        appStates.remoteState.value = "Connected";
      }
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateNew ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateConnecting) {
        appStates.remoteState.value = "Connecting..";
      }
    };
    // Creating Remote Data Channel
    remoteConnection.onDataChannel = (channel) {
      remoteDataChannel = channel;
      //Receiving Files or Messages
      remoteReceiverInstance.remoteReceiver(
          remoteDataChannel, appStates, reSetterInstance);
    };
  }

  addRemoteSdp(var data, IO.Socket socket) async {
    print("I am in remote connection addRemoteSdp function, The Data is $data");
    String sdp = write(data["session"], null);

    RTCSessionDescription description = RTCSessionDescription(sdp, 'offer');

    await remoteConnection.setRemoteDescription(description);

    RTCSessionDescription description2 = await remoteConnection.createAnswer(
        {'offerToReceiveAudio': 1}); // {'offerToReceiveVideo': 1 for video call

    print("Remote Session Description : ${description2.sdp}");

    var session = parse(description2.sdp.toString());

    await remoteConnection.setLocalDescription(description2);
    print(
        "I am in remote connection addRemoteSdp function, The answer SDP is $session");

    socket.emit("createAnswer", {"session": session});
  }

  addIceCandidate(var data) async {
    print("Local Candidate received $data");
    dynamic candidate = RTCIceCandidate(data['candidate']['candidate'],
        data['candidate']['sdpMid'], data['candidate']['sdpMlineIndex']);
    await remoteConnection.addCandidate(candidate);
  }
}
