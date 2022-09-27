import 'dart:convert';
import 'package:allshare/controller/resetter.dart';
import 'package:allshare/controller/webrtc_local_connection.dart';
import 'package:allshare/controller/webrtc_remote_connection.dart';
import 'package:allshare/data/app_states.dart';
import 'package:allshare/model/profileData.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Websocket {
  IO.Socket? socket;
  ProfileData? remoteUserInfo;
  ProfileData? localUserInfo;
  bool remoteUserStatus = false;
  bool localUserStatus = false;
  WebRtcLocalConnection localInstance = WebRtcLocalConnection();
  WebRtcRemoteConnection remoteInstance = WebRtcRemoteConnection();

  // webRtcConnectionStart() {
  //   localInstance.createLocalConnection(socket!);
  //   //remoteInstance.createRemoteConnection(socket!);
  // }

  startSocketConnection(AppStates appStates, Resetter reSetterInstance) {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket!.connect();
    socket!.on('connect', (_) {
      print('Connected id : ${socket!.id}');
    });

    socket!.onConnect((data) async {
      print('Socket Server Successfully connected');
    });

    //Offer received from Local client
    socket!.on("receiveOffer", (data) async {
      await remoteInstance.createRemoteConnection(
          data, socket!, appStates, reSetterInstance);

      // remoteInstance.addRemoteSdp(
      //     data, socket!); //added local sdp to remote connection.
    });
    //Answer received from Second client which is set as remote description
    socket!.on("receiveAnswer", (data) async {
      print("Answer received: $data");
      localInstance.addRemoteSdp(data); //added remote sdp to local
    });
    //Receiving Local Candidates
    //THIS COMPELETES THE CONNECTION PROCEDURE
    socket!.on("receiveLocalCandidate", (data) async {
      remoteInstance.addIceCandidate(data);
    });

    //Receiving Remote Candidates
    //THIS COMPELETES THE CONNECTION PROCEDURE
    socket!.on("receiveRemoteCandidate", (data) async {
      localInstance.addIceCandidate(data);
    });

    socket!.on('remoteUserInfo', (data) {
      Map<String, dynamic> json = jsonDecode(data);
      appStates.remoteUserInfo.value = ProfileData.fromJson(json);
      updateUsers(appStates);
      appStates.remoteUserStatus.value = true;
    });

    socket!.on("userDisconnected", (data) {
      appStates.remoteUserStatus.value = false;
    });
  }

  void disposeSocket() {
    if (socket!.disconnected) {
      socket!.disconnect();
    }
  }

  updateUsers(AppStates appStates) {
    //store.counter.value += 1;
    if (!appStates.localUserStatus.value) {
      if (socket!.connected) {
        appStates.localUserInfo.value = ProfileData(
          name: "Sohel Rana",
          id: socket!.id,
          status: socket!.connected,
        );

        if (!appStates.remoteUserStatus.value) {
          socket!
              .emit("localUserInfo", jsonEncode(appStates.localUserInfo.value));
        }
        appStates.localUserStatus.value = true;
      }
    }
  }
  //Close all connnection

  closeAllConnection() {
    remoteInstance.remoteConnection.close();
    localInstance.localConnection.close();
    localInstance.localDataChannel.close();
    remoteInstance.remoteDataChannel.close();
  }
}
