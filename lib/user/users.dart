import 'dart:convert';

List<Users> welcomeFromJson(String str) =>
    List<Users>.from(json.decode(str).map((x) => Users.fromJson(x)));

String welcomeToJson(List<Users> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Users {
 // String id;
  String userId;
  String name;
  String email;
  String mobile;
  String password;
  String sessionToken;
  String imagePath;
  Users({
    //required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.sessionToken,
    required this.imagePath,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
    // name: json["name"],
    // email: json["email"],
    // mobile: json["mobile"],
    // password: json["password"],
    // sessionToken: json["session_token"]
   // id: json["id"],
    userId: json["user_id"] ?? "",
    name: json["name"] ?? "",
    email: json["email"] ?? "",
    mobile: json["mobile"] ?? "",
    password: json["password"] ?? "",
    sessionToken: json["session_token"] ?? "",
    imagePath: json["image_path"] ?? "",
  );

  Map<String, dynamic> toJson() => {
   // "id":id,
    "user_id": userId,
    "name": name,
    "email": email,
    "mobile": mobile,
    "password": password,
    "session_token":sessionToken,
    "image_path":imagePath,
  };
}

