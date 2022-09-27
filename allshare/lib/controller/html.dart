import 'dart:typed_data';
import 'package:allshare/controller/dart.dart'
    if (dart.library.html) 'dart:html';

class Html {
  static bool save(Uint8List bytes, String name) {
    final blob = Blob([bytes]); //Blob will carry array of bytes
    final url = Url.createObjectUrlFromBlob(blob);
    AnchorElement anchorElement = AnchorElement(href: url);
    anchorElement.download = name;
    anchorElement.click();
    bool status = true;
    return status;
    ;
  }
}
