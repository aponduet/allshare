import 'dart:async';
import 'package:allshare/data/app_states.dart';

class Resetter {
  reset(AppStates appStates) {
    Timer(const Duration(seconds: 3), () {
      appStates.isShowSendProgress.value = false;
      appStates.isShowSendSuccess.value = false;
      appStates.isShowReceiveProgress.value = false;
      appStates.isShowSaveSuccess.value = false;
      appStates.isShowSaving.value = false;
      appStates.currentChunkIndex.value = 0;
      appStates.sendProgressValue.value = 0;
      appStates.receiveProgressValue.value = 0;
      appStates.isFileSelected.value = false;
      appStates.receivedChunks.value = [];
      appStates.selectedFileName.value = "";
    });
  }
}
