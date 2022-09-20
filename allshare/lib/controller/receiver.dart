import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:allshare/controller/resetter.dart';
import 'package:allshare/controller/save_file.dart';
import 'package:allshare/data/app_states.dart';
import 'package:allshare/model/file_info.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

//*********** Local RECEIVER ********* */
//*********** Local RECEIVER ********* */
//*********** Local RECEIVER ********* */

class LocalReceiver {
  int totalChunks = 0;
  Saver localFileSaverInstance = Saver();
  localreceiver(
      RTCDataChannel? sendChannel, AppStates appStates, Resetter reSetter) {
    sendChannel!.onMessage = (message) {
      if (message.isBinary) {
        appStates.receivedChunks.value.add(message.binary);
        // Update progress bar value
        double percent = (appStates.receivedChunks.value.length) / totalChunks;
        //Show Received Progress Indicator
        appStates.receiveProgressValue.value = percent;
        appStates.isShowReceiveProgress.value = true;
      }
      if (!message.isBinary) {
        FileInfo fileheaders = FileInfo.fromJson(jsonDecode(message.text));
        if (!fileheaders.isFileInfo) {
          //used to show text on chatbox
          print(fileheaders.textmessage);
        }

        if (fileheaders.isFirstChunk) {
          totalChunks = fileheaders.totalChunk;
        }
        //save file to storage or download in web
        if (fileheaders.isLastChunk) {
          appStates.receiveProgressValue.value = 1;
          appStates.isShowReceiveProgress.value = false;
          appStates.isShowSaving.value = true;
          Timer(const Duration(seconds: 2), () {
            localFileSaverInstance.saveFile(message.text, appStates, reSetter);
          });
        }
      }
    };
  }
}

//*********** REMOTE RECEIVER ********* */
//*********** REMOTE RECEIVER ********* */
//*********** REMOTE RECEIVER ********* */

class RemoteReceiver {
  int totalChunks = 0;
  Saver remoteFileSaverInstance = Saver();

  remoteReceiver(RTCDataChannel? receiveChannel, AppStates appStates,
      Resetter reSetterInstance) {
    receiveChannel!.onMessage = (message) async {
      if (message.isBinary) {
        appStates.receivedChunks.value.add(message.binary);
        // Update progress bar value
        double percent = (appStates.receivedChunks.value.length) / totalChunks;
        appStates.receiveProgressValue.value = percent;
        appStates.isShowReceiveProgress.value = true;
      }
      if (!message.isBinary) {
        FileInfo fileheaders = FileInfo.fromJson(jsonDecode(message.text));
        if (!fileheaders.isFileInfo) {
          //used to show text on chatbox
          print(fileheaders.textmessage);
        }

        if (fileheaders.isFirstChunk) {
          totalChunks = fileheaders.totalChunk;
        }
        //save file to storage or download in web
        if (fileheaders.isLastChunk) {
          appStates.receiveProgressValue.value = 1;
          appStates.isShowReceiveProgress.value = false;
          appStates.isShowSaving.value = true;
          Timer(const Duration(seconds: 2), () {
            //save file after two seconds
            remoteFileSaverInstance.saveFile(
                message.text, appStates, reSetterInstance);
          });
        }
      }
    };
  }
}
