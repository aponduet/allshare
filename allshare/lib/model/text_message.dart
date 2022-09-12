class TextMessage {
  String? sms;
  String? date;
  String? name;
  int? id;
  bool
      isFileInfo; // This is used to seperate Media Information text and Normal Messate text in Onmessage function

  TextMessage(
      {this.sms, this.date, this.name, this.id, required this.isFileInfo});

  //Map data to Json
  Map<String, dynamic> toJson() => {
        'sms': sms,
        'date': date,
        'name': name,
        'id': id,
        'isFileInfo': isFileInfo,
      };

  //Json data to Object data
  factory TextMessage.fromJson(Map<String, dynamic> json) => TextMessage(
        sms: json['sms'],
        date: json['date'],
        name: json['name'],
        id: json['id'],
        isFileInfo: json['isFileInfo'],
      );
}
