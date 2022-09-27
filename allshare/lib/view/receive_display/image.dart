import 'dart:io';
import 'package:allshare/controller/converter.dart';
import 'package:allshare/data/app_states.dart';
import 'package:allshare/model/received_file.dart';
import 'package:allshare/screens/image_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DisplayImage extends StatelessWidget {
  //final ReceivedFile imageData;
  final AppStates appStates;
  final int index;
  final Converter converter = Converter();
  DisplayImage({
    Key? key,
    required this.appStates,
    required this.index,
  }) : super(key: key);

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
              child: GestureDetector(
            onTap: () {
              print("Gesture ditector button is clicked");
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ImageView(appStates: appStates, index: index)),
              );

              //do something for Image modal
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  // child: Image.file(
                  //   File('C:/Users/Sohel Rana/Downloads/rana.jpg.jpg'),
                  //   width: 100,
                  //   height: 80,
                  //   fit: BoxFit.fill,
                  // ),
                  child:
                      Image.memory(converter.getUint8List(receivedFile.binary)),
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.green),
                borderRadius: const BorderRadius.all(Radius.circular(25))),
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
          )
        ],
      ),
    );
  }
}
