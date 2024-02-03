import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../server_side/websocket_manager.dart';

class PlayOnline extends StatefulWidget {
  @override
  _PlayOnlineState createState() => _PlayOnlineState();
}

class _PlayOnlineState extends State<PlayOnline> {
  late WebSocketManager webSocketManager;
  List<String> onlineUsers = [];

  @override
  void initState() {
    super.initState();
    webSocketManager = WebSocketManager('ws://192.168.220.206:3005');
    webSocketManager.stream.listen((message) {
      handleWebSocketMessage(message);
    });

    // Send a fetch_online_users message with the session token when initializing
    // Replace 'your_session_token_here' with the actual session token
    webSocketManager.send(json.encode({
      'type': 'fetch_online_users',
      'sessionToken': 'c6568d87-c667-48fd-84a1-7d30752d1a1b',
    }));

    // Periodically send a heartbeat message to keep the WebSocket connection alive
    Timer.periodic(Duration(seconds: 20), (timer) {
      webSocketManager.send(json.encode({'type': 'heartbeat'}));
    });
  }


  void handleWebSocketMessage(String message) {
    final Map<String, dynamic> decodedMessage = json.decode(message);
    final String messageType = decodedMessage['type'];

    switch (messageType) {
      case 'online_users':
        setState(() {
          onlineUsers = List<String>.from(decodedMessage['usernames']);
        });
        break;
      case 'game_request':
        handleGameRequest(decodedMessage);
        break;
      case 'game_request_failed':
        handleGameRequestFailed(decodedMessage);
        break;
    // Handle other message types as needed
    }
  }

  void updateOnlineUsers(List<String> users) {
    setState(() {
      onlineUsers = users;
    });
  }

  void handleGameRequest(Map<String, dynamic> message) {
    final String sender = message['sender'];
    // Implement logic to handle game request
    // You can show a dialog to the user to accept or decline the request
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Request'),
          content: Text('$sender wants to play a game with you.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Implement logic to accept the request
                print('Accepted request from $sender');
                Navigator.of(context).pop();
              },
              child: Text('Accept'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement logic to decline the request
                print('Declined request from $sender');
                Navigator.of(context).pop();
              },
              child: Text('Decline'),
            ),
          ],
        );
      },
    );
  }

  void handleGameRequestFailed(Map<String, dynamic> message) {
    final String errorMessage = message['message'];
    // Implement logic to show the error message to the user
    print('Game request failed: $errorMessage');
  }

  void sendRequest(String playerName) {
    // Send a game request to the specified player
    webSocketManager.send(json.encode({
      'type': 'game_request',
      'recipient': playerName,
    }));
    print('Sending request to $playerName');
  }

  // Fetch online users from the server
  void fetchOnlineUsers() {
    webSocketManager.send(json.encode({'type': 'fetch_online_users'}));
  }

  @override
  void dispose() {
    webSocketManager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Play Online'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text(
            'Online Users:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: onlineUsers.length,
              itemBuilder: (context, index) {
                final playerName = onlineUsers[index];
                return ListTile(
                  title: Text(playerName),
                  trailing: ElevatedButton(
                    onPressed: () {
                      sendRequest(playerName);
                    },
                    child: Text('Request'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}