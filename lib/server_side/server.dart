// server.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:mysql1/mysql1.dart';

final Map<String, WebSocketChannel> onlinePlayers = {};
final Map<String, User> userSessions = {};
late MySqlConnection dbConnection;

void main() async {
  try {
    dbConnection = await MySqlConnection.connect(ConnectionSettings(
      host: '127.0.0.1',
      port: 3306,
      user: 'root',
      db: 'id21287285_esakki',
    ));

    final server = await HttpServer.bind('192.168.220.206',3005);
    print('Server running on port ${server.port}');

    // Heartbeat Mechanism - Check user online status every 30 seconds
    Timer.periodic(Duration(seconds: 30), (timer) {
      checkUserOnlineStatus();
    });

    server.listen((HttpRequest request) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        handleWebSocket(request);
      } else {
        handleHttpRequest(request);
      }
    });
  } catch (e) {
    print('Error connecting to MySQL: $e');
  }
}

void handleClientMessage(String username, Map<String, dynamic> receivedMessage) {
  final messageType = receivedMessage['type'] as String?;

  switch (messageType) {
    case 'echo':
      handleEchoMessage(username, receivedMessage);
      break;
    case 'game_request':
      handleGameRequest(username, receivedMessage);
      break;
    case 'fetch_online_users':
      sendOnlineUsers(username);
      break;
  // Add more cases for other message types as needed
  }
}

void handleEchoMessage(String username, Map<String, dynamic> message) {
  final echoMessage = message['message'] as String?;
  if (echoMessage != null) {
    onlinePlayers[username]?.sink.add(json.encode({'type': 'echo', 'message': echoMessage}));
  }
}

void handleGameRequest(String sender, Map<String, dynamic> message) async {
  final recipient = message['recipient'] as String?;

  if (recipient != null && onlinePlayers.containsKey(recipient)) {
    // The recipient is online
    final recipientWebSocket = onlinePlayers[recipient]!;

    // Notify the recipient about the game request
    recipientWebSocket.sink.add(json.encode({
      'type': 'game_request',
      'sender': sender,
    }));
  } else {
    // The recipient is not online or does not exist
    print('Recipient $recipient is not online or does not exist.');
    // Optionally, you can inform the sender about the failure
    onlinePlayers[sender]?.sink.add(json.encode({
      'type': 'game_request_failed',
      'message': 'Recipient $recipient is not online or does not exist.',
    }));
  }
}

void handleWebSocket(HttpRequest request) {
  WebSocketTransformer.upgrade(request).then((WebSocket webSocket) {
    webSocket.listen(
          (data) {
        try {
          final message = json.decode(data);
          handleWebSocketConnection(webSocket, message);
        } catch (e) {
          print('Error decoding message: $e');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        handleWebSocketDisconnection(webSocket);
      },
    );
  });
}

void handleWebSocketConnection(WebSocket webSocket, Map<String, dynamic> message) async {
  final sessionToken = message['sessionToken'] as String?;
  final type = message['type'] as String?;

  if (sessionToken == null && type != 'game_request') {
    print('Session token not provided. Closing connection.');
    webSocket.close();
    return;
  }

  // Authenticate user using session token
  final user = await authenticateUser(sessionToken ?? ''); // Provide a default value if sessionToken is null

  if (user != null) {
    // Check if there is an existing WebSocket for the user
    if (onlinePlayers.containsKey(user.username)) {
      // Close the existing WebSocket connection
      onlinePlayers[user.username]?.sink.close();
    }

    onlinePlayers[user.username] = IOWebSocketChannel(webSocket);
    userSessions[sessionToken ?? ''] = user; // Provide a default value if sessionToken is null
    print('Player joined: ${user.username}');

    // Update user's last activity time
    user.lastActivity = DateTime.now().millisecondsSinceEpoch;

    // Notify the server that the player is online
    updateOnlineStatus(user.username, true);
    broadcastOnlineUsers();

    // Send a welcome message to the client
    webSocket.add(json.encode({'type': 'welcome', 'message': 'Welcome, ${user.username}!'}));

    // Listen for messages from the client
    try {
      await for (var data in webSocket) {
        final receivedMessage = json.decode(data as String);
        // Update user's last activity time on message handling
        user.lastActivity = DateTime.now().millisecondsSinceEpoch;
        handleClientMessage(user.username, receivedMessage);
      }
    } catch (e) {
      print('WebSocket error: $e');
    } finally {
      // Handle WebSocket disconnection
      handleWebSocketDisconnection(webSocket);
    }
  } else {
    print('Failed to authenticate user with session token: $sessionToken');
    webSocket.add(json.encode({'type': 'authentication_failed', 'message': 'Invalid session token'}));
    webSocket.close();
  }
}



Future<User?> authenticateUser(String sessionToken) async {
  try {
    final results = await dbConnection.query(
      'SELECT name, session_token FROM chess_user WHERE session_token = ?',
      [sessionToken],
    );

    print('Authentication Results: $results');

    if (results.isNotEmpty) {
      final row = results.first;
      return User(row['name'], row['session_token']);
    }
  } catch (e) {
    print('Database error during authentication: $e');
  }

  return null;
}

void checkUserOnlineStatus() {
  final currentTime = DateTime.now().millisecondsSinceEpoch;

  for (var user in userSessions.values) {
    final lastActivity = user.lastActivity ?? 0;
    final timeDifference = currentTime - lastActivity;

    // Set a threshold (e.g., 1 minute) to determine when a user is considered inactive
    final inactiveThreshold = 1 * 60 * 1000; // 1 minute in milliseconds

    if (timeDifference > inactiveThreshold) {
      // User is considered inactive, update 'is_online' status in the database
      updateOnlineStatus(user.username, false);
    } else {
      // User is still online
      updateOnlineStatus(user.username, true);
    }
  }

  // Notify the server about the current online users
  broadcastOnlineUsers();
}

void broadcastOnlineUsers() {
  final onlineUsernames = userSessions.values
      .where((user) => onlinePlayers.containsKey(user.username))
      .map((user) => user.username)
      .toList();

  final message = {'type': 'online_users', 'usernames': onlineUsernames};

  // Remove closed WebSocket channels from the list
  onlinePlayers.removeWhere((username, channel) {
    try {
      channel.sink.add(json.encode(message));
      return false; // Keep the channel in the list
    } catch (_) {
      return true; // Remove the channel from the list
    }
  });
}


void updateOnlineStatus(String username, bool isOnline) async {
  try {
    await dbConnection.query(
      'UPDATE chess_user SET is_online = ? WHERE name = ?',
      [isOnline ? 1 : 0, username],
    );

    print('User $username is ${isOnline ? 'online' : 'offline'}');
  } catch (e) {
    print('Error updating online status: $e');
  }
}

void handleWebSocketDisconnection(WebSocket webSocket) {
  final playerName = getPlayerNameByWebSocket(webSocket);

  if (playerName != null) {
    final user = userSessions[playerName];
    userSessions.remove(playerName);

    if (user != null) {
      print('Player disconnected: $playerName');

      // Update user's last activity time
      user.lastActivity = DateTime.now().millisecondsSinceEpoch;

      // Check if the user is genuinely offline
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final inactiveThreshold = 1 * 60 * 1000; // 1 minute in milliseconds

      if (user.lastActivity != null && currentTime - user.lastActivity! > inactiveThreshold) {
        updateOnlineStatus(playerName, false);
        broadcastOnlineUsers();

        // Close the WebSocket connection
        onlinePlayers[playerName]?.sink.close();
        onlinePlayers.remove(playerName);
      }
    } else {
      print('Error: User session not found for $playerName');
    }
  }
}


String? getPlayerNameByWebSocket(WebSocket webSocket) {
  for (var entry in onlinePlayers.entries) {
    if (entry.value.sink == webSocket) {
      return entry.key;
    }
  }
  return null;
}

void handleHttpRequest(HttpRequest request) {
  request.response.write('Welcome to the chess server!');
  request.response.close();
}

// Add a case to handle the 'fetch_online_users' type in handleClientMessage

// Add the following method to send the list of online users to the client
void sendOnlineUsers(String username) {
  final onlineUsernames = userSessions.values
      .where((user) => onlinePlayers.containsKey(user.username))
      .map((user) => user.username)
      .toList();

  final message = {'type': 'online_users', 'usernames': onlineUsernames};
  onlinePlayers[username]?.sink.add(json.encode(message));
}

class User {
  final String username;
  final String sessionToken;
  int? lastActivity;

  User(this.username, this.sessionToken);
}
