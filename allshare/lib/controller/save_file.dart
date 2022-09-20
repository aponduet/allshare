import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:allshare/controller/resetter.dart';
import 'package:allshare/data/app_states.dart';
import 'package:allshare/model/file_info.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class Saver {
  bool isSavedFile = false;
  bool isSaving = false;
  //Save Files in Devices

  //Reset previous sending history
  void localreset() {
    isSaving = false;
    isSavedFile = false;
  }

  saveFile(String message, AppStates appStates, Resetter reSetter) async {
    if (!kIsWeb) {
      if (Platform.isIOS || Platform.isAndroid || Platform.isMacOS) {
        bool status = await Permission.storage.isGranted;
        if (!status) await Permission.storage.request();
      }
    }

    FileInfo fileheaders = FileInfo.fromJson(jsonDecode(message));
    String? filename = fileheaders.name ?? "";
    String? extension = fileheaders.extn ?? "";
    List<Uint8List> receivedChunks = appStates.receivedChunks.value;
    //Convert List<Uint8List> to List<int>  //https://stackoverflow.com/questions/62295468/listuint8list-to-listint-in-dart
    List<int> readyChunks = [
      for (var sublist in receivedChunks) ...sublist,
    ];

    Uint8List finalChunks = Uint8List.fromList(readyChunks);
    String savingstatus = await FileSaver.instance
        .saveFile(filename, finalChunks, extension, mimeType: MimeType.OTHER);

    if (savingstatus != "") {
      appStates.isShowSaving.value = false;
      appStates.isShowSaveSuccess.value = true;
      reSetter.reset(appStates);
    }
  }
}
