import 'dart:typed_data';

class ReceivedFile {
  List<Uint8List> binary = [];
  String? name = " ";
  String? extention = " ";
  String? path = " ";
  String? dirForCmd = " ";
  String? text = " ";
  String? time = DateTime.now().toString();
  bool? isVideo = false;
  bool? isAudio = false;
  bool? isPdf = false;
  bool? isImage = false;
  bool? isWordFile = false;
  bool? isZiped = false;
}
