import 'dart:typed_data';

class Converter {
  Uint8List getUint8List(List<Uint8List> x) {
    List<int> z = [for (var y in x) ...y];
    Uint8List a = Uint8List.fromList(z);
    return a;
  }
}
