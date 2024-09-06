import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:mysql1/mysql1.dart';

final Map<String, WebSocket> onlinePlayers = {};
final List<String> matchmakingQueue = [];
final Map<String, User> userSessions = {};
late MySqlConnection dbConnection;
final Map<String, GameSession> gameSessions = {};
final Set<String> activePlayers = {};
final Set<String> matchedPlayers = {}; // Define it globally

final Map<String, DateTime> playerLastActivity = {};
const Duration pongTimeout = Duration(seconds: 80);


const String authUrl = 'https://schmidivan.com/Esakki/ChessGame/authentication';
const String onlineStatusUrl = 'https://schmidivan.com/Esakki/ChessGame/onlinestatus';
final List<int> dartServerPorts = [3003];

Future<void> main() async {
  for (var port in dartServerPorts) {
    await runWebSocketServer(port);
  }
}

Future<void> runWebSocketServer(int port) async {
  try {
    final server = await HttpServer.bind('0.0.0.0',port);
    print('Dart WebSocket server running on port $port');

    // Print server IP address
    final ipAddresses = await _getLocalIPAddresses();
    print('Server IP addresses: ${ipAddresses.join(', ')}');

    server.listen((HttpRequest request) async {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        handleWebSocket(request);
        //startPeriodicCleanup();
        if (request.uri.path == '/ws') {
          WebSocket socket = await WebSocketTransformer.upgrade(request);
          //handleping(socket);

        }
      } else {
        handleHttpRequest(request);
      }
    });

    startMatchmaking();
  } catch (e) {
    print('Error connecting to MySQL: $e');
  }
}

Future<List<String>> _getLocalIPAddresses() async {
  final interfaces = await NetworkInterface.list();
  List<String> ipAddresses = [];
  for (var interface in interfaces) {
    for (var address in interface.addresses) {
      if (address.type == InternetAddressType.IPv4) {
        ipAddresses.add(address.address);
      }
    }
  }
  return ipAddresses;
}

void handleHttpRequest(HttpRequest request) {
  request.response
    ..statusCode = HttpStatus.forbidden
    ..write('WebSocket connections only')
    ..close();
}

void handleWebSocket(HttpRequest request) {
  WebSocketTransformer.upgrade(request).then((WebSocket webSocket) {
    print('New WebSocket connection established.');

    webSocket.listen(
          (dynamic data) {
        try {
          String decodedData;

          if (data is String) {
            // Handle string messages directly
            decodedData = data;
          } else if (data is List<int>) {
            // Handle binary data
            decodedData = utf8.decode(data); // Convert List<int> to String
          } else {
            print('Unsupported data type: ${data.runtimeType}');
            return;
          }

          print('Received message: $decodedData');

          final Map<String, dynamic> message = json.decode(decodedData);
          final sessionToken = message['sessionToken'] as String?;

          if (sessionToken != null) {
            handleWebSocketConnection(webSocket, message, sessionToken);
          } //else {
          //   print('Session token not provided. Closing connection.');
          //   //webSocket.close();
          // }
        } catch (e) {
          print('Error decoding message: $e');
          //webSocket.close();
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        final username = getPlayerNameByWebSocket(webSocket);
        if (username != null) {
          final sessionToken = userSessions[username]?.sessionToken;
          if (sessionToken != null) {
            handleWebSocketDisconnection(username, sessionToken);
          } else {
            print('Error: Session token not found for $username');
          }
        } //else {
        //print('Error: User session not found for the disconnected WebSocket');
        //}
      },
    );

    // Optionally send an acknowledgment message
    webSocket.add(utf8.encode(json.encode({'type': 'connection_success', 'message': 'Dart server connected to proxy.'})));
  });
}

void handleEchoMessage(String username, Map<String, dynamic> message) {
  final echoMessage = message['message'] as String?;
  if (echoMessage != null) {
    final webSocket = onlinePlayers[username];
    if (webSocket != null) {
      webSocket.add(json.encode({'type': 'echo', 'message': echoMessage}));
      print('Sent echo message to $username: $echoMessage');
    } else {
      print('Error: WebSocket not found for user $username');
    }
  } else {
    print('Error: No echo message provided');
  }
}
// void handleping(WebSocket socket) {
//   socket.listen((message) {
//     final Map<String, dynamic> receivedMessage = json.decode(message);
//
//     switch (receivedMessage['type']) {
//       case 'ping':
//       // Respond with 'pong'
//         sendMessage(socket, {'type': 'pong'});
//         break;
//       default:
//         print('Unknown message type: ${receivedMessage['type']}');
//     }
//   }, onDone: () {
//     print('Client disconnected');
//   }, onError: (error) {
//     print('WebSocket error: $error');
//   });
// }


void handleClientMessage(String username, Map<String, dynamic> receivedMessage,WebSocket socket) {
  final messageType = receivedMessage['type'] as String?;

  print('Received message type: $messageType');
  print('$playerLastActivity:here player activity');
  switch (messageType) {
    case 'echo':
      handleEchoMessage(username, receivedMessage);
      break;
    case 'join_matchmaking':
      addToMatchmakingQueue(username);
      break;

    case 'start_matchmaking':
      startMatchmaking();
      break;
    case 'ping':
    // Respond with 'pong'
      sendMessage(socket, {'type': 'pong'});
      playerLastActivity[username] = DateTime.now();
      print('Ping received. Updated last activity for $username');
      break;
    case 'player_exit':
      handlePlayerExit(username, receivedMessage);
      break;
    case 'game_end':
      game_end(username, receivedMessage);
      break;
    case 'test_message':
      print("authondecated");
      break;
    case 'invite_user':
      handleInviteUser(username, receivedMessage,socket);
      break;
    case 'match_response':
      handleMatchResponse(username, receivedMessage);
      break;
    case 'no_user_online':
      handleMatchmakingFailed(username, socket);
      break;
    case 'player_status':
      handlePlayerStatus(username, receivedMessage);
      print("calling player status ");
      break;
    case 'game_state':
      final player1 = getPlayer1FromMessage(receivedMessage);
      final player2 = getPlayer2FromMessage(receivedMessage);
      if (player1 != null && player2 != null) {
        handleGameStateMessage(username, receivedMessage, player1, player2);
      } else {
        print('Error: Player information not found in the message');
      }
      break;
    default:
      print('Unknown message type: $messageType');
  }
}

String? getPlayer1FromMessage(Map<String, dynamic> message) {
  return message['player1'] as String?;
}

String? getPlayer2FromMessage(Map<String, dynamic> message) {
  return message['player2'] as String?;
}


void handleGameStateMessage(String username, Map<String, dynamic> message, String player1, String player2) {
  final gameState = message['game_state'] as Map<String, dynamic>?;

  if (gameState != null) {
    // Extract game state information
    final fen = gameState['fen'] as String?;
    final history = (gameState['history'] as List<dynamic>?)?.cast<String>(); // Cast to List<String> or handle null
    final redoStack = (gameState['redoStack'] as List<dynamic>?)?.cast<String>(); // Cast to List<String> or handle null
    final eatenWhite = (gameState['eatenWhite'] as List<dynamic>?)?.cast<String>(); // Cast to List<String> or handle null
    final eatenBlack = (gameState['eatenBlack'] as List<dynamic>?)?.cast<String>(); // Cast to List<String> or handle null
    final previousMove = (gameState['previousMove'] as Map<String, dynamic>?)
        ?.map((key, value) => MapEntry(key, value as String)); // Convert to Map<String, String> or handle null
    final selectedTile = gameState['selectedTile'] as String?;
    final availableMoves = (gameState['availableMoves'] as List<dynamic>?)?.cast<String>(); // Cast to List<String> or handle null
    final promotionMove = (gameState['promotionMove'] as Map<String, dynamic>?)
        ?.map((key, value) => MapEntry(key, value as String)); // Convert to Map<String, String> or handle null

    print(gameState);

    broadcastGameStateToPlayer(player1, player2, gameState); // Send to player1's opponent (player2)
    broadcastGameStateToPlayer(player2, player1, gameState); // Send to player2's opponent (player1)
  } else {
    print('Error: No game state provided');
  }
}

void broadcastGameStateToPlayer(String player, String opponent, Map<String, dynamic> gameState) {
  final webSocket = onlinePlayers[opponent]; // Fetch opponent's WebSocket
  if (webSocket != null) {
    webSocket.add(json.encode({'type': 'game_state', 'game_state': gameState, 'sent_by': player}));
    print('Sent game state update from $player to $opponent: $gameState');
  } else {
    print('Error: WebSocket not found for user $opponent');
  }
}
void sendMessage(WebSocket socket, Map<String, dynamic> message) {
  final encodedMessage = json.encode(message);
  socket.add(encodedMessage);
}
Future<void> handleMatchmakingFailed(String username, WebSocket socket) async {
  print('Matchmaking failed for user: $username');

  // Delay the start of AI matchmaking to allow for potential real opponent to join
  // await Future.delayed(Duration(seconds: 5)); // 5-second delay

  // Re-check if another player joined and match with them if possible
  if (matchmakingQueue.isNotEmpty) {
    tryStartMatch(); // Retry matchmaking
    return;
  }

  // Check if the player is in the active players list or already matched
  if (activePlayers.contains(username)) {
    print('$username is in an active game session.');
    return; // Exit the function if the user is active
  }

  // List of random Indian player names
  final indianPlayerNames = [
    'Ananya', 'Aarav', 'Vihaan', 'Ishaan', 'Aditi', 'Rohan', 'Neha', 'Arjun', 'Kavya', 'Rahul',
    'Siddharth', 'Riya', 'Karan', 'Mira', 'Anika', 'Nikhil', 'Saanvi', 'Aryan', 'Pooja', 'Dev',
    'Lakshmi', 'Vivaan', 'Sneha', 'Rudra', 'Tara', 'Vikram', 'Priya', 'Kabir', 'Meera', 'Yash',
    'Simran', 'Aditya', 'Gauri', 'Nitin', 'Ishita', 'Rakesh', 'Shruti', 'Manav', 'Pallavi', 'Kunal',
    'Leela', 'Rajesh', 'Nisha', 'Vijay', 'Sunita', 'Harsh', 'Nidhi', 'Raj', 'Anjali', 'Amit', 'Rekha'
  ];


  final colors = ['White','Black'];
  final randomColor = colors[Random().nextInt(colors.length)];

  // Select a random name from the list of Indian player names
  final aiOpponent = indianPlayerNames[Random().nextInt(indianPlayerNames.length)];

  sendMessage(socket, {
    'type': 'starting_ai',
    'message': aiOpponent,
    'username': username,
    'color': randomColor,
  });

  activePlayers.add(username);
  final isPlayer1Black = randomColor == 'Black';
  print("$aiOpponent");
  print("$isPlayer1Black");
  final gameSession = GameSession(username, aiOpponent, isPlayer1Black);
  gameSession.start();
  print("Game session started: $gameSession");
}

void handleMatchResponse(String username, Map<String, dynamic> message) {
  final response = message['response'] as String?;
  final opponent = message['opponent'] as String?;

  if (response == 'accept') {
    startGameSession(username, opponent!);
  } else if (response == 'reject') {
    onlinePlayers[opponent!]?.add(json.encode({
      'type': 'match_response',
      'response': 'reject',
      'opponent': username,
      'sessionToken': "session_token",
    }));
  }
}
void startGameSession(String player1, String player2) {
  // Check if either player is already in a game session
  if (activePlayers.contains(player1) || activePlayers.contains(player2)) {
    print('Error: One of the players is already in a game session');
    return;
  }

  final random = Random();
  final isPlayer1Black = random.nextBool();

  final gameSession = GameSession(player1, player2, isPlayer1Black);
  gameSession.start();
  print("$gameSession");

  onlinePlayers[player1]?.add(json.encode({'type': 'match_found', 'opponent': player2}));
  onlinePlayers[player2]?.add(json.encode({'type': 'match_found', 'opponent': player1}));

  if (isPlayer1Black) {
    onlinePlayers[player1]?.add(json.encode({'type': 'color_selection', 'color': 'Black'}));
    onlinePlayers[player2]?.add(json.encode({'type': 'color_selection', 'color': 'White'}));
  } else {
    onlinePlayers[player1]?.add(json.encode({'type': 'color_selection', 'color': 'White'}));
    onlinePlayers[player2]?.add(json.encode({'type': 'color_selection', 'color': 'Black'}));
  }

  // Ensure players are added to active players
  activePlayers.add(player1);
  print("$activePlayers");

  activePlayers.add(player2);
  print("$activePlayers");
  // Send updated game session list to all connected clients
  onlinePlayers.forEach((_, channel) {
    sendGameSessionUserList(channel);  // Assuming channel is the WebSocket connection
  });
}
void sendGameSessionUserList(WebSocket socket) {
  // Create a list of active game sessions
  final List<Map<String, String>> sessions = gameSessions.entries.map((entry) {
    return {
      'player1': entry.value.player1,
      'player2': entry.value.player2,
    };
  }).toList();

  // Send the active game sessions list to the client
  sendMessage(socket, {
    'type': 'active_game_sessions',
    'sessions': sessions,
  });

  print('Sent active game sessions to the client: $sessions');
}

void handlePlayerStatus(String username, Map<String, dynamic> message) {
  final status = message['status'] as String?;
  if (status != null) {
    // Update the player's status on the server
    //updatePlayerStatus(username, status);

    // Find and notify the opponent
    final gameSession = gameSessions[username];
    if (gameSession != null) {
      final opponent = gameSession.player1 == username ? gameSession.player2 : gameSession.player1;

      // Notify the opponent about the player's status change
      final opponentSocket = onlinePlayers[opponent];
      if (opponentSocket != null) {
        sendMessage(opponentSocket, {
          'type': 'opponent_status',
          'status': status,
          'username': username,
        });
        print("send message to opponent about opponent_status  $opponent");
      }
      print("send message to opponent about opponent_status  $opponent");
    }else{
      print("game session null$gameSession");
    }
    print("status not null");
  } else {
    print('Error: Status information not found in the message');
  }
}
// void startPeriodicCleanup() {
//   Timer.periodic(const Duration(seconds: 10), (timer) {
//     final now = DateTime.now();
//     List<String> playersToRemove = [];
//
//     // First pass: Identify players to be removed
//     playerLastActivity.forEach((username, lastActivity) {
//       if (now.difference(lastActivity) > pongTimeout) {
//         print('Pong timeout for $username. Cleaning up session.');
//         handlePlayerExit(username);
//
//         // Add player and opponent to remove list
//         playersToRemove.add(username);
//         final opponent = findOpponentForPlayer(username); // Custom logic to find the opponent
//         if (opponent != null) {
//           playersToRemove.add(opponent);
//           print('Opponent $opponent also removed from playerLastActivity');
//         }
//       }
//     });
//
//     // Second pass: Remove players and their opponents (after iteration completes)
//     for (var username in playersToRemove) {
//       playerLastActivity.remove(username);
//       print('Player $username removed from playerLastActivity');
//     }
//   });
// }
//
// String? findOpponentForPlayer(String username) {
//   final gameSession = gameSessions[username];
//   if (gameSession != null) {
//     return gameSession.player1 == username ? gameSession.player2 : gameSession.player1;
//   }
//   return null;
// }
void game_end(String username, [Map<String, dynamic>? message]) async {
  print('game end message received from $username');
  List<String> usersToRemove = [];


  // Clean up the player's game session and related data
  deleteBettingAmountFromDatabase(username);
  activePlayers.remove(username);

  print('Active player removed $username');

  if (matchmakingQueue.contains(username)) {
    matchmakingQueue.remove(username);
    print('Player $username removed from matchmaking queue');
  }

  final gameSession = gameSessions[username];
  if (gameSession != null) {
    final opponent = gameSession.player1 == username ? gameSession.player2 : gameSession.player1;
    //
    // // Notify the opponent that the player has exited
    // if (onlinePlayers.containsKey(opponent)) {
    //   onlinePlayers[opponent]?.add(json.encode({
    //     'type': 'player_exit',
    //     'message': '$username has exited the game.',
    //   }));
    // }

    // Remove the game session for both players
    gameSessions.remove(username);
    gameSessions.remove(opponent);
    activePlayers.remove(opponent);
    print('Active player removed $opponent');
    userSessions.remove(opponent);

    playerLastActivity.remove(username);

    print("playerLastActivity  removed for $username");

    print('Game session cleaned up for $username , $opponent');
  }

  // Remove the user from the list of online players and close the WebSocket connection
  final webSocketChannel = onlinePlayers[username];
  if (webSocketChannel != null) {
    // Notify other players about the player exit
    broadcastOnlineUsers();

    // Send updated game session list to all online players
    for (var playerSocket in onlinePlayers.values) {
      if (playerSocket != webSocketChannel) { // Avoid sending to the user who exited
        sendGameSessionUserList(playerSocket);
      }
    }


    userSessions.remove(username);
    print('User $username is offline');
    onlinePlayers.remove(username); // Remove the user from online players after closing connection
  } else {
    print('Error: WebSocket channel not found for $username');
  }
}

void handlePlayerExit(String username, [Map<String, dynamic>? message]) async {
  print('Player exit message received from $username');
  List<String> usersToRemove = [];


  // Clean up the player's game session and related data
  deleteBettingAmountFromDatabase(username);
  activePlayers.remove(username);

  print('Active player removed $username');

  if (matchmakingQueue.contains(username)) {
    matchmakingQueue.remove(username);
    print('Player $username removed from matchmaking queue');
  }

  final gameSession = gameSessions[username];
  if (gameSession != null) {
    final opponent = gameSession.player1 == username ? gameSession.player2 : gameSession.player1;

    // Notify the opponent that the player has exited
    if (onlinePlayers.containsKey(opponent)) {
      onlinePlayers[opponent]?.add(json.encode({
        'type': 'player_exit',
        'message': '$username has exited the game.',
      }));
    }

    // Remove the game session for both players
    gameSessions.remove(username);
    gameSessions.remove(opponent);
    activePlayers.remove(opponent);
    print('Active player removed $opponent');
    userSessions.remove(opponent);

    playerLastActivity.remove(username);

    print("playerLastActivity  removed for $username");

    print('Game session cleaned up for $username , $opponent');
  }

  // Remove the user from the list of online players and close the WebSocket connection
  final webSocketChannel = onlinePlayers[username];
  if (webSocketChannel != null) {
    // Notify other players about the player exit
    broadcastOnlineUsers();

    // Send updated game session list to all online players
    for (var playerSocket in onlinePlayers.values) {
      if (playerSocket != webSocketChannel) { // Avoid sending to the user who exited
        sendGameSessionUserList(playerSocket);
      }
    }


    userSessions.remove(username);
    print('User $username is offline');
    onlinePlayers.remove(username); // Remove the user from online players after closing connection
  } else {
    print('Error: WebSocket channel not found for $username');
  }
}

void handleInviteUser(String username, Map<String, dynamic> message, WebSocket socket) {
  final opponent = message['opponent'] as String?;
  final bettingAmount = message['bettingAmount'] as String?;

  if (opponent != null && !activePlayers.contains(opponent)) {
    if (!activePlayers.contains(username)) {
      onlinePlayers[opponent]?.add(json.encode({
        'type': 'game_invitation',
        'opponent': username,
        'bettingAmount': bettingAmount,
      }));
      print('Sent game invitation from $username to $opponent');
    } else {
      print('Error: $username is already in a game or matchmaking.');
    }
  } else {
    print('Error: Opponent not found, not online, or currently in a game');
  }
}


Future<void> addToMatchmakingQueue(String username) async {
  final user = userSessions[username];
  if (user == null || user.isInMatchmaking || activePlayers.contains(username)) {
    print('Error: User session not found, already in matchmaking, or already active for $username');
    return;
  }

  // Lock the player for matchmaking
  user.isInMatchmaking = true;

  // Add to matchmaking queue
  if (!matchmakingQueue.contains(username)) {
    matchmakingQueue.add(username);
    print('Player $username joined matchmaking queue');
    tryStartMatch();
  } else {
    user.isInMatchmaking = false; // Unlock if already in the queue
  }
}
void tryStartMatch() {
  matchedPlayers.clear();

  while (matchmakingQueue.length >= 2) {
    final player1 = matchmakingQueue.removeAt(0);
    final user1 = userSessions[player1];

    if (user1 == null || matchedPlayers.contains(player1) || activePlayers.contains(player1)) {
      if (user1 != null) user1.isInMatchmaking = false;
      continue;
    }

    final player2Index = matchmakingQueue.indexWhere((player) =>
    !matchedPlayers.contains(player) && !activePlayers.contains(player) && userSessions[player]?.isInMatchmaking == false);

    if (player2Index != -1) {
      final player2 = matchmakingQueue.removeAt(player2Index);
      final user2 = userSessions[player2];

      if (user2 != null) {
        matchedPlayers.add(player1);
        matchedPlayers.add(player2);
        activePlayers.add(player1);
        activePlayers.add(player2);

        startGameSession(player1, player2);
      }

      user1.isInMatchmaking = false;
      if (user2 != null) user2.isInMatchmaking = false;
    } else {
      matchmakingQueue.insert(0, player1);
      user1.isInMatchmaking = false;
      break;
    }
  }

  if (matchmakingQueue.isNotEmpty) {
    final player1 = matchmakingQueue.removeAt(0);
    final user1 = userSessions[player1];

    if (user1 != null && !activePlayers.contains(player1)) {
      handleMatchmakingFailed(player1, user1.socket);
      user1.isInMatchmaking = false;
    }
  }
}


Future<void> startMatchmaking() async {
  // Periodically check the matchmaking queue and start matches
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    tryStartMatch();
  });
}


void handleWebSocketConnection(WebSocket webSocket, Map<String, dynamic> message, String sessionToken) async {
  print('Incoming message: $message');

  // Authenticate user using session token obtained from the client's message
  try {
    final user = await authenticateUser(sessionToken,  webSocket);

    if (user != null) {
      print('User authenticated: ${user.username}');
      // Store the user session with the session token
      userSessions[user.username] = user;
      user.isAuthenticated = true; // Mark the user as authenticated
      print('User session stored: ${user.username}');

      // Store the WebSocket for the user
      onlinePlayers[user.username] = webSocket;
      print('Online players: $onlinePlayers');

      // Call handleClientMessage to start listening for messages
      handleClientMessage(user.username, message,webSocket);

      // Update user's last activity time
      user.lastActivity = DateTime.now().millisecondsSinceEpoch;

      // Send a welcome message to the client
      if (webSocket.readyState == WebSocket.open) {
        webSocket.add(json.encode({'type': 'welcome', 'message': 'Welcome, ${user.username}!'}));
      }

      // Notify the server that the player is online
      updateOnlineStatus(user.username, true);
      broadcastOnlineUsers();

    } else {
      print('Failed to authenticate user with session token: $sessionToken');
      if (webSocket.readyState == WebSocket.open) {
        webSocket.add(json.encode({'type': 'authentication_failed', 'message': 'Invalid session token'}));
        await webSocket.close();
      }
    }
  } catch (e) {
    print('Error during WebSocket connection handling: $e');
  }
}
void handleWebSocketDisconnection(String username, String sessionToken) async {
  final webSocketChannel = onlinePlayers[username];
  if (webSocketChannel != null) {
    final user = userSessions[username]; // Use username to retrieve user session
    if (user != null) {
      print('Player disconnected: $username');
      activePlayers.remove(username);
      user.lastActivity = DateTime.now().millisecondsSinceEpoch;
      // Update user's online status
      updateOnlineStatus(username, false);
      // Broadcast updated list of online users
      broadcastOnlineUsers();
      try {
        //await webSocketChannel.close(); // Close the WebSocket channel
        //print('WebSocket channel closed for user: $username');
        // Remove the user session using the username
        userSessions.remove(username);
        print('User $username is offline');

        // Delete betting amount from the database
        await deleteBettingAmountFromDatabase(username);
      } catch (e) {
        print('Error closing WebSocket channel: $e');
      }
    } if (matchmakingQueue.contains(username)) {
      matchmakingQueue.remove(username);
      print('Player $username removed from matchmaking queue');
    }
  } else {
    print('Error: WebSocket channel not found for $username');
  }
}


Future<void> deleteBettingAmountFromDatabase(String username) async {
  try {
    final response = await http.post(
      Uri.parse('https://schmidivan.com/Esakki/ChessGame/delete_bettingamount'),
      body: jsonEncode({'username': username}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success']) {
        print('Betting amount deleted for user: $username');
      } else {
        print('Failed to delete betting amount: $username${responseData['message']}');
      }
    } else {
      print('Failed to connect to the server to delete betting amount');
    }
  } catch (e) {
    print('Error deleting betting amount: $e');
  }
}

Future<User?> authenticateUser(String sessionToken, WebSocket socket) async {
  try {
    // Check if the user is already authenticated
    for (var user in userSessions.values) {
      if (user.sessionToken == sessionToken && user.isAuthenticated) {
        print('User already authenticated: ${user.username}');
        return user;
      }
    }

    // User not found in existing sessions or not authenticated, proceed with authentication
    print('Sending session token for authentication: $sessionToken');
    final response = await http.post(
      Uri.parse(authUrl),
      body: {'session_token': sessionToken},
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Parsed response data: $data');
      if (data['success'] == true && data['username'] != null) {
        final username = data['username'];
        return User(username, sessionToken,socket)..isAuthenticated = true;
      } else {
        print('Authentication failed: ${data['message']}');
      }
    } else {
      print('Failed to authenticate user. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error during authentication: $e');
  }
  return null;
}

void broadcastOnlineUsers() async {
  // Fetch betting amounts for all online users
  final bettingAmounts = await fetchBettingAmountsFromServer(
      userSessions.values
          .where((user) => onlinePlayers.containsKey(user.username))
          .map((user) => user.username)
          .toList()
  );

  // Use a Set to automatically remove duplicates
  final onlineUsernamesSet = bettingAmounts.keys.toSet();

  // Make a copy of onlinePlayers entries to avoid modifying the map while iterating
  final channelsToSend = List.from(onlinePlayers.entries);

  print('Broadcasting online users with betting amounts: $onlineUsernamesSet, $bettingAmounts');

  for (final entry in channelsToSend) {
    final ownUsername = entry.key;
    final channel = entry.value;

    // Determine the betting amount of the current user
    final ownBettingAmount = bettingAmounts[ownUsername];

    // Create a new set of usernames with the same betting amount, excluding the owner's username
    final usernamesToSend = onlineUsernamesSet
        .where((username) => username != ownUsername && bettingAmounts[username] == ownBettingAmount)
        .toSet();

    // Add usernames from 'other_players_for_matching' list as online users
    usernamesToSend.addAll(matchmakingQueue.where((username) => username != ownUsername));

    final message = {
      'type': 'online_users',
      'usernames': usernamesToSend.toList(), // Convert set back to a list
      'betting_amounts': bettingAmounts,
      'other_players_for_matching': matchmakingQueue,
    };

    try {
      if (channel.readyState == WebSocket.open) {
        channel.add(json.encode(message));
        print('Online users message sent to channel: $channel for user $ownUsername');
      } else {
        print('WebSocket closed for channel: $channel');
        // Remove closed WebSocket from onlinePlayers map
        onlinePlayers.remove(ownUsername);
      }
    } catch (error) {
      print('Error sending online users message to channel: $error');
      // Handle error gracefully, e.g., remove WebSocket from onlinePlayers
      onlinePlayers.remove(ownUsername);
    }
  }
}


Future<Map<String, int>> fetchBettingAmountsFromServer(List<String> usernames) async {
  final bettingAmounts = <String, int>{};
  try {
    final response = await http.post(
      Uri.parse('https://schmidivan.com/Esakki/ChessGame/fetch_bettingamount'), // Replace with your PHP script URL
      body: {'usernames': json.encode(usernames)},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final Map<String, dynamic> bettingAmountsData = data['betting_amounts'];
        bettingAmountsData.forEach((username, amount) {
          bettingAmounts[username] = int.parse(amount.toString());
        });
      } else {
        print('Failed to fetch betting amounts: ${data['message']}');
      }
    } else {
      print('Failed to fetch betting amounts. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching betting amounts: $e');
  }
  return bettingAmounts;
}


void updateOnlineStatus(String username, bool isOnline) async {
  try {
    final response = await http.post(
      Uri.parse(onlineStatusUrl),
      body: {
        'username': username,
        'is_online': isOnline ? '1' : '0',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        print('User $username is ${isOnline ? 'online' : 'offline'}');
        return;
      } else {
        print('Failed to update online status for user $username: ${data['message']}');
      }
    } else {
      print('Failed to update online status for user $username. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error updating online status: $e');
  }
}


String? getPlayerNameByWebSocket(WebSocket webSocket) {
  for (var entry in onlinePlayers.entries) {
    if (entry.value == webSocket) {
      return entry.key;
    }
  }
  return null;
}
void endGameSession(String player1, String player2) {
  // Clean up the game session
  gameSessions.remove(player1);
  gameSessions.remove(player2);

  // Remove from active players set
  activePlayers.remove(player1);
  activePlayers.remove(player2);
}
class User {
  final String username;
  final WebSocket socket;
  final String sessionToken;
  int? lastActivity;
  int? bettingAmount;
  bool isAuthenticated; // New flag to indicate if the user is authenticated
  bool isInMatchmaking;
  User(this.username, this.sessionToken, this.socket)
      : isAuthenticated = false,
        isInMatchmaking = false;}

class GameSession {
  final String player1;
  final String player2;
  final bool isPlayer1Black;

  // final String player1Color;
  // final String player2Color;

  GameSession(this.player1, this.player2, this.isPlayer1Black);
  void start() {
    gameSessions[player1] = this;
    gameSessions[player2] = this;
    print('Game session started between $player1 and $player2.');
  }
}