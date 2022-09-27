import 'dart:convert';
import 'dart:io';
import 'package:allshare/controller/html.dart';
import 'dart:typed_data';
import 'package:allshare/controller/resetter.dart';
import 'package:allshare/data/app_states.dart';
import 'package:allshare/model/file_info.dart';
import 'package:allshare/model/received_file.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
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

    ReceivedFile receivedFileInstance = ReceivedFile();
    FileInfo fileheaders = FileInfo.fromJson(jsonDecode(message));

    //File Saving Codes
    if (!kIsWeb) {
      if (Platform.isWindows) {
        Directory? dir = await getDownloadsDirectory();
        String directory = dir!.path.replaceAll(r'\', '/');
        String winDirForCmd = dir.path.replaceAll(r'\', '\\');
        FileInfo fileInfo = FileInfo.fromJson(jsonDecode(message));
        String extension = fileInfo.extn!;
        String name = '${DateTime.now().millisecondsSinceEpoch}.$extension';
        String path = '$directory/$name';
        List<Uint8List> chunks = appStates.receivedChunks.value;
        List<int> bytes = [for (var sublist in chunks) ...sublist];
        File file = File(path);
        File saveStatus =
            await file.writeAsBytes(bytes, mode: FileMode.write, flush: false);
        print('The Saving Path is : $saveStatus');
        String status = saveStatus.path;
        //Update states
        if (status == path) {
          print('saveStatus == path : $path');
          receivedFileInstance.binary = appStates.receivedChunks.value;
          receivedFileInstance.name = name;
          receivedFileInstance.extention = extension;
          receivedFileInstance.path = path;
          receivedFileInstance.dirForCmd = winDirForCmd;
          receivedFileInstance.text = fileheaders.textmessage;
          receivedFileInstance.time = DateTime.now().hour.toString();
        }
      }
    } else {
      FileInfo fileInfo = FileInfo.fromJson(jsonDecode(message));
      String extension = fileInfo.extn!;
      String name = '${DateTime.now().millisecondsSinceEpoch}.$extension';
      List<Uint8List> chunks = appStates.receivedChunks.value;
      List<int> listBytes = [for (var sublist in chunks) ...sublist];
      Uint8List bytes = Uint8List.fromList(listBytes);
      bool isDownloaded = Html.save(bytes, name);
      //Update States
      if (isDownloaded) {
        receivedFileInstance.binary = appStates.receivedChunks.value;
        receivedFileInstance.name = name;
        receivedFileInstance.extention = extension;
        receivedFileInstance.text = fileheaders.textmessage;
        receivedFileInstance.time = DateTime.now().hour.toString();
      }
    }

    //saving every new item to store.
    appStates.receivedItems.value = List.from(appStates.receivedItems.value)
      ..add(receivedFileInstance);
    //controlling progress Indicator
    appStates.isShowSaving.value = false;
    appStates.isShowSaveSuccess.value = true;
    reSetter.reset(appStates);
  }
}
