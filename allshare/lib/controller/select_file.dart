import 'dart:typed_data';

import 'package:allshare/data/app_states.dart';
import 'package:file_picker/file_picker.dart';

class FileSelector {
  FilePickerResult? result;
  PlatformFile? selectedfile;
  Uint8List? fileInBytes;
  List<Uint8List> chunks = [];

  localreset() {
    chunks = [];
    selectedfile = null;
  }

  //Select Files to send
  selectFile(AppStates appStates) async {
    localreset(); //First Clear the previous history of chunks
    result = await FilePicker.platform.pickFiles(
      withData:
          true, //use withData: true, If null is returned in desktop , follow https://github.com/miguelpruivo/flutter_file_picker/issues/817
    );

    if (result != null) {
      selectedfile = result!.files.first;
      //Make small chunk of message
      fileInBytes = selectedfile!.bytes;
      int chunkSize = 262144;
      //print("File type is: ${selectedfile!.extension}");
      for (var i = 0; i < fileInBytes!.length; i += chunkSize) {
        chunks.add(fileInBytes!.sublist(
            i,
            i + chunkSize > fileInBytes!.length
                ? fileInBytes!.length
                : i + chunkSize));
      }
      appStates.selectedFileName.value = selectedfile!.name;
      appStates.isFileSelected.value = true;
    } else {
      print("No Files Selected!!");
    }
  }
}
