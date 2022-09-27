import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:allshare/controller/resetter.dart';
import 'package:allshare/data/app_states.dart';
import 'package:allshare/model/file_info.dart';
import 'package:allshare/model/received_file.dart';
import 'package:file_saver/file_saver.dart';
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

    FileInfo fileheaders = FileInfo.fromJson(jsonDecode(message));
    String? filename = fileheaders.name ?? "";
    String? extension = fileheaders.extn ?? "";
    List<Uint8List> receivedChunks = appStates.receivedChunks.value;
    //Convert List<Uint8List> to List<int>  //https://stackoverflow.com/questions/62295468/listuint8list-to-listint-in-dart
    List<int> readyChunks = [
      for (var sublist in receivedChunks) ...sublist,
    ];

    Uint8List finalChunks = Uint8List.fromList(readyChunks);
    String savedPath = await FileSaver.instance
        .saveFile(filename, finalChunks, extension, mimeType: MimeType.OTHER);

    if (savedPath != "") {
      ReceivedFile receivedFileInstance = ReceivedFile();
      String filePathInWindows = "";
      //!!!!! N.B. dart:io does not work on dart:html
      //kIsWeb comes from dart foundation library, so kIsWeb is common for all platform and supported by all
      //We, will First Detect is the Platform is Web or Not, If kIsWeb = false, then we will check the platform
      //using dart:io package. dart:io is supported in other platform.

      if (kIsWeb) {
        receivedFileInstance.binary = appStates.receivedChunks.value;
        receivedFileInstance.name = fileheaders.name;
        receivedFileInstance.extention = fileheaders.extn;
        receivedFileInstance.path = filePathInWindows;
        receivedFileInstance.text = fileheaders.textmessage;
        receivedFileInstance.time = DateTime.now().hour.toString();
      } else {
        Directory? dir = await getDownloadsDirectory();
        String downloadDirectory = dir!.path.replaceAll(r'\', '\\');
        print(dir.path);
        if (Platform.isWindows) {
          //For Windows
          filePathInWindows = savedPath.replaceAll(
              r'\', '/'); //convert backslash to normal slash
          print("right path is : $filePathInWindows");
          //Remove extension from file name
          // int? x = fileheaders.name!.length;
          // int? y = fileheaders.extn!.length;
          // String name = fileheaders.name!.substring(0, (x - y) - 1);
          // print(name);
          //Updating received item instance
          receivedFileInstance.binary = appStates.receivedChunks.value;
          receivedFileInstance.name = fileheaders.name;
          //receivedFileInstance.name = name;
          receivedFileInstance.extention = fileheaders.extn;
          receivedFileInstance.path = filePathInWindows;
          receivedFileInstance.downloadDirectory = downloadDirectory;
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
}
