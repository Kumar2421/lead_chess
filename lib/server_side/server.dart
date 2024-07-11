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

const String authUrl = 'https://schmidivan.com/senthil/_ChessGame/authondecation';
const String onlineStatusUrl = 'https://schmidivan.com/senthil/_ChessGame/onlinestatus';
final List<int> dartServerPorts = [3005];
// Future<void> main() async {
//   for (var port in dartServerPorts) {
//     await runWebSocketServer(port);
//     // Run the JavaScript file
//     // var result = await Process.run('node', ['/Users/LIBS/StudioProjects/Chess_game/lib/server_side/server.js']);
//     // var result1 = await Process.run('node', ['/Users/LIBS/StudioProjects/Chess_game/lib/server_side/client_server.js']);
//     // print(result.stdout);
//     // print(result1.stderr);
//   }
// }

Future<void> main() async {
  for (var port in dartServerPorts) {
    await runWebSocketServer(port);
  }
}

Future<void> runWebSocketServer(int port) async {
  try {
    final server = await HttpServer.bind('192.168.29.168', port);
    print('Dart WebSocket server running on port $port');

    server.listen((HttpRequest request) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        handleWebSocket(request);
      } else {
        handleHttpRequest(request);
      }
    });

    startMatchmaking();
  } catch (e) {
    print('Error connecting to MySQL: $e');
  }
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
        if (data is String) {
          // Handle string messages
          print('Received message as String: $data');
          try {
            final Map<String, dynamic> message = json.decode(data);
            final sessionToken = message['sessionToken'] as String?;
            if (sessionToken != null) {
              handleWebSocketConnection(webSocket, message, sessionToken);
            } else {
              print('Session token not provided. Closing connection.');
              webSocket.close();
            }
          } catch (e) {
            print('Error decoding message: $e');
          }
        } else if (data is List<int>) {
          // Handle binary data
          String decodedData = utf8.decode(data); // Convert Uint8List to String
          print('Received binary data as String: $decodedData');
          // Process the decoded data as needed
        } else {
          print('Unexpected data type received: ${data.runtimeType}');
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
        } else {
          print('Error: User session not found for the disconnected WebSocket');
        }
      },
    );

    webSocket.add(utf8.encode(json.encode({'type': 'connection_success_ack', 'message': 'Dart server connected to proxy.'})));
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

void handleClientMessage(String username, Map<String, dynamic> receivedMessage) {
  final messageType = receivedMessage['type'] as String?;

  print('Received message type: $messageType');

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
    case 'invite_user':
      handleInviteUser(username, receivedMessage);
      break;
    case 'match_response':
      handleMatchResponse(username, receivedMessage);
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

void startGameSession(String player1, String player2) async {
  final random = Random();
  final isPlayer1Black = random.nextBool();

  final gameSession = GameSession(player1, player2, isPlayer1Black);
  gameSession.start();

  onlinePlayers[player1]?.add(json.encode({'type': 'match_found', 'opponent': player2}));
  onlinePlayers[player2]?.add(json.encode({'type': 'match_found', 'opponent': player1}));

  if (isPlayer1Black) {
    onlinePlayers[player1]?.add(json.encode({'type': 'color_selection', 'color': 'black'}));
    onlinePlayers[player2]?.add(json.encode({'type': 'color_selection', 'color': 'white'}));
  } else {
    onlinePlayers[player1]?.add(json.encode({'type': 'color_selection', 'color': 'white'}));
    onlinePlayers[player2]?.add(json.encode({'type': 'color_selection', 'color': 'black'}));
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


void handleInviteUser(String username, Map<String, dynamic> message) {
  final opponent = message['opponent'] as String?;
  final bettingAmount = message['bettingAmount'] as String?;

  if (opponent != null && onlinePlayers.containsKey(opponent)) {
    onlinePlayers[opponent]?.add(json.encode({
      'type': 'game_invitation',
      'opponent': username,
      'bettingAmount': bettingAmount,
    }));
    print('Sent game invitation from $username to $opponent');
  } else {
    print('Error: Opponent not found or not online');
  }
}

Future<void> addToMatchmakingQueue(String username) async {
  final user = userSessions[username];
  if (user == null) {
    print('Error: User session not found for $username');
    return;
  }

  // Check if the user is already in the matchmaking queue
  if (!matchmakingQueue.contains(username)) {
    matchmakingQueue.add(username);
    print('Player $username joined matchmaking queue');
    tryStartMatch();
  }
}
void tryStartMatch() {
  if (matchmakingQueue.length >= 2) {
    final player1 = matchmakingQueue.removeAt(0);
    final player2 = matchmakingQueue.removeAt(0);
    startGameSession(player1, player2);
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
    final user = await authenticateUser(sessionToken);

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
      handleClientMessage(user.username, message);

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
      user.lastActivity = DateTime.now().millisecondsSinceEpoch;
      // Update user's online status
      updateOnlineStatus(username, false);
      // Broadcast updated list of online users
      broadcastOnlineUsers();
      try {
        await webSocketChannel.close(); // Close the WebSocket channel
        print('WebSocket channel closed for user: $username');
        // Remove the user session using the username
        userSessions.remove(username);
        print('User $username is offline');

        // Delete betting amount from the database
        final response = await http.post(
          Uri.parse('https://schmidivan.com/senthil/_ChessGame/delete_bettingamount.php'),
          body: jsonEncode({'username': username}),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['success']) {
            print('Betting amount deleted for user: $username');
          } else {
            print('Failed to delete betting amount: ${responseData['message']}');
          }
        } else {
          print('Failed to connect to the server to delete betting amount');
        }
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
Future<User?> authenticateUser(String sessionToken) async {
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
        return User(username, sessionToken)..isAuthenticated = true;
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
  final bettingAmounts = await fetchBettingAmountsFromServer(userSessions.values
      .where((user) => onlinePlayers.containsKey(user.username))
      .map((user) => user.username)
      .toList());

  // Use a Set to automatically remove duplicates
  final onlineUsernamesSet = bettingAmounts.keys.toSet();

  final channelsToSend = List.from(onlinePlayers.entries);

  print('Broadcasting online users with betting amounts: $onlineUsernamesSet, $bettingAmounts');

  for (final entry in channelsToSend) {
    final ownUsername = entry.key;
    final channel = entry.value;

    // Determine the betting amount of the current user
    final ownBettingAmount = bettingAmounts[ownUsername];

    // Create a new set of usernames with the same betting amount, excluding the owner's username
    final usernamesToSend = onlineUsernamesSet.where((username) =>
    username != ownUsername && bettingAmounts[username] == ownBettingAmount).toSet();

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
        onlinePlayers.removeWhere((username, socket) => socket == channel);
      }
    } catch (error) {
      print('Error sending online users message to channel: $error');
      // Handle error gracefully, e.g., remove WebSocket from onlinePlayers
      onlinePlayers.removeWhere((username, socket) => socket == channel);
    }
  }
}

Future<Map<String, int>> fetchBettingAmountsFromServer(List<String> usernames) async {
  final bettingAmounts = <String, int>{};
  try {
    final response = await http.post(
      Uri.parse('https://schmidivan.com/senthil/_ChessGame/fetch_bettingamount'), // Replace with your PHP script URL
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
class User {
  final String username;
  final String sessionToken;
  int? lastActivity;
  int? bettingAmount;
  bool isAuthenticated; // New flag to indicate if the user is authenticated

  User(this.username, this.sessionToken) : isAuthenticated = false;
}

class GameSession {
  final String player1;
  final String player2;
  // final String player1Color;
  // final String player2Color;
  GameSession(this.player1, this.player2, bool isPlayer1Black);

  void start() {
    // Implement game session initialization logic here
    // For example, start a new chess game between player1 and player2
  }
}