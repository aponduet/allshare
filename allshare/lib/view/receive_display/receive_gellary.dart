import 'package:allshare/data/app_states.dart';
import 'package:allshare/view/receive_display/item_list.dart';
import 'package:flutter/material.dart';

import '../../model/received_file.dart';

class ReceiveGellary extends StatelessWidget {
  final AppStates appStates;
  const ReceiveGellary({Key? key, required this.appStates}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: 300,
      height: double.infinity,
      child: ValueListenableBuilder<List<ReceivedFile>>(
          valueListenable: appStates.receivedItems,
          builder: (context, receivedItems, child) {
            return receivedItems.isNotEmpty
                ? ReceivedFilesArea(appStates: appStates)
                : const Center(
                    child: Text("No Items received yet!!"),
                  );
          }),
    );
  }
}
