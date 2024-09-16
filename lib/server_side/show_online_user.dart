import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:button_animations/button_animations.dart';
import 'package:chess_game/screen/home_screen.dart';
import 'package:chess_game/server_side/websocket_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../games/ai_handler.dart';
import '../games/choose_color_screen2.dart';
import '../games/game_logic.dart';
import 'package:get_it/get_it.dart';

import '../main.dart';
final logic = GetIt.instance<GameLogic>();
class OnlineUser {
  final String username;
  final String uniqueId;

  OnlineUser(this.username, this.uniqueId);
}

class PlayOnline extends StatefulWidget {
  final String bettingAmount;
 // late WebSocketManager webSocketManager;

  PlayOnline({super.key, required this.bettingAmount, required Map userData});
  @override
  _PlayOnlineState createState() => _PlayOnlineState();
}
class _PlayOnlineState extends State<PlayOnline> {
  late String playerName = '';
  List<OnlineUser> onlineUsers = [];
  late Map<String, dynamic> userData = {};
  bool isLoading = true;
  Set<String> invitedUsers = {}; // Track invited users
  Timer? matchmakingTimer;
  bool isMatchmakingOngoing = true; // Initially set to true
  bool matchmakingFailedCalled = false;
  List<Map<String, dynamic>> activeGameSessions = [];
  late SharedPreferences prefs; // SharedPreferences instance
  late WebSocketManager webSocketManager;

  @override
  void initState() {
    super.initState();
    webSocketManager = GetIt.instance<WebSocketManager>(); // Retrieve the instance here
<<<<<<< HEAD
    initPrefsAndSetupWebSocket(); // Initialize shared preferences and setup WebSocket
=======
    initPrefsAndSetupWebSocket();
    // Initialize shared preferences and setup WebSocket
>>>>>>> d93d3c4 (Initial commit)
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
        setState(() {
          onlineUsers = usernames.map((username) => OnlineUser(username, '')).toList();
        });
       print("$onlineUsers:here online users ");
        if (onlineUsers.isNotEmpty) {
          if (isMatchmakingOngoing) {
            matchmakingFailedCalled = false; // Reset the flag if users are available
            startMatchmaking();
            print("Matchmaking started with available users.");
          }
        } else if (!matchmakingFailedCalled && isMatchmakingOngoing) {
          // Delay the matchmaking failure to allow time for new users to join
          Future.delayed(const Duration(seconds: 10), () {
            // Check onlineUsers again after the delay
            if (onlineUsers.isEmpty) {
              if (isMatchmakingOngoing) {
                matchmakingFailedCalled = true;

                sendMatchmakingFailed();
                isMatchmakingOngoing=false;
                print("No users found after 10 seconds; matchmaking failed.");
              }
            } else {
              // New users joined during the delay; restart matchmaking
              if (onlineUsers.isEmpty) {
                if (isMatchmakingOngoing) {
                  matchmakingFailedCalled = false;
                  startMatchmaking();
                  print("New users joined; restarting matchmaking.");
                }
              }else{
                print("online user not found");
              };
            }
          });
        }
        break;

      case 'match_found':
      //onMatchFoundOrCancelled();
        matchmakingFailedCalled = true;
        isMatchmakingOngoing = false;
        invitedUsers.clear(); // Clear previous invites
        final opponent = decodedMessage['opponent'] as String?;
        if (opponent != null) {
          handleMatchFound(opponent);
        } else {
          print('Error: No opponent found in match found message');
        }
        break;
      case 'active_game_sessions':
        final List<dynamic> sessions = decodedMessage['sessions'];
        // Update a state variable with the list of players currently in game sessions
        setState(() {
          activeGameSessions = sessions.map((session) => {
            'player1': session['player1'],
            'player2': session['player2'],
          }).toList();
        });
        print('Updated active game sessions: $activeGameSessions');
        break;
      case 'starting_ai':
        logic.args.isMultiplayer = false;
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SkillsOption3()));
        // await aiHandler.DifficultySelectionScreen(decodedMessage['type'], context);
        final startingAIMessage = decodedMessage['message'] as String?;
        if (startingAIMessage != null) {
          storeStartingAIValue(startingAIMessage);
          print("ai was atarted");
        } else {
          print('Error: storeStartingAIValue not stored ');
        }
        break;
      case 'game_state':
        print("Starting stage of game state receiving");
        break;

      case 'welcome':
        final username = decodedMessage['username'];
        if (username != null) {
          await saveUsernameToLocal(username);
          print('Received welcome message: ${decodedMessage['message']}');
        } else {
          //print('Error: No username found in welcome message');
        }
      case 'color_selection':
        final color = decodedMessage['color'] as String?;
        if (color != null) {
          await handleColorSelection(color);
        } else {
          print('Error: No color found in color selection message');
        }
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
        if (decodedMessage['type'] == 'game_state') {
          print("gsme state recived from server on userlist");
          //handleReceivedGameState(decodedMessage['game_state']);
        }
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
  Future<void> storeStartingAIValue(String startingAIMessage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('starting_ai', startingAIMessage);
    print("$startingAIMessage :starting_ai stored");
  }

  Future<void> handleMatchFound(String opponent) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('opponent', opponent);
    print('$opponent: Match found');

    setState(() {
      isLoading = false;
      isMatchmakingOngoing = false; // Stop matchmaking
    });

    matchmakingTimer?.cancel(); // Cancel the matchmaking timer

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChooseColorScreen2(),
      ),
    );
  }

  void showGameInvitation(String opponent) {
    sendMatchResponse(opponent, 'accept');
  }
  void sendMatchResponse(String opponent, String response) {
    final String? sessionToken = prefs.getString('sessionToken');
    webSocketManager.send(json.encode({
        'type': 'match_response',
        'response': response,
        'opponent': opponent,
        'sessionToken': sessionToken,
      }));
    //webSocketManager.send(message);
      print('Match response sent: opponent=$opponent, response=$response');
    //}
    // else {
    //   print('WebSocketManager not initialized. Cannot send match response.');
    // }
  }

  Future<void> startMatchmaking() async {
    matchmakingFailedCalled = false;
    matchmakingTimer?.cancel();

    matchmakingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (isMatchmakingOngoing) {
        // Filter out users who have already been invited or are in an active game session
        var availableUsers = onlineUsers.where((user) {
          bool isInActiveSession = activeGameSessions.any((session) {
            return session['player1'] == user.username || session['player2'] == user.username;
          });
          return !invitedUsers.contains(user.username) && !isInActiveSession;
        }).toList();

        if (availableUsers.isNotEmpty) {
          final random = Random();
          final randomIndex = random.nextInt(availableUsers.length);
          final opponent = availableUsers[randomIndex].username;

          // Send the matchmaking request and add the opponent to the invited list
          sendMatchmakingRequest(opponent);
          invitedUsers.add(opponent);

          print("Matchmaking request sent to $opponent.");
        } else {
          // No more users to invite, handle matchmaking failure
          if (!matchmakingFailedCalled) {
            matchmakingFailedCalled = true;
            sendMatchmakingFailed();
            print("Matchmaking failed: No more users available to invite.");
          }
        }
      }
    });
  }

  void sendMatchmakingFailed() {
    webSocketManager.send(json.encode({
        'type': 'no_user_online',  // Custom message type for matchmaking failure
        'sessionToken': userData['session_token'] ?? '',
      }));
      //webSocketManager.send(message);

      // The message sent will be printed inside the send method of WebSocketManager
    //}

    print('Sent matchmaking failed message to the server');
    isMatchmakingOngoing = false;
    matchmakingFailedCalled = true;
  }

<<<<<<< HEAD
  void sendMatchmakingRequest(String opponent) {
=======

  Future<void> sendMatchmakingRequest(String opponent) async {
    final prefs = await SharedPreferences.getInstance();
    int? storedTime = prefs.getInt('selected_time');
>>>>>>> d93d3c4 (Initial commit)
     webSocketManager.send(json.encode({
        'type': 'invite_user', // WebSocket server message type
        'opponent': opponent,
        'bettingAmount': widget.bettingAmount,
        'sessionToken': userData['session_token'] ?? '',
<<<<<<< HEAD
=======
        'time':storedTime,
>>>>>>> d93d3c4 (Initial commit)
      }));
    //webSocketManager.send(message);
    //}
    print('Sent matchmaking request to $opponent');
  }

  @override
  void dispose() {
    super.dispose();
   // widget.webSocketManager.close();
    matchmakingTimer?.cancel();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            final exitMessage = json.encode({
              'type': 'player_exit',
              'username': playerName,
              'sessionToken': userData['session_token'] ?? '',// Replace with the actual current player username
            });

            // Debug: print the message before sending
            print('Sending exit message: $exitMessage');


              webSocketManager.send(exitMessage);
              print('Sent game state update to server: $exitMessage');

            isMatchmakingOngoing = false; // Initially set to false
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          },
        ),
      ),
      body: Stack(
        children: [

          if (isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // AvatarAnimation(),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Searching for opponents... ):',
                    style: TextStyle(fontSize: 18, color: Colors.black45),
                  ),
                  SizedBox(height: 20),
                  // ProgressIndicator(),
                  SizedBox(height: 20),

                ],
              ),
            )
          else
            const Center(
              child: Text(
                'Connected! Starting game...',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}