Blob(List bytes) {
  print("I am from blob function ");
}

class Url {
  static createObjectUrlFromBlob(dynamic blob) {
    print('I am from createObjectUrlFromBlob function');
  }
}

class AnchorElement {
  String download = '';
  String href = '';
  AnchorElement({required this.href});
  click() {}
}
