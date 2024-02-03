import 'dart:convert';

List<Users> welcomeFromJson(String str) =>
    List<Users>.from(json.decode(str).map((x) => Users.fromJson(x)));

String welcomeToJson(List<Users> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Users {
  String name;
  String email;
  String mobile;
  String password;
 // String sessionToken;
  Users({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
   // required this.sessionToken,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
    password: json["password"],
   // sessionToken: json["session_token"]
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "mobile": mobile,
    "password": password,
   // "session_token":sessionToken,
  };
}
