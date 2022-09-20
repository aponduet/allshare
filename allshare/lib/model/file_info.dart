class FileInfo {
  String? name;
  String? extn;
  int totalChunk;
  bool isLastChunk;
  bool isFirstChunk;
  bool isFileInfo;
  String? textmessage;

  FileInfo(
      {this.name,
      this.extn,
      required this.totalChunk,
      required this.isLastChunk,
      required this.isFirstChunk,
      required this.isFileInfo,
      this.textmessage});

  //Map data to Json
  Map<String, dynamic> toJson() => {
        'name': name,
        'extn': extn,
        'totalChunk': totalChunk,
        'isLastChunk': isLastChunk,
        'isFileInfo': isFileInfo,
        'textmessage': textmessage,
        'isFirstChunk': isFirstChunk,
      };

  //Json data to Object data
  factory FileInfo.fromJson(Map<String, dynamic> json) => FileInfo(
        name: json['name'],
        extn: json['extn'],
        totalChunk: json['totalChunk'],
        isLastChunk: json['isLastChunk'],
        isFileInfo: json['isFileInfo'],
        textmessage: json['textmessage'],
        isFirstChunk: json['isFirstChunk'],
      );
}
