import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:chess_game/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../games/choose_color_screen2.dart';
import '../games/color_option2.dart';
import '../main.dart';

class OnlineUser {
  final String username;
  final String uniqueId;

  OnlineUser(this.username, this.uniqueId);
}

class PlayOnline extends StatefulWidget {
  final String bettingAmount;
  const PlayOnline({super.key, required this.bettingAmount, required Map<String, dynamic> userData});

  @override
  _PlayOnlineState createState() => _PlayOnlineState();
}

class _PlayOnlineState extends State<PlayOnline> {
  List<String> websocketUrls = [
    'ws://192.168.29.168:3005',
    // Add more WebSocket server URLs as needed
  ];

  late List<WebSocketChannel> _channels;
  List<OnlineUser> onlineUsers = [];
  late Map<String, dynamic> userData = {};
  Map<String, bool> listeningStatus = {};
  Map<String, bool> inviteStatus = {};

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');
    if (userDataString != null) {
      setState(() {
        userData = jsonDecode(userDataString);
      });
      initializeWebSocket();
    }
  }

  void initializeWebSocket() {
    _channels = websocketUrls.map((url) => IOWebSocketChannel.connect(url)).toList();

    for (var channel in _channels) {
      channel.stream.listen(
            (message) {
          String decodedMessage;
          if (message is Uint8List) {
            decodedMessage = utf8.decode(message);
          } else if (message is String) {
            decodedMessage = message;
          } else {
            print('Unsupported WebSocket message type: ${message.runtimeType}');
            return;
          }

          print('Received WebSocket message: $decodedMessage');
          handleWebSocketMessage(decodedMessage);
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket stream has been closed.');
        },
      );

      channel.sink.add(json.encode({
        'type': 'authenticate',
        'sessionToken': userData['session_token'] ?? '',
      }));
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
        setState(() {
          onlineUsers = usernames.map((username) => OnlineUser(username, '')).toList();
          inviteStatus = {for (var user in onlineUsers) user.username: false};
        });
        print('Online Users: $onlineUsers');
        break;
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
      case 'rematch_request':
        final opponent = decodedMessage['opponent'] as String?;
        if (opponent != null) {
          _showRematchDialog(opponent);
        } else {
          print('Error: No opponent found in rematch request message');
        }
        break;
      case 'rematch_response':
        final response = decodedMessage['response'] as String?;
        if (response != null) {
          if (response == 'accepted') {
            _startNewGame();
          } else {
            _showRejectionDialog();
          }
        } else {
          print('Error: No response found in rematch response message');
        }
        break;

      case 'user_connected':
        final connectedUserId = decodedMessage['data']['id'];
        final connectedUserName = decodedMessage['data']['name'];
        print('User with id $connectedUserId and name $connectedUserName has connected');
        break;
      case 'welcome':
        final username = decodedMessage['username'];
        await saveUsernameToLocal(username);
        print('Received welcome message: ${decodedMessage['message']}');
        break;
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
        // Automatically close the dialog after 5 seconds
        Future.delayed(Duration(seconds: 12), () {
          Navigator.pop(context);
        });

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
    for (var channel in _channels) {
      channel.sink.add(json.encode({
        'type': 'match_response',
        'response': response,
        'opponent': opponent,
        'sessionToken': userData['session_token'] ?? '',
      }));
    }
  }

  void sendInvitation(String opponent) {
    final String? img= prefs.getString('profile_picture_path');
    setState(() {
      inviteStatus[opponent] = true;
    });

    for (var channel in _channels) {
      channel.sink.add(json.encode({
        'type': 'invite_user',
        'opponent': opponent,
        'bettingAmount': widget.bettingAmount,
        'sessionToken': userData['session_token'] ?? '',
        'user_image':img,
      }));
    }
  }
  void startMatchmaking() {
    // Randomly select an online user from the list
    final random = Random();
    if (onlineUsers.isNotEmpty) {
      final randomIndex = random.nextInt(onlineUsers.length);
      final opponent = onlineUsers[randomIndex].username;

      // Send matchmaking request to the selected opponent
      sendMatchmakingRequest(opponent);
    } else {
      print('No online users available for matchmaking.');
    }
  }

  void sendMatchmakingRequest(String opponent) {
    for (var channel in _channels) {
      channel.sink.add(json.encode({
        'type': 'invite_user', // WebSocket server message type
        'opponent': opponent,
        'bettingAmount': widget.bettingAmount,
        'sessionToken': userData['session_token'] ?? '',
      }));
    }
    print('Sent matchmaking request to $opponent');
  }

  void _showRematchDialog(String opponent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Automatically close the dialog after 5 seconds
        Future.delayed(Duration(seconds: 12), () {
          Navigator.pop(context);
        });

        return AlertDialog(
          title: Text("Rematch Request"),
          content: Text("$opponent has requested a rematch. Do you accept?"),
          actions: [
            TextButton(
              onPressed: () {
                sendRematchResponse(opponent, 'accepted');
                Navigator.pop(context);
                _startNewGame();
              },
              child: Text("Accept"),
            ),
            TextButton(
              onPressed: () {
                sendRematchResponse(opponent, 'rejected');
                Navigator.pop(context);
              },
              child: Text("Reject"),
            ),
          ],
        );
      },
    );
  }

  void _startNewGame() {
    Navigator.push(context, MaterialPageRoute(builder:(context)=>ChooseColorScreen2()));
  }
  void _showRejectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Rematch Rejected"),
        content: Text("Your rematch request has been rejected."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
  void sendRematchResponse(String opponent, String response) {
    if (opponent.isEmpty) {
      print('Error: Opponent name is empty.');
      return;
    }

    for (var channel in _channels) {
      channel.sink.add(json.encode({
        'type': 'rematch_response',
        'response': response,
        'opponent': opponent,
        'sessionToken': userData['session_token'] ?? '',
      }));
    }
  }
  @override
  void dispose() {
    for (var channel in _channels) {
      channel.sink.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Play Online'),
        leading: IconButton(
            icon:Icon(Icons.arrow_back), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
              },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/c3.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: startMatchmaking,
                child: Text('Start Matchmaking'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: onlineUsers.length,
                  itemBuilder: (context, index) {
                    String username = onlineUsers[index].username;
                    return ListTile(
                      title: Text(username),
                      trailing: ElevatedButton(
                        onPressed: inviteStatus[username] == true
                            ? null
                            : () {
                          sendInvitation(username);
                        },
                        child: Text(inviteStatus[username] == true ? 'Wait' : 'Invite'),
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
  }
}
