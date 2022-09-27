import 'package:allshare/data/app_states.dart';
import 'package:allshare/model/received_file.dart';
import 'package:allshare/view/receive_display/image.dart';
import 'package:allshare/view/receive_display/other_file.dart';
import 'package:allshare/view/receive_display/video.dart';
import 'package:flutter/material.dart';

class ReceivedFilesArea extends StatelessWidget {
  final AppStates appStates;

  const ReceivedFilesArea({Key? key, required this.appStates})
      : super(key: key);

  Widget builderItems(int i) {
    List<ReceivedFile> listItems = appStates.receivedItems.value;
    if (listItems[i].extention == 'jpg' ||
        listItems[i].extention == 'JPG' ||
        listItems[i].extention == 'png') {
      return DisplayImage(
        appStates: appStates,
        index: i,
      );
    } else if (listItems[i].extention == 'mp4') {
      return DisplayVideo(
        appStates: appStates,
        index: i,
      );
    } else {
      return DisplayOther(appStates: appStates, index: i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: appStates.receivedItems.value.length,
        itemBuilder: ((context, index) {
          //return DisplayImage(imageData: listItems[index]);
          return builderItems(index);
        }));
  }
}
