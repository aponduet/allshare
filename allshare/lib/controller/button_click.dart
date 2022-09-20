import 'dart:convert';

import 'package:allshare/data/app_states.dart';
import 'package:allshare/model/profileData.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ButtonClick {
  //Button Text Depending on WEBSocket Connection State
  static Widget buttonText(AppStates appStates) {
    if (appStates.localUserStatus.value == true &&
        appStates.remoteUserStatus.value == true) {
      return const Text("Users Active");
    } else {
      return const Text("Refresh");
    }
  }

  static ProfileData? refreshUsers(IO.Socket socket) {
    ProfileData? data;
    if (socket.connected) {
      data = ProfileData(
        name: "Sohel Rana",
        id: socket.id,
        status: socket.connected,
      );

      socket.emit("firstUserInfo", jsonEncode(data));
    }
    return data;
  }
}
