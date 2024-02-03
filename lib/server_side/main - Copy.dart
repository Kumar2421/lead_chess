// // main.dart or client.dart
//
// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'websocket_manager.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   late WebSocketManager webSocketManager;
//   late SharedPreferences prefs; // SharedPreferences instance
//
//   @override
//   void initState() {
//     super.initState();
//     webSocketManager = WebSocketManager('ws://192.168.29.228:5000');
//     initializeWebSocketManager();
//   }
//
//   void initializeWebSocketManager() async {
//     prefs = await SharedPreferences.getInstance(); // Initialize SharedPreferences
//     String sessionToken = prefs.getString('sessionToken') ?? ''; // Retrieve session token from local storage
//     await webSocketManager.init();
//     // Send user information to the server upon initialization
//     webSocketManager.send(json.encode({'type': 'user_info', 'sessionToken': sessionToken}));
//   }
//
//   @override
//   void dispose() {
//     webSocketManager.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('WebSocket Example'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             if (webSocketManager != null && webSocketManager.isInitialized) {
//               // Send a test message to the server
//               webSocketManager.send(json.encode({'type': 'test_message'}));
//             } else {
//               print('WebSocket manager not initialized');
//             }
//           },
//           child: Text('Send Test Message'),
//         ),
//       ),
//     );
//   }
// }