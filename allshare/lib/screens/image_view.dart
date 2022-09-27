import 'dart:io';
import 'dart:typed_data';
import 'package:allshare/controller/converter.dart';
import 'package:allshare/data/app_states.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatelessWidget {
  final Converter converter = Converter();
  final AppStates appStates;
  final int index;
  Uint8List? imageBinay;
  ImageView({Key? key, required this.appStates, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Controll What to Show Depending on Platform
    imageBinay =
        converter.getUint8List(appStates.receivedItems.value[index].binary);
    ImageProvider<Object>? imageProvider() {
      if (kIsWeb) {
        return MemoryImage(imageBinay!);
      } else {
        return FileImage(
          File(appStates.receivedItems.value[index]
              .path!), //Image coming from local storage using path
        );
      }
    }

    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Container(
              child: PhotoView(
                imageProvider: imageProvider(),
              ),
            ),
            Positioned(
              right: 50,
              top: 50,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.red),
                    borderRadius: const BorderRadius.all(Radius.circular(25))),
                child: IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
