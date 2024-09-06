import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:chess_game/server_side/websocket_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../games/choose_color_screen2.dart';
import '../games/color_option2.dart';
import '../screen/home_screen.dart';

class OnlineUser {
  final String username;
  final String uniqueId;

  OnlineUser(this.username, this.uniqueId);
}

class PlayWithFriends extends StatefulWidget {
  final String bettingAmount;
  const PlayWithFriends({super.key, required this.bettingAmount, required Map<String, dynamic> userData});

  @override
  _PlayOnlineState createState() => _PlayOnlineState();
}

class _PlayOnlineState extends State<PlayWithFriends> {
  List<OnlineUser> onlineUsers = [];
  List<OnlineUser> filteredUsers = [];
  late Map<String, dynamic> userData = {};
  Map<String, bool> listeningStatus = {};
  Map<String, bool> inviteStatus = {};
  late String playerName = '';
  bool isLoading = true;
  Set<String> invitedUsers = {}; // Track invited users
  Timer? matchmakingTimer;
  bool isMatchmakingOngoing = true; // Initially set to true
  bool matchmakingFailedCalled = false;
  List<Map<String, dynamic>> activeGameSessions = [];
  late SharedPreferences prefs; // SharedPreferences instance
  late WebSocketManager webSocketManager;
  TextEditingController searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    webSocketManager = GetIt.instance<WebSocketManager>(); // Retrieve the instance here
    initPrefsAndSetupWebSocket(); // Initialize shared preferences and setup WebSocket
  }

  Future<void> initPrefsAndSetupWebSocket() async {
    prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');
    if (userDataString != null) {
      setState(() {
        userData = jsonDecode(userDataString);
      });
    }
    setupWebSocket(); // Setup WebSocket after prefs is initialized
  }

  void setupWebSocket() {
    // Check if webSocketManager is initialized
    if (webSocketManager != null) {
      webSocketManager.stream.listen((message) {
        print('Message received in PlayOnline: $message');
        handleWebSocketMessage(message);  // Implement your message handling logic here
      });

      // Send an authentication message to the server
      String? sessionToken = prefs.getString('sessionToken');
      if (sessionToken != null && sessionToken.isNotEmpty) {
        webSocketManager.send(json.encode({
          'type': 'authenticate',
          'sessionToken': sessionToken,
        }));
      } else {
        print('Invalid session token. Cannot authenticate.');
      }
    } else {
      print('webSocketManager is not initialized. Cannot set up WebSocket.');
    }
  }



  Future<void> handleWebSocketMessage(String message) async {
    final decodedMessage = json.decode(message);
    print('Received WebSocket message: $decodedMessage');
    switch (decodedMessage['type']) {
      case 'online_users':
        final List<dynamic> usernames = decodedMessage['usernames'];
        final Map<String, dynamic> bettingAmountsMap = decodedMessage['betting_amounts'];
        final Map<String, int> bettingAmounts = bettingAmountsMap.map((key, value) => MapEntry(key, value as int));

        print('Usernames received: $usernames');
        print('Betting amounts received: $bettingAmounts');

        setState(() {
          // If there is only one user, ensure that user is included
          onlineUsers = usernames.map((username) => OnlineUser(username, '')).toList();
          inviteStatus = {for (var user in onlineUsers) user.username: false};
        });
      case 'match_found':
        final opponent = decodedMessage['opponent'] as String?;
        if (opponent != null) {
          handleMatchFound(opponent);
        } else {
          print('Error: No opponent found in match found message');
        }
        break;
      case 'game_state':
        print("Starting stage of game state receiving");
        break;
      case 'user_connected':
        final connectedUserId = decodedMessage['data']['id'];
        final connectedUserName = decodedMessage['data']['name'];
        print('User with id $connectedUserId and name $connectedUserName has connected');
        break;
      case 'welcome':
        final username = decodedMessage['username'];
        if (username != null) {
          await saveUsernameToLocal(username);
          print('Received welcome message: ${decodedMessage['message']}');
        } else {
          //print('Error: No username found in welcome message');
        }
      case 'user_disconnected':
        final disconnectedUserId = decodedMessage['data'];
        print('User with id $disconnectedUserId has disconnected');
        break;
      case 'color_selection':
        final color = decodedMessage['color'] as String?;
        if (color != null) {
          await handleColorSelection(color);
        } else {
          print('Error: No color found in color selection message');
        }
        break;
      case 'connection_success':
        print("Connection success");
        break;
      case 'game_invitation':
        final opponent = decodedMessage['opponent'] as String?;
        if (opponent != null) {
          showGameInvitation(opponent);
        } else {
          print('Error: No opponent found in game invitation message');
        }
        break;
      default:
        print('Unknown WebSocket message type: ${decodedMessage['type']}');
    }
  }

  Future<void> handleColorSelection(String color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_color', color);
    print('Color $color saved to local storage');
  }
  Future<void> saveUsernameToLocal(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    print('Username $username saved to local storage');
  }
  Future<void> handleMatchFound(String opponent) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('opponent', opponent);
    print('$opponent: get here also');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChooseColorScreen2(),
      ),
    );
  }

  void showGameInvitation(String opponent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Invitation'),
          content: Text('$opponent has invited you to a game. Do you accept?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                sendMatchResponse(opponent, 'reject');
              },
              child: Text('Reject'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                sendMatchResponse(opponent, 'accept');
              },
              child: Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  void sendMatchResponse(String opponent, String response) {
    webSocketManager.send(json.encode({
        'type': 'match_response',
        'response': response,
        'opponent': opponent,
        'sessionToken': userData['session_token'] ?? '',
      }));
    }


  @override
  void dispose() {
    // for (var channel in _channels) {
    //   channel.sink.close();
    // }
    super.dispose();
  }

  void sendInvitation(String opponent) {
    setState(() {
      inviteStatus[opponent] = true;
    });

    webSocketManager.send(json.encode({
        'type': 'invite_user',
        'opponent': opponent,
        'bettingAmount': widget.bettingAmount,
        'sessionToken': userData['session_token'] ?? '',
      }));

  }


  void filterUsers(String query) {
    setState(() {
      filteredUsers = onlineUsers
          .where((user) => user.username.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play With Friends'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final exitMessage = json.encode({
              'type': 'player_exit',
              'username': playerName,
              'sessionToken': userData['session_token'] ?? '',
            });

            print('Sending exit message: $exitMessage');
            webSocketManager.send(exitMessage);

            isMatchmakingOngoing = false;
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HomeScreen()));
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/home.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: filterUsers,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    String username = filteredUsers[index].username;
                    return ListTile(
                      title: Text(username),
                      trailing: ElevatedButton(
                        onPressed: inviteStatus[username] == true
                            ? null
                            : () {
                          sendInvitation(username);
                        },
                        child: Text(
                            inviteStatus[username] == true ? 'Wait' : 'Invite'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }}
