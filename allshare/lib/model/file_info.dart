class FileInfo {
  String? name;
  String? extn;
  int? totalChunk;
  bool isLastChunk = false;

  FileInfo({this.name, this.extn, this.totalChunk, required this.isLastChunk});

  //Map data to Json
  Map<String, dynamic> toJson() => {
        'name': name,
        'extn': extn,
        'totalChunk': totalChunk,
        'isLastChunk': isLastChunk,
      };

  //Json data to Object data
  factory FileInfo.fromJson(Map<String, dynamic> json) => FileInfo(
        name: json['name'],
        extn: json['extn'],
        totalChunk: json['totalChunk'],
        isLastChunk: json['isLastChunk'],
      );
}
