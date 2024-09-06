// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:http/http.dart' as http;
//
// import '../main.dart';
// import '../server_side/show_online_user.dart';
// import '../user/current_user.dart';
// import '../user/users.dart';
// import 'choose_color_screen2.dart';
//
//
// class User1 {
//   final String username;
//   final String winningamount;
//   final String bettingamount;
//   //final String points;
//
//   const User1( {
//     required this.winningamount,
//     required this.bettingamount,
//     required this.username,
//     //  required this.points,
//   });
//
//   factory User1.fromJson(Map<String, dynamic> json) {
//     return User1(
//       username: 'User', // Adjust as needed
//       winningamount: json['winning_amount'],
//       bettingamount: json['betting_amount'],
//       //  points: 'assets/pawn.png', // Adjust as needed
//     );
//   }
// }
//
// class GameResultScreen extends StatefulWidget {
//   @override
//   _GameResultScreenState createState() => _GameResultScreenState();
//
// }
//
// class _GameResultScreenState extends State<GameResultScreen> {
//   late List<WebSocketChannel> _channels;
//   late String opponentName = '';
//   late Map<String, dynamic> userData = {};
//   late String playerName = '';
//   late String email = '';
//   late String playerImage = '';
//   late String opponentImage = '';
//   bool isDataLoaded = false;
//   final CurrentUser _currentUser = Get.put(CurrentUser());
//   final UserController userController = Get.find<UserController>();
//   List<User1> users = [];
//   Users currentUser = Get.find<CurrentUser>().users;
//
//   String? _userId;
//   String? _profilePicturePath;
//   String gameResult = 'Loading...';
//   String bettingAmount = '';
//
//
//   List<String> websocketUrls = [
//     'ws://192.168.1.14:3003',
//     // Add more WebSocket server URLs as needed
//   ];
//
//
//   @override
//   void initState() {
//     super.initState();
//     //fetchGameData();
//     loadUserData();
//     getGameResultMessage();
//     //fetchProfilePicturePath(currentUser.userId, currentUser.email);
//   }
//   //
//   // Future<void> fetchGameData() async {
//   //   final response = await http.get(Uri.parse('https://schmidivan.com/Esakki/ChessGame/fetch_online_game'));
//   //
//   //   if (response.statusCode == 200) {
//   //     final List<dynamic> data = jsonDecode(response.body);
//   //     setState(() {
//   //       users = data.map((json) => User1.fromJson(json)).toList();
//   //     });
//   //   } else {
//   //     throw Exception('Failed to load game data');
//   //   }
//   // }
//   Future<void> loadUserData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String name = _currentUser.users.name;
//     String? userDataString = prefs.getString('userData');
//
//     final String? opponent = await getOpponentName();
//     if (userDataString != null) {
//       setState(() {
//         playerName = userData['name'] ?? 'Player';
//         userData = jsonDecode(userDataString);
//       });
//     }
//     bettingAmount = prefs.getString('bettingAmount') ?? '0';
//     if (opponent != null ){
//       playerName=name;
//       opponentName = opponent; // Assign opponentName here
//       print('Loaded userData: $name');
//       print('Loaded opponent: $opponentName');
//       initializeWebSocket();
//       setState(() {
//         isDataLoaded = true;
//       });
//     } else {
//       print('image of user data null.');
//     }
//   }
//   // Future<void> loadUserData1() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   String? userDataString = prefs.getString('userData');
//   //   if (userDataString != null) {
//   //     setState(() {
//   //       // Decode JSON to a Map
//   //       Map<String, dynamic> userDataMap = jsonDecode(userDataString);
//   //       // Extract user_id from the Map
//   //       String? userId = userDataMap['user_id'];
//   //       if (userId != null) {
//   //         // Now you can use the userId in other methods
//   //         sendwinningAmountToDatabase(userId);
//   //       }
//   //     });
//   //     initializeWebSocket();
//   //   }
//   // }
//
//
//   void initializeWebSocket() {
//     _channels = websocketUrls.map((url) {
//       print('Connecting to WebSocket server with game screen : $url');
//       return IOWebSocketChannel.connect(url);
//     }).toList();
//
//     for (var channel in _channels) {
//       channel.stream.listen(
//             (message) {
//           String decodedMessage;
//           if (message is Uint8List) {
//             decodedMessage = utf8.decode(message);
//           } else if (message is String) {
//             decodedMessage = message;
//           } else {
//             print('Unsupported WebSocket message type: ${message.runtimeType}');
//             return;
//           }
//
//           print('Received WebSocket message: $decodedMessage');
//           handleWebSocketMessage1(decodedMessage);
//         },
//         onError: (error) {
//           print('WebSocket error: $error');
//         },
//         onDone: () {
//           print('WebSocket stream has been closed.');
//         },
//       );
//     }
//   }
//
//   Future<void> handleWebSocketMessage1(String message) async {
//     final decodedMessage = json.decode(message);
//     switch (decodedMessage['type']) {
//       case 'rematch_request':
//         final opponent = decodedMessage['opponent'] as String?;
//         if (opponent != null) {
//           _showRematchDialog(opponent, context);
//         } else {
//           print('Error: No opponent found in rematch request message');
//         }
//         break;
//       case 'rematch_response':
//         final response = decodedMessage['response'] as String?;
//         if (response != null) {
//           if (response == 'accepted') {
//             Navigator.push(context,MaterialPageRoute(builder: (context)=>ChooseColorScreen2()));
//           } else {
//             _showRejectionDialog(context);
//           }
//         } else {
//           print('Error: No response found in rematch response message');
//         }
//         break;
//     // case 'player_image':
//     //   final String? playerImage = decodedMessage['player_image'];
//     //   if (playerImage != null) {
//     //     setState(() {
//     //       this.opponentImage = opponentImage; // Update opponentImage
//     //     });
//     //   } else {
//     //     print('Error: No player image found in message');
//     //   }
//     //   break;
//     }
//   }
//
//   Future<String?> getOpponentName() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? opponent = prefs.getString('opponent');
//     print('$opponent: get here');
//     return opponent;
//   }
//   Future<String?> getProfilePicturePath() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('profile_picture_path');
//   }
//
//
//   void sendRematchRequest(String opponent) {
//     for (var channel in _channels) {
//       channel.sink.add(jsonEncode({
//         'type': 'rematch_request',
//         'sessionToken': userData['session_token'] ?? '',
//         'opponent': opponent,
//         'user_image':playerImage,
//       }));
//       print('Sent rematch request to $opponent');
//     }
//   }
//
//   void sendRematchResponse(String opponent, String response) {
//     if (opponent.isEmpty) {
//       print('Error: Opponent name is empty.');
//       return;
//     }
//
//     for (var channel in _channels) {
//       channel.sink.add(json.encode({
//         'type': 'rematch_response',
//         'response': response,
//         'opponent': opponent,
//         'sessionToken': userData['session_token'] ?? '',
//       }));
//     }
//   }
//
//   void _showRematchDialog(String opponent, BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) => AlertDialog(
//         title: Text("Rematch Request"),
//         content: Text("$opponent has requested a rematch. Do you accept?"),
//         actions: [
//           TextButton(
//             onPressed: () {
//               sendRematchResponse(opponent, 'accepted');
//               Navigator.push(context, MaterialPageRoute(builder: (context) => ChooseColorScreen2()));
//             },
//             child: Text("Accept"),
//           ),
//           TextButton(
//             onPressed: () {
//               sendRematchResponse(opponent, 'rejected');
//               Navigator.pop(context);
//             },
//             child: Text("Reject"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showRejectionDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) => AlertDialog(
//         title: Text("Rematch Rejected"),
//         content: Text("Your rematch request has been rejected."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlayOnline(bettingAmount: '', userData: {}, webSocketManager: webSocketManager,))),
//             child: Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }
//   // Future<void> fetchProfilePicturePath(String userId, String email) async {
//   //   try {
//   //     final response = await http.post(
//   //       Uri.parse('https://schmidivan.com/Esakki/ChessGame/fetch_profile_picture'),
//   //       body: {
//   //         'user_id': userId,
//   //         'email': email,
//   //       },
//   //     );
//   //
//   //     if (response.statusCode == 200) {
//   //       final Map<String, dynamic> responseData = jsonDecode(response.body);
//   //
//   //       // Check if the imagePath key exists in the response data
//   //       if (responseData.containsKey('imagePath')) {
//   //         final String imagePath = responseData['imagePath'];
//   //
//   //         // Assuming imagePath contains the file name only, concatenate it with the base URL
//   //         const String baseUrl = 'https://schmidivan.com/Esakki/ChessGame/';
//   //         final String imageUrl = baseUrl + imagePath;
//   //
//   //         setState(() {
//   //           _userId = userId;
//   //           _profilePicturePath = imageUrl; // Update _profilePicturePath with the complete URL
//   //           userController.setProfilePicturePath(imageUrl);
//   //           // Update the player profile image URL if needed
//   //           playerImage = imageUrl;
//   //         });
//   //       } else {
//   //         // Handle case where no image path is found
//   //         setState(() {
//   //           _userId = null;
//   //           _profilePicturePath = playerImage; // Set _profilePicturePath to null or a default image URL
//   //           userController.setProfilePicturePath('');
//   //           playerImage = 'assets/c3.png';
//   //         });
//   //       }
//   //     } else {
//   //       throw Exception('Failed to fetch image data');
//   //     }
//   //   } catch (e) {
//   //     print('Error fetching image: $e');
//   //   }
//   // }
//   String getGameResultMessage() {
//     // Retrieve the selected color from SharedPreferences
//     String? selectedColor = prefs.getString('selected_color')?.toLowerCase() ?? 'unknown'; // Default to 'unknown' if null
//     String? result = prefs.getString('game_result')?.toLowerCase() ?? 'unknown'; // Default to 'unknown' if null
//
//     // Set gameResult state
//     setState(() {
//       gameResult = result;
//     });
//
//     // Debugging output
//     print('Game Result: $result');
//     print('Selected Color: $selectedColor');
//
//     // Determine the message based on the game result
//     if (gameResult == 'draw') {
//       String? userDataString = prefs.getString('userData');
//       if (userDataString != null) {
//         setState(() {
//           // Decode JSON to a Map
//           Map<String, dynamic> userDataMap = jsonDecode(userDataString);
//           // Extract user_id from the Map
//           String? userId = userDataMap['user_id'];
//           if (userId != null) {
//             // Now you can use the userId in other methods
//             senddrowAmountToDatabase(userId);
//             print("winning amount sended");
//           }
//         });
//       }
//       return 'It\'s a Draw!';
//     } else if (gameResult.contains('wins')) {
//       // Check if the selected color matches the winning color
//       if ((selectedColor == 'black' && gameResult.contains('black')) ||
//           (selectedColor == 'white' && gameResult.contains('white'))) {
//         String? userDataString = prefs.getString('userData');
//         if (userDataString != null) {
//           setState(() {
//             // Decode JSON to a Map
//             Map<String, dynamic> userDataMap = jsonDecode(userDataString);
//             // Extract user_id from the Map
//             String? userId = userDataMap['user_id'];
//             if (userId != null) {
//               // Now you can use the userId in other methods
//               sendwinningAmountToDatabase(userId);
//               print("winning amount sended");
//             }
//           });
//         }
//
//         return 'You Win!';
//       } else {
//         print("lose1");
//         return 'You Lose!';
//       }
//     } else {
//       print("lose2");
//       return 'You Lose!';
//     }
//   }
//   Future<void> sendwinningAmountToDatabase(String userId) async {
//     const url = 'https://schmidivan.com/senthil/_ChessGame/ending_winning_amount';
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedBettingAmount = prefs.getString('bettingAmount');
//
//     if (storedBettingAmount == null) {
//       print('No betting amount found in SharedPreferences.');
//       return;
//     }
//
//     final originalAmount = double.parse(storedBettingAmount.split(' ')[0]);
//     final discountedAmount = (originalAmount - (originalAmount * 0.15)) * 2; // Applying 15% discount and multiplying by 2
//
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         body: {
//           'user_id': userId,
//           'betting_amount': discountedAmount.toString(),
//         },
//       );
//
//       if (response.statusCode == 200) {
//         print('Game data sent successfully: $email, $discountedAmount');
//       } else {
//         print('Failed to send game data. HTTP status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error sending game data: $e');
//     }
//   }
//
//
//   Future<void> senddrowAmountToDatabase(String userId) async {
//     const url = 'https://schmidivan.com/senthil/_ChessGame/ending_winning_amount';
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedBettingAmount = prefs.getString('bettingAmount');
//
//     if (storedBettingAmount == null) {
//       print('No betting amount found in SharedPreferences.');
//       return;
//     }
//
//     final originalAmount = double.parse(storedBettingAmount.split(' ')[0]);
//     final discountedAmount = originalAmount * 0.50;
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         body: {
//           'user_id': userId,
//           'betting_amount': discountedAmount.toString(),
//         },
//       );
//
//       if (response.statusCode == 200) {
//         print('Game data sent successfully: $email, $discountedAmount');
//       } else {
//         print('Failed to send game data. HTTP status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error sending game data: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: isDataLoaded
//           ? Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/Designer.jpeg'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 getGameResultMessage(),
//                 style: TextStyle(
//                   fontSize: 40,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//
//                 children: [
//                   PlayerProfile(
//                     name: playerName,
//                     //image:playerImage,
//                   ),
//                   SizedBox(width: 40),
//                   PlayerProfile(
//                     name: opponentName,
//                     // image: playerImage,
//
//                   ),
//                 ],
//               ),
//               // SizedBox(height: 40), CircleAvatar(
//               //   radius: 50.0,
//               //   backgroundImage: _profilePicturePath != null
//               //       ? NetworkImage(_profilePicturePath!)
//               //       : AssetImage('assets/c3.png') as ImageProvider,
//               // ),
//
//               ElevatedButton(
//                 onPressed: () {
//                   sendRematchRequest(opponentName); // Call your function here
//                   // Add any other logic you need
//                 },
//                 child: Text('Rematch'),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pushReplacement(
//                     MaterialPageRoute(builder: (context) => PlayOnline(bettingAmount: '', userData: {}, webSocketManager: webSocketManager,)),
//                   );
//                 },
//                 child: Text('exit'),
//               ),
//             ],
//           ),
//         ),
//       )
//           : Center(child: CircularProgressIndicator()),
//     );
//   }
// }
//
// class PlayerProfile extends StatelessWidget {
//   final String name;
//   //final String image;
//
//   PlayerProfile({
//     required this.name,
//     //required this.image,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // CircleAvatar(
//         //   radius: 50,
//         //   backgroundImage: AssetImage(image.isNotEmpty ? image : 'assets/c3.png'),
//         // ),
//         // SizedBox(height: 10),
//         Text(
//           name,
//           style: TextStyle(
//             fontSize: 20,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
// }