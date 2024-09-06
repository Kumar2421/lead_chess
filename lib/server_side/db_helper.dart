// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
// import 'package:mysql1/mysql1.dart';
//
// Future<List<String>> getOnlineUsers() async {
//   final response = await http.get(Uri.parse('http://your-server-url/get_online_users.php'));
//
//   if (response.statusCode == 200) {
//     final List<dynamic> jsonResult = json.decode(response.body);
//     return jsonResult.map((dynamic user) => user['name'] as String).toList();
//   } else {
//     throw Exception('Failed to fetch online users');
//   }
// }
// MySqlConnection dbConnection =  MySqlConnection.connect(ConnectionSettings(
// host: '127.0.0.1',
// port: 3306,
// user: 'root',
// db: 'id21287285_esakki',
// password: '',
// )) as MySqlConnection;