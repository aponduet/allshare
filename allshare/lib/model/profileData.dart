class ProfileData {
  String? name;
  String? id;
  bool? status = false;
  ProfileData({this.name, this.id, this.status});

  //Map data to Json
  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'status': status,
      };

  //Json data to Object data
  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
        name: json['name'],
        id: json['id'],
        status: json['status'],
      );
}
