// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import '../engine/choose_color_screen.dart';
// import '../engine/choose_color_screen2.dart';
// import '../engine/timer.dart';
// import '../main.dart';
// import '../server_side/websocket_manager.dart';
// import '../games/play_local.dart';
//
//
// class OnlineUser {
//   final String username;
//   final String uniqueId;
//
//   OnlineUser(this.username, this.uniqueId);
// }
//
// class PlayOnline extends StatefulWidget {
//   const PlayOnline({Key? key}) : super(key: key);
//
//   @override
//   _PlayOnlineState createState() => _PlayOnlineState();
// }
//
// class _PlayOnlineState extends State<PlayOnline> {
//   late WebSocketChannel _channel;
//   List<OnlineUser> onlineUsers = [];
//   late Map<String, dynamic> userData = {};
//   Map<String, bool> listeningStatus = {};
//
//   @override
//   void initState() {
//     super.initState();
//     loadUserData();
//   }
//
//   Future<void> loadUserData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? userDataString = prefs.getString('userData');
//     if (userDataString != null) {
//       setState(() {
//         userData = jsonDecode(userDataString);
//       });
//       initializeWebSocket();
//     }
//   }
//
//   void initializeWebSocket() async {
//     _channel = IOWebSocketChannel.connect('ws://192.168.29.1:3006');
//
//     _channel.stream.listen(
//           (message) {
//         print('Received WebSocket message: $message');
//         handleWebSocketMessage(message);
//       },
//       onError: (error) {
//         print('WebSocket error: $error');
//       },
//       onDone: () {
//         print('WebSocket stream has been closed.');
//       },
//     );
//
//     // Send authentication message to server
//     _channel.sink.add(json.encode({
//       'type': 'authenticate',
//       'sessionToken': userData['session_token'] ?? '',
//     }));
//   }
//   void handleWebSocketMessage(String message) {
//     final decodedMessage = json.decode(message);
//     print('Received WebSocket message: $decodedMessage');
//     switch (decodedMessage['type']) {
//       case 'online_users':
//         setState(() {
//           onlineUsers = (decodedMessage['usernames'] as List<dynamic>)
//               .map((username) => OnlineUser(username, ''))
//               .toList();
//         });
//         print('Online Users: $onlineUsers');
//         break;
//       case 'match_found':
//         handleMatchFound();
//         break;
//       case 'user_connected':
//         final connectedUserId = decodedMessage['data']['id'];
//         final connectedUserName = decodedMessage['data']['name'];
//         print('User with id $connectedUserId and name $connectedUserName has connected');
//         break;
//       case 'welcome':
//       // Handle the welcome message
//         final welcomeMessage = decodedMessage['message'];
//         print('Received welcome message: $welcomeMessage');
//         break;
//       case 'user_disconnected':
//         final disconnectedUserId = decodedMessage['data'];
//         print('User with id $disconnectedUserId has disconnected');
//         break;
//       default:
//         print('Unknown WebSocket message type: ${decodedMessage['type']}');
//     }
//   }
//
//
//
//   void handleMatchFound() {
//     final shuffledOnlineUsers = List.of(onlineUsers)..shuffle();
//     final matchUsers = shuffledOnlineUsers.take(2).map((user) {
//       return {
//         'id': user.uniqueId,
//         'name': user.username,
//       };
//     }).toList();
//
//     // Check if the matchUsers list contains two users
//     if (matchUsers.length == 2) {
//       // Navigate to the game board screen with the matched users
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ChooseColorScreen2(matchUsers),
//         ),
//       );
//     } else {
//       print('Match found but unable to start game: Insufficient players');
//     }
//   }
//
//
//
//   void startMatchmaking() {
//     _channel.sink.add(json.encode({
//       'type': 'start_matchmaking',
//       'sessionToken': userData['session_token'] ?? '',
//     }));
//   }
//
//   @override
//   void dispose() {
//     _channel.sink.close();
//     super.dispose();
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Play Online'),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: startMatchmaking,
//             child: Text('Start Matchmaking'),
//           ),
//           SizedBox(height: 20),
//           Text(
//             'Online Users:',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 10),
//           Expanded(
//             child: ListView.builder(
//               itemCount: onlineUsers.length,
//               itemBuilder: (context, index) {
//                 final OnlineUser user = onlineUsers[index];
//                 if (user.uniqueId == userData['uniqueId']) {
//                   // Skip displaying your own name
//                   return SizedBox.shrink();
//                 }
//                 return ListTile(
//                   title: Text(user.username),
//                   onTap: () {
//                     _channel.sink.add(json.encode({
//                       'type': 'join_matchmaking',
//                       'sessionToken': userData['session_token'] ?? '',
//                       'uniqueId': user.uniqueId,
//                     }));
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:mysql1/mysql1.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
//
// final Map<String, WebSocket> onlinePlayers = {};
// final List<String> matchmakingQueue = [];
// final Map<String, User> userSessions = {};
// late MySqlConnection dbConnection;
//
//
// Future<void> main() async {
//   try {
//     dbConnection = await _initializeDbConnection();
//
//     final server = await HttpServer.bind('192.168.29.1', 3006);
//     print('Server running on port ${server.port}');
//
//     server.listen((HttpRequest request) {
//       if (WebSocketTransformer.isUpgradeRequest(request)) {
//         handleWebSocket(request);
//       } else {
//         handleHttpRequest(request);
//       }
//     });
//
//     // Start the matchmaking process
//     startMatchmaking();
//   } catch (e) {
//     print('Error connecting to MySQL: $e');
//   }
// }
//
// Future<MySqlConnection> _initializeDbConnection() async {
//   final settings = ConnectionSettings(
//     host: 'localhost',
//     port: 3306,
//     user: 'root',
//     db: 'id21287285_esakki',
//   );
//   final connection = await MySqlConnection.connect(settings);
//   print('Connected to MySQL database');
//   return connection;
// }
// void handleClientMessage(String username, Map<String, dynamic> receivedMessage) {
//   final messageType = receivedMessage['type'] as String?;
//
//   print('Received message type: $messageType');
//
//   switch (messageType) {
//     case 'echo':
//       handleEchoMessage(username, receivedMessage);
//       break;
//     case 'join_matchmaking':
//       addToMatchmakingQueue(username);
//       break;
//     case 'start_matchmaking':
//       startMatchmaking();
//       break;
//   // Add more message type handling as needed
//   }
// }
//
//
// void handleEchoMessage(String username, Map<String, dynamic> message) {
//   final echoMessage = message['message'] as String?;
//   if (echoMessage != null) {
//     final webSocket = onlinePlayers[username];
//     if (webSocket != null) {
//       webSocket.add(json.encode({'type': 'echo', 'message': echoMessage}));
//       print('Sent echo message to $username: $echoMessage');
//     } else {
//       print('Error: WebSocket not found for user $username');
//     }
//   } else {
//     print('Error: No echo message provided');
//   }
// }
//
//
//
// void addToMatchmakingQueue(String username) {
//   if (!matchmakingQueue.contains(username)) {
//     matchmakingQueue.add(username);
//     print('Player $username joined matchmaking queue');
//     tryStartMatch();
//   }
// }
//
// void tryStartMatch() {
//   if (matchmakingQueue.length >= 2) {
//     final player1 = matchmakingQueue.removeAt(0);
//     final player2 = matchmakingQueue.removeAt(0);
//     startGameSession(player1, player2);
//   }
// }
//
// void startGameSession(String player1, String player2) {
//   // Create a new game session for the matched players
//   final gameSession = GameSession(player1, player2);
//   gameSession.start();
//
//   // Notify the players about the match
//   onlinePlayers[player1]?.add(json.encode({'type': 'match_found', 'opponent': player2}));
//   onlinePlayers[player2]?.add(json.encode({'type': 'match_found', 'opponent': player1}));
// }
//
// void startMatchmaking() {
//   // Periodically check the matchmaking queue and start matches
//   Timer.periodic(const Duration(seconds: 10), (timer) {
//     tryStartMatch();
//   });
// }
//
// void handleWebSocket(HttpRequest request) {
//   WebSocketTransformer.upgrade(request).then((WebSocket webSocket) {
//     // Handle incoming messages
//     webSocket.listen(
//           (data) {
//         try {
//           final message = json.decode(data as String);
//           final sessionToken = message['sessionToken'] as String?;
//           if (sessionToken != null) {
//             handleWebSocketConnection(webSocket, message, sessionToken);
//           } else {
//             print('Session token not provided. Closing connection.');
//             webSocket.close();
//           }
//         } catch (e) {
//           print('Error decoding message: $e');
//         }
//       },
//       onError: (error) {
//         print('WebSocket error: $error');
//       },
//       onDone: () {
//         // Handle WebSocket disconnection
//         final username = getPlayerNameByWebSocket(webSocket);
//         if (username != null) {
//           final sessionToken = userSessions[username]?.sessionToken; // Retrieve session token
//           if (sessionToken != null) {
//             handleWebSocketDisconnection(username, sessionToken);
//           } else {
//             print('Error: Session token not found for $username');
//           }
//         } else {
//           print('Error: User session not found for the disconnected WebSocket');
//         }
//       },
//     );
//   });
// }
//
//
// // void handleWebSocketMessages(WebSocket webSocket, User user) {
// //   webSocket.listen((data) {
// //     final receivedMessage = json.decode(data);
// //     // Update user's last activity time on message handling
// //     user.lastActivity = DateTime.now().millisecondsSinceEpoch;
// //     handleClientMessage(user.username, receivedMessage);
// //     print("recived");
// //   }, onError: (error) {
// //     print('WebSocket error: $error');
// //   }, onDone: () {
// //     // Handle WebSocket disconnection
// //     handleWebSocketDisconnection(user.username, user.sessionToken);
// //   });
// // }
// void handleWebSocketConnection(WebSocket webSocket, Map<String, dynamic> message, String sessionToken) async {
//   print('Incoming message: $message');
//
//   // Authenticate user using session token obtained from the client's message
//   final user = await authenticateUser(sessionToken);
//
//   if (user != null) {
//     print('User authenticated: ${user.username}');
//     // Store the user session with the session token
//     userSessions[user.username] = user;
//     print('User session stored: ${user.username}');
//
//     // Store the WebSocket for the user
//     onlinePlayers[user.username] = webSocket;
//     print('Online players: $onlinePlayers');
//
//     // Call handleClientMessage to start listening for messages
//     handleClientMessage(user.username, message);
//
//     // Update user's last activity time
//     user.lastActivity = DateTime.now().millisecondsSinceEpoch;
//
//     // Notify the server that the player is online
//     updateOnlineStatus(user.username, true);
//     broadcastOnlineUsers();
//
//     // Send a welcome message to the client
//     if (webSocket.readyState == WebSocket.open) {
//       // Check if the WebSocket is open
//       webSocket.add(json.encode({'type': 'welcome', 'message': 'Welcome, ${user.username}!'}));
//     }
//   } else {
//     print('Failed to authenticate user with session token: $sessionToken');
//     if (webSocket.readyState == WebSocket.open) {
//       // Check if the WebSocket is open
//       webSocket.add(json.encode({'type': 'authentication_failed', 'message': 'Invalid session token'}));
//       await webSocket.close();
//     }
//   }
// }
//
//
//
// // Server-Side Code Modifications
// void handleWebSocketDisconnection(String username, String sessionToken) async {
//   final webSocketChannel = onlinePlayers[username];
//   if (webSocketChannel != null) {
//     final user = userSessions[username]; // Use username to retrieve user session
//     if (user != null) {
//       print('Player disconnected: $username');
//       user.lastActivity = DateTime.now().millisecondsSinceEpoch;
//       // Update user's online status
//       updateOnlineStatus(username, false);
//       // Broadcast updated list of online users
//       broadcastOnlineUsers();
//       try {
//         await webSocketChannel.close(); // Close the WebSocket channel
//         print('WebSocket channel closed for user: $username');
//         // Remove the user session using the username
//         userSessions.remove(username);
//         print('User $username is offline');
//       } catch (e) {
//         print('Error closing WebSocket channel: $e');
//       }
//     } else {
//       print('Error: User session not found for $username');
//     }
//   } else {
//     print('Error: WebSocket channel not found for $username');
//   }
// }
//
//
//
// Future<bool> isWebSocketChannelOpen(WebSocketChannel webSocketChannel) async {
//   try {
//     await webSocketChannel.stream.first;
//     return true; // WebSocket is open
//   } catch (e) {
//     return false; // WebSocket is closed
//   }
// }
//
// Future<User?> authenticateUser(String sessionToken) async {
//   try {
//     final results = await dbConnection.query(
//       'SELECT name, session_token FROM chess_user WHERE session_token = ?',
//       [sessionToken],
//     );
//
//     print('Authentication Results: $results');
//
//     if (results.isNotEmpty) {
//       final row = results.first;
//       return User(row['name'], row['session_token']);
//     }
//   } catch (e) {
//     print('Database error during authentication: $e');
//   }
//
//   return null;
// }
//
// void handleHttpRequest(HttpRequest request) {
//   request.response.write('Welcome to the chess server!');
//   request.response.close();
// }
//
// void broadcastOnlineUsers() {
//   final onlineUsernames = userSessions.values
//       .where((user) => onlinePlayers.containsKey(user.username))
//       .map((user) => user.username)
//       .toList();
//
//   final message = {'type': 'online_users', 'usernames': onlineUsernames};
//
//   final channelsToSend = List.from(onlinePlayers.values);
//
//   print('Broadcasting online users: $onlineUsernames');
//
//   for (final channel in channelsToSend) {
//     try {
//       channel.add(json.encode(message));
//       print('Online users message sent to channel: $channel');
//     } catch (error) {
//       print('Error sending online users message to channel: $error');
//     }
//   }
// }
//
//
// void updateOnlineStatus(String username, bool isOnline) async {
//   try {
//     await dbConnection.query(
//       'UPDATE chess_user SET is_online = ? WHERE name = ?',
//       [isOnline ? 1 : 0, username],
//     );
//
//     print('User $username is ${isOnline ? 'online' : 'offline'}');
//   } catch (e) {
//     print('Error updating online status: $e');
//   }
// }
//
// String? getPlayerNameByWebSocket(WebSocket webSocket) {
//   for (var entry in onlinePlayers.entries) {
//     if (entry.value == webSocket) {
//       return entry.key;
//     }
//   }
//   return null;
// }
//
// class User {
//   final String username;
//   final String sessionToken;
//   int? lastActivity;
//
//   User(this.username, this.sessionToken);
// }
//
// class GameSession {
//   final String player1;
//   final String player2;
//
//   GameSession(this.player1, this.player2);
//
//   void start() {
//     // Implement game session initialization logic here
//     // For example, start a new chess game between player1 and player2
//   }
// }
// import 'dart:async';
// import 'dart:convert';
// import 'package:carousel_slider/carousel_controller.dart';
// import 'package:chess_game/games/tournament/registration.dart%20';
// import 'package:flutter/material.dart';
// import '../server_side/server.dart';
// import '../server_side/show_online_user.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:chess_game/buttons/back_button.dart';
// import 'package:chess_game/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//
// Future<void> clipbordExample() async {
//   ClipboardData? data = await Clipboard.getData('text/plain');
//   String? text = data?.text;
//   const helloMsg = ClipboardData(text: "hello flutter");
//   await Clipboard.setData(helloMsg);
//   bool hasText = await Clipboard.hasStrings();
// }
//
// class PlayOnline1 extends StatefulWidget {
//   final String bettingAmount;
//
//   final Map<String, dynamic> userData;
//
//   const PlayOnline1({Key? key, required this.bettingAmount, required this.userData}) : super(key: key);
//
//   @override
//   _PlayOnlineState createState() => _PlayOnlineState();
// }
//
// class _PlayOnlineState extends State<PlayOnline1> with TickerProviderStateMixin {
//   int activeIndex = 0;
//   CarouselController buttonCarouselController = CarouselController();
//
//   final _items = [
//     Colors.blue,
//     Colors.yellow,
//     Colors.green,
//     Colors.pink,
//   ];
//   final _pageController = PageController();
//   final _pageController2 = PageController();
//   final _currentPageNotifier = ValueNotifier<int>(0);
//   final _currentPageNotifier2 = ValueNotifier<int>(0);
//   final _boxHeight = 150.0;
//
//   List<User1> users = [
//     const User1(username: '100 Coins', place: 'winning amount: 170', points: 'assets/pawn.png'),
//     const User1(username: '200 Coins', place: 'winning amount: 340', points: 'assets/bishop.png'),
//     const User1(username: '500 Coins', place: 'winning amount: 850', points: 'assets/knight1.png'),
//     const User1(username: '1000 Coins', place: 'winning amount: 1700', points: 'assets/rook1.png'),
//     const User1(username: '2000 Coins', place: 'winning amount: 3400', points: 'assets/queen.png'),
//     const User1(username: '5000 Coins', place: 'winning amount: 4250', points: 'assets/piece.png'),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: color.navy1,
//         automaticallyImplyLeading: false,
//         leading: const ArrowBackButton(color: Colors.white),
//         title: Padding(
//           padding: EdgeInsets.only(right: screenWidth / 10),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     'PLAY ',
//                     style: GoogleFonts.oswald(color: Colors.white, fontSize: screenWidth / 20, fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     'ONLINE',
//                     style: GoogleFonts.oswald(fontSize: screenWidth / 20, fontWeight: FontWeight.bold, color: Colors.amberAccent),
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                 child: Container(
//                   height: screenHeight / 400,
//                   width: screenWidth / 5,
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.white, Colors.amber, Colors.white],
//                       begin: Alignment.bottomLeft,
//                       end: Alignment.topRight,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Container(
//         height: screenHeight / 1,
//         width: screenWidth / 1,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/checked-background.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Container(
//           height: screenHeight / 1,
//           width: screenWidth / 1,
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage('assets/play-online2.png'),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: Column(
//             children: [
//               SizedBox(height: screenHeight / 10),
//               Padding(
//                 padding: const EdgeInsets.only(right: 4.0, left: 4.0),
//                 child: Stack(
//                   alignment: Alignment.bottomCenter,
//                   children: [
//                     CarouselSlider(
//                       items: users.map((user) {
//                         List<Gradient> containerGradients = [
//                           const RadialGradient(
//                             colors: [Colors.red, Colors.brown, Colors.red],
//                             radius: 1.75,
//                           ),
//                           const LinearGradient(
//                             colors: [Colors.blue, Colors.green, Colors.blue],
//                             begin: Alignment.centerLeft,
//                             end: Alignment.centerRight,
//                           ),
//                           const LinearGradient(
//                             colors: [Colors.orange, Colors.pink, Colors.orange],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           const RadialGradient(
//                             colors: [Colors.blue, Colors.purple],
//                             radius: 2.75,
//                           ),
//                         ];
//                         Gradient containerGradient = containerGradients[users.indexOf(user) % containerGradients.length];
//                         return GestureDetector(
//                           onTap: () {
//                             try {
//                               final bettingAmount = user.username; // Assuming user.username already contains the correct name
//                               updateBettingAmount(user.username, bettingAmount); // Call updateBettingAmount with the correct parameters
//                               print('Selected Betting Amount: $bettingAmount');
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => PlayOnline(bettingAmount: bettingAmount)),
//                               );
//                             } catch (e) {
//                               print('Error updating betting amount: $e');
//                             }
//                           },
//
//
//                           child: Container(
//                             height: screenHeight / 2.5,
//                             width: screenWidth / 1.3,
//                             decoration: BoxDecoration(
//                               gradient: containerGradient,
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: color.navy.withOpacity(0.55), width: 10.0),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(10.0),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     user.username,
//                                     style: GoogleFonts.oswald(
//                                       color: Colors.white,
//                                       fontSize: screenWidth / 25,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     user.place,
//                                     style: const TextStyle(fontSize: 13, color: Colors.white),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Image(
//                                     image: AssetImage(user.points),
//                                     height: screenHeight / 10,
//                                     width: screenWidth / 10,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                       carouselController: buttonCarouselController,
//                       options: CarouselOptions(
//                         onPageChanged: (index, reason) {
//                           setState(() {});
//                         },
//                         initialPage: 0,
//                         enlargeCenterPage: true,
//                         autoPlayCurve: Curves.easeInOut,
//                         enableInfiniteScroll: true,
//                         autoPlayAnimationDuration: const Duration(milliseconds: 300),
//                         aspectRatio: 16 / 9,
//                         viewportFraction: 0.8,
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 80,
//                       right: 0,
//                       left: 0,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           GestureDetector(
//                             onTap: () => buttonCarouselController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.linear),
//                             child: Image(
//                               image: const AssetImage('assets/arrowb1.png'),
//                               height: screenHeight / 20,
//                               width: screenWidth / 15,
//                               color: Colors.orange,
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () => buttonCarouselController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.linear),
//                             child: Image(
//                               image: const AssetImage('assets/arrowf1.png'),
//                               height: screenHeight / 20,
//                               width: screenWidth / 15,
//                               color: Colors.orange,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 100),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
