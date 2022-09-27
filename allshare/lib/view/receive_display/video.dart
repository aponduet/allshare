import 'dart:io';
import 'package:allshare/controller/converter.dart';
import 'package:allshare/data/app_states.dart';
import 'package:allshare/model/received_file.dart';
import 'package:allshare/screens/video_play.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DisplayVideo extends StatelessWidget {
  final Converter converter = Converter();
  final AppStates appStates;
  final int index;
  DisplayVideo({Key? key, required this.appStates, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ReceivedFile receivedFile = appStates.receivedItems.value[index];
    return Container(
      width: 300,
      height: 100,
      //margin: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 240, 240, 240),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: InkWell(
            onTap: () {
              // print('Clicked run button.');

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
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VideoPlay(appStates: appStates, index: index),
                  ),
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 50,
                  //height: 80,
                  child: Icon(
                    Icons.movie,
                    size: 50,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(receivedFile.name ?? ""),
                )),
              ],
            ),
          )),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.green),
                borderRadius: const BorderRadius.all(Radius.circular(25))),
            child: IconButton(
              icon: const Center(
                child: Icon(Icons.download),
              ),
              iconSize: 25,
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
                    //saveFile will just pick the selected location path
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
          )
        ],
      ),
    );
  }
}
