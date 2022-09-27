import 'dart:typed_data';

import 'package:allshare/model/profileData.dart';
import 'package:allshare/model/received_file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class AppStates {
  final ValueNotifier<bool> remoteUserStatus = ValueNotifier<bool>(false);
  final ValueNotifier<bool> localUserStatus = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isAllUsersActive = ValueNotifier<bool>(false);

  final ValueNotifier<ProfileData> remoteUserInfo =
      ValueNotifier<ProfileData>(ProfileData());
  final ValueNotifier<ProfileData> localUserInfo =
      ValueNotifier<ProfileData>(ProfileData());
  final ValueNotifier<String> localState = ValueNotifier<String>("Connect");
  final ValueNotifier<String> remoteState = ValueNotifier<String>("Connect");
  final ValueNotifier<bool> isSender = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isFileSelected = ValueNotifier<bool>(false);
  final ValueNotifier<String> selectedFileName = ValueNotifier<String>("");
  final ValueNotifier<int> currentChunkIndex = ValueNotifier<int>(0);
  final ValueNotifier<List<Uint8List>> receivedChunks =
      ValueNotifier<List<Uint8List>>([]);

  //Progress and File Saving Indicator Related States
  final ValueNotifier<bool> isShowSendProgress = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isShowReceiveProgress = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isShowSendSuccess = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isShowSaving = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isShowSaveSuccess = ValueNotifier<bool>(false);
  final ValueNotifier<double> sendProgressValue = ValueNotifier<double>(0);
  final ValueNotifier<double> receiveProgressValue = ValueNotifier<double>(0);
  //Received Display Area

  final ValueNotifier<List<ReceivedFile>> receivedItems =
      ValueNotifier<List<ReceivedFile>>([]);
}
