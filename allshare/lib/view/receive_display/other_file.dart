import 'dart:io';

import 'package:allshare/controller/converter.dart';
import 'package:allshare/data/app_states.dart';
import 'package:allshare/model/received_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DisplayOther extends StatelessWidget {
  final AppStates appStates;
  final int index;
  final Converter converter = Converter();
  DisplayOther({Key? key, required this.appStates, required this.index})
      : super(key: key);
  Widget filetype() {
    if (appStates.receivedItems.value[index].extention == 'docx') {
      return const Icon(Icons.file_present);
    } else if (appStates.receivedItems.value[index].extention == 'mp3') {
      return const Icon(Icons.audio_file);
    }
    if (appStates.receivedItems.value[index].extention == 'pdf') {
      return const Icon(Icons.picture_as_pdf);
    } else {
      return const Icon(Icons.file_copy);
    }
  }

  @override
  Widget build(BuildContext context) {
    ReceivedFile receivedFile = appStates.receivedItems.value[index];
    return Container(
      width: 300,
      height: 100,
      margin: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 219, 217, 217),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (!kIsWeb) {
                  if (Platform.isWindows) {
                    var playStatus = Process.run(
                      'start',
                      ['${receivedFile.name}'],
                      runInShell: true,
                      workingDirectory: '${receivedFile.dirForCmd}',
                    );
                    print(playStatus);
                  }
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 80,
                    child: filetype(),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Text(appStates.receivedItems.value[index].name ?? ""),
                  )),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: IconButton(
              icon: const Icon(Icons.download),
              iconSize: 24,
              onPressed: () async {
                // download(converter.getUint8List(imageData.binary),
                //     imageData.name!, imageData.extention!);
                if (kIsWeb) {
                  await FileSaver.instance.saveFile(
                      //(File Saver package)
                      receivedFile.name!,
                      converter.getUint8List(receivedFile.binary),
                      receivedFile.extention!,
                      mimeType: MimeType.OTHER);
                } else if (Platform.isAndroid || Platform.isIOS) {
                  // Now support only IOS and Android (File Saver package)
                  await FileSaver.instance.saveAs(
                      receivedFile.name!,
                      converter.getUint8List(receivedFile.binary),
                      receivedFile.extention!,
                      MimeType.OTHER);
                } else {
                  //For Windows/MacOS/Linux
                  String? path = await FilePicker.platform.saveFile(
                    // Saving system from File Picker
                    dialogTitle: 'Please select an output file:',
                    fileName: receivedFile.name,
                  );
                  if (path != null) {
                    File file = File(path);
                    File status = await file.writeAsBytes(
                        converter.getUint8List(receivedFile.binary),
                        mode: FileMode.write,
                        flush: false);
                    if (status != null) {
                      print("File Saved");
                    } else {
                      print("Not Saved");
                    }
                    print(status);
                  } else {
                    print("Directory not selected");
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
