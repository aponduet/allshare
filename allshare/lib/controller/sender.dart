import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:allshare/controller/resetter.dart';
import 'package:allshare/data/app_states.dart';
import 'package:allshare/model/file_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

//***************     Local Sender        ********************
//***************     Local Sender        ********************
//***************     Local Sender        ********************
class LocalSender {
  double sendprogress = 0;
  bool showSendProgressBar = false;
  bool isSendSuccess = false;
  int currentChunkId = 0;
  //Send Message
  sendtext(RTCDataChannel? localDataChannel,
      TextEditingController? textInputController) {
    //Send message to Remote
    //Sending total chunk to Receiver
    FileInfo messageHistory = FileInfo(
        textmessage: textInputController!.text,
        totalChunk: 0,
        isLastChunk: false,
        isFirstChunk: false,
        isFileInfo: false);
    String info = jsonEncode(messageHistory);
    RTCDataChannelMessage messageText = RTCDataChannelMessage(info);
    localDataChannel!.send(messageText);
    print(messageHistory.textmessage);
    textInputController.text = "";
  }

  //Send Message

  sendFile(
      RTCDataChannel? localDataChannel,
      PlatformFile? selectedfile,
      List<Uint8List> chunks,
      AppStates appStates,
      Resetter reSetterInstance) async {
    //Large File Sending New System
    //Send Files from Local to Remote
    sendFilesLocalToRemote(int currentChunkIndex) {
      if (localDataChannel!.bufferedAmount == 0 ||
          localDataChannel.bufferedAmount == null) {
        print("Send Bucket is Empty!");
        if (currentChunkIndex == 0) {
          print("First condition called");
          //Sending total chunk to Receiver
          FileInfo fileHistory = FileInfo(
              name: selectedfile!.name,
              extn: selectedfile.extension,
              totalChunk: chunks.length,
              isLastChunk: false,
              isFirstChunk: true,
              isFileInfo: true);

          String info = jsonEncode(fileHistory);
          RTCDataChannelMessage fileData = RTCDataChannelMessage(info);
          localDataChannel.send(fileData);
          print("This is First Message with Total Chunk");
          appStates.isShowSendProgress.value = true;
        }

        if (currentChunkIndex < chunks.length) {
          print("Second condition called");
          RTCDataChannelMessage binaryMessage =
              RTCDataChannelMessage.fromBinary(chunks[currentChunkIndex]);
          //print(binaryMessage);
          localDataChannel.send(binaryMessage);
          sendprogress = currentChunkIndex / (chunks.length);
          appStates.sendProgressValue.value = sendprogress;
        }

        if (currentChunkIndex == chunks.length) {
          print("Third condition called");
          FileInfo fileHistory = FileInfo(
              name: selectedfile!.name,
              extn: selectedfile.extension,
              totalChunk: chunks.length,
              isLastChunk: true,
              isFirstChunk: false,
              isFileInfo: true);
          String info = jsonEncode(fileHistory);
          RTCDataChannelMessage fileData = RTCDataChannelMessage(info);
          localDataChannel.send(fileData);

          sendprogress = 1.0;
          appStates.sendProgressValue.value = sendprogress;
          appStates.isShowSendProgress.value = false;
          appStates.isShowSendSuccess.value = true;
          //Reset

          reSetterInstance.reset(appStates); // will reset all states

          print(
              "Sendchanell buffered abount : ${localDataChannel.bufferedAmount}");
          print("Total chunk : ${chunks.length}");
          print("Last Chunk has been sent");
        }
        if (currentChunkIndex < chunks.length) {
          appStates.currentChunkIndex.value =
              currentChunkIndex + 1; // must reset to zero when send complete
          sendFilesLocalToRemote(appStates.currentChunkIndex.value);
        }
      } else {
        Timer(const Duration(milliseconds: 100), () {
          print("Waiting untill the Buffered amount is zero or null");
          sendFilesLocalToRemote(appStates.currentChunkIndex.value);
        });
      }
    }

    //Sending files
    sendFilesLocalToRemote(appStates.currentChunkIndex.value);
  }
}

//***************     Remote Sender        ********************
//***************     Remote Sender        ********************
//***************     Remote Sender        ********************

class RemoteSender {
  double sendprogress = 0;
  bool showSendProgressBar = false;
  bool isSendSuccess = false;
  int currentChunkId = 0;
  //Send Message
  sendtext(RTCDataChannel? remoteDataChannel,
      TextEditingController? textInputController) {
    //Send message to Remote
    //Sending total chunk to Receiver
    FileInfo messageHistory = FileInfo(
        textmessage: textInputController!.text,
        totalChunk: 0,
        isLastChunk: false,
        isFirstChunk: false,
        isFileInfo: false);
    String info = jsonEncode(messageHistory);
    RTCDataChannelMessage messageText = RTCDataChannelMessage(info);
    remoteDataChannel!.send(messageText);
    print(messageHistory.textmessage);
    textInputController.text = "";
  }

  //Send Files

  sendFile(
      RTCDataChannel? remoteDataChannel,
      PlatformFile? selectedfile,
      List<Uint8List> chunks,
      AppStates appStates,
      Resetter reSetterInstance) async {
    //Large File Sending New System

    //Send Files From Remote to Local
    sendFilesRemoteToLocal(int currentChunkIndex) {
      if (remoteDataChannel!.bufferedAmount == 0 ||
          remoteDataChannel.bufferedAmount == null) {
        print("Send Bucket is Empty!");
        if (currentChunkIndex == 0) {
          //Sending total chunk to Receiver
          FileInfo fileHistory = FileInfo(
              name: selectedfile!.name,
              extn: selectedfile.extension,
              totalChunk: chunks.length,
              isLastChunk: false,
              isFirstChunk: true,
              isFileInfo: true);

          String info = jsonEncode(fileHistory);
          RTCDataChannelMessage fileData = RTCDataChannelMessage(info);
          remoteDataChannel.send(fileData);

          print("This is First Message with Total Chunk");
        }

        if (currentChunkIndex < chunks.length) {
          RTCDataChannelMessage binaryMessage =
              RTCDataChannelMessage.fromBinary(chunks[currentChunkIndex]);
          //print(binaryMessage);
          remoteDataChannel.send(binaryMessage);
          sendprogress = currentChunkIndex / (chunks.length);
          appStates.isShowSendProgress.value = true;
          appStates.sendProgressValue.value = sendprogress;
        }

        if (currentChunkIndex == chunks.length) {
          FileInfo fileHistory = FileInfo(
              name: selectedfile!.name,
              extn: selectedfile.extension,
              totalChunk: chunks.length,
              isLastChunk: true,
              isFirstChunk: false,
              isFileInfo: true);
          String info = jsonEncode(fileHistory);
          RTCDataChannelMessage fileData = RTCDataChannelMessage(info);
          remoteDataChannel.send(fileData);
          //Show Progress Indicator
          sendprogress = 1.0;
          appStates.sendProgressValue.value = sendprogress;
          appStates.isShowSendProgress.value = false;
          appStates.isShowSendSuccess.value = true;

          print("Total chunk : ${chunks.length}");
          print("Last Chunk has been sent");
          //Reset current chunk Id
          reSetterInstance.reset(appStates);
        }
        if (currentChunkIndex < chunks.length) {
          appStates.currentChunkIndex.value = currentChunkIndex + 1;
          sendFilesRemoteToLocal(appStates.currentChunkIndex.value);
        }
      } else {
        Timer(const Duration(milliseconds: 100), () {
          print("Waiting untill the Buffered amount is zero or null");
          sendFilesRemoteToLocal(appStates.currentChunkIndex.value);
        });
      }
    }

    //Sending files
    sendFilesRemoteToLocal(appStates.currentChunkIndex.value);
    showSendProgressBar = true;
  }
}
