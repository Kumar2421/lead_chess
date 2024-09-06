
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:chess_game/buttons/back_button.dart';
import 'package:chess_game/buttons/bounce_button.dart';
import 'package:chess_game/colors.dart';
import 'package:chess_game/games/board_piece.dart';
import 'package:chess_game/screen/home_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../main.dart';
import '../screen/homepage.dart';
import '../server_side/websocket_manager.dart';
import '../spin_wheel.dart';
import '../user/current_user.dart';
import '../user/users.dart';
import 'piece_widget.dart';
import 'package:flutter/material.dart';
import 'player_bar.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:io';
import 'package:get_it/get_it.dart';
import 'game_logic.dart';
final logic = GetIt.instance<GameLogic>();
const String testDevice = 'YOUR_DEVICE_ID';
const int maxFailedLoadAttempts = 3;
class LocalGamepage3 extends StatefulWidget {
  final int selectedTime;

  const LocalGamepage3({super.key, required this.selectedTime});

  @override
  State<LocalGamepage3> createState() => _LocalGamepage3State();
}

class _LocalGamepage3State extends State<LocalGamepage3>with WidgetsBindingObserver {
  void update() => setState(() => {});

  late Map<String, dynamic> userData = {};
  late String opponentName = '';
  final CurrentUser _currentUser = Get.put(CurrentUser());
  //List<User1> users = [];
  Users currentUser = Get.find<CurrentUser>().users;
  late String playerName = '';
  late Timer _heartbeatTimer;
  bool _isOpponentOnline = true;
  String? _userId;
  Timer _offlineTimer = Timer(Duration.zero, () {});  bool _isDialogShown = false;
  late String email = '';
  late SharedPreferences prefs;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  late WebSocketManager webSocketManager;

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  final double _scaleFactor = 1.0;

  @override
  void initState() {
    logic.addListener(update);
    super.initState();
    startHeartbeat();
    webSocketManager = GetIt.instance<WebSocketManager>(); // Retrieve the instance here
    Wakelock.enable();
    //initializeWebSocket();
    //startHeartbeat();
    initializePrefs();
    loadUserData();
  }

  Future<void> initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (webSocketManager == null) {
        setState(() {
          _isOpponentOnline = false;
        });
        _heartbeatTimer.cancel();
      } else {
        // Send ping message as JSON
        webSocketManager.send(json.encode({
          'type': 'ping',
          'sessionToken': userData['session_token'] ?? '',
          'username': playerName,
        }));

        // Assume opponent is offline until pong is received
        _isOpponentOnline = false;
      }

    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _handleAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
    }
  }
  void _handleAppPaused() {
    print('App is in the background.');
    webSocketManager.send(json.encode({
      'type': 'player_status',
      'status': 'offline',
      'username': playerName,
      'sessionToken': userData['session_token'] ?? ''
    }));
    setState(() {
      _isOpponentOnline = false;
    });
// Stop sending ping messages
    _heartbeatTimer?.cancel();
  }

  void _handleAppResumed() {
    print('App is in the foreground.');
    webSocketManager.send(json.encode({
      'type': 'player_status',
      'status': 'online',
      'username': playerName,
      'sessionToken': userData['session_token'] ?? ''
    }));

    setState(() {
      _isOpponentOnline = true;
    });
    // Restart heartbeat
    startHeartbeat();
  }
  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String name = _currentUser.users.name;
    String? userDataString = prefs.getString('userData');

    //final String? opponent = await getOpponentName();
    if (userDataString != null) {
      setState(() {
        playerName = userData['name'] ?? 'Player';
        userData = jsonDecode(userDataString);
      });
    }
    playerName=name;
  }


  Future<void> handleWebSocketMessage(String message) async {
    final decodedMessage = json.decode(message);
    print('Received WebSocket message: $decodedMessage');
    switch (decodedMessage['type']) {
      case 'player_exit':
        handlePlayerExit(decodedMessage);
        break;
      case 'pong':
        setState(() {
          _isOpponentOnline = true;
        });
        break;
      case 'opponent_status':
        handleOpponentStatus(decodedMessage);
        break;
      default:
        print('Unknown WebSocket message type: ${decodedMessage['type']}');
    }
  }void handlePlayerExit(Map<String, dynamic> message) {
    final exitMessage = message['message'] as String?;
    if (exitMessage != null) {
      print(exitMessage);

      // Display a dialog or notification to inform the user
      if (!_isDialogShown) {
        _isDialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false, // Prevent dismissal by tapping outside
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Opponent Exited'),
            content: Text(exitMessage),
            // actions: [
            //   TextButton(
            //     onPressed: () {
            //       Navigator.pop(context);
            //       _isDialogShown = false;
            //       // Handle any additional cleanup or navigation
            //     },
            //     child: Text('OK'),
            //   ),
            // ],
          ),
        );
      }
    }
  }

  void handleOpponentStatus(Map<String, dynamic> message) {
    final status = message['status'] as String?;
    final username = message['username'] as String?;
    String? userDataString = prefs.getString('userData');
    if (userDataString != null) {
      setState(() {
        // Decode JSON to a Map
        Map<String, dynamic> userDataMap = jsonDecode(userDataString);
        // Extract user_id from the Map
        String? userId = userDataMap['user_id'];
        // if (userId != null) {
        //   // Now you can use the userId in other methods
        //   senddrowAmountToDatabase(userId);
        //   print("winning amount sended");
        // }
      });

      if (status != null && username != null) {
        print('Opponent $username is now $status');

        if (status == 'offline') {
          // Show exit dialog immediately
          handlePlayerExit({
            'message': '$username has exited the game.',
          });

          // Start a timer to check if the opponent remains offline for one minute
          _offlineTimer.cancel();
          _offlineTimer = Timer(Duration(minutes: 1), () {
            setState(() {
              _isOpponentOnline = false;
              // Update the dialog text to "You Win" if the opponent remains offline
              if (_isDialogShown) {
                Navigator.pop(context);
                _isDialogShown = false;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) =>
                      AlertDialog(
                        title: const Text('Opponent Offline'),
                        content: const Text('You Win!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              final prefs = GetIt.instance<SharedPreferences>();
                              String? sessionToken = prefs.getString('sessionToken');

                          final exitMessage = json.encode({
                          'type': 'player_exit',
                          //'username': playerName,
                          'sessionToken': sessionToken ,// Replace with the actual current player username
                          });

                          // Debug: print the message before sending
                          print('Sending exit message: $exitMessage');


                          webSocketManager.send(exitMessage);
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => const Homepage()));
                              // Handle any additional cleanup or navigation
                              getGameResultMessage();
                              logic.clear();
                              // Navigator.popUntil(context, (route) => route.isFirst);
                              logic.player1Timer.stop();
                              logic.player2Timer.stop();
                              _heartbeatTimer.cancel();
                              WidgetsBinding.instance.removeObserver(this);
                              _offlineTimer.cancel();
                              print(" calling getGameResultMessage()");
                            },

                            child: Text('exit'),
                          ),
                        ],
                      ),
                );
              }
            });
            print('Opponent $username is offline for more than one minute');
          });
        } else if (status == 'online') {
          // Cancel the offline timer if the opponent comes back online
          _offlineTimer.cancel();
          setState(() {
            _isOpponentOnline = true;
          });
          if (_isDialogShown) {
            Navigator.pop(context);
            _isDialogShown = false;
          }
          print('Opponent $username is back online');
        }
      } else {
        print('Error: Status or username information not found in the message');
      }
    }
  }

  String getGameResultMessage() {
    String? selectedColor = prefs.getString('selected_color')?.toLowerCase() ?? 'unknown';
    String? result = prefs.getString('game_result')?.toLowerCase() ?? 'unknown';

    if (result == 'draw') {
      senddrowAmountToDatabase(currentUser.userId);
      return 'It\'s a Draw!';
    } else if (result.contains('wins')) {
      if ((selectedColor == 'black' && result.contains('black')) ||
          (selectedColor == 'white' && result.contains('white'))) {
        sendwinningAmountToDatabase(currentUser.userId);
        return 'You Win!';
      } else {
        return 'You Lose!';
      }
    } else {
      return 'You Lose!';
    }
  }
  Future<void> senddrowAmountToDatabase(String userId) async {
    const url = 'https://schmidivan.com/Esakki/ChessGame/ending_winning_amount';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedBettingAmount = prefs.getString('bettingAmount');

    if (storedBettingAmount == null) {
      print('No betting amount found in SharedPreferences.');
      return;
    }

    final originalAmount = double.parse(storedBettingAmount.split(' ')[0]);
    final discountedAmount = originalAmount * 0.50;
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': userId,
          'betting_amount': discountedAmount.toString(),
        },
      );

      if (response.statusCode == 200) {
        print('Game data sent successfully: $email, $discountedAmount');
      } else {
        print('Failed to send game data. HTTP status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending game data: $e');
    }
  }


  Future<void> sendwinningAmountToDatabase(String userId) async {
    const url = 'https://schmidivan.com/Esakki/ChessGame/ending_winning_amount';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedBettingAmount = prefs.getString('bettingAmount');

    if (storedBettingAmount == null) {
      print('No betting amount found in SharedPreferences.');
      return;
    }

    final originalAmount = double.parse(storedBettingAmount.split(' ')[0]);
    final discountedAmount = (originalAmount - (originalAmount * 0.15)) * 2; // Applying 15% discount and multiplying by 2

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': userId,
          'betting_amount': discountedAmount.toString(),
        },
      );

      if (response.statusCode == 200) {
        print('Game data sent successfully: $discountedAmount');
      } else {
        print('Failed to send game data. HTTP status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending game data: $e');
    }
  }
  @override
  void dispose() {
    super.dispose();
    logic.clear(); // Clear the game state
    logic.removeListener(update);
    // logic.player1Timer.stop();
    // logic.player2Timer.stop();
    _bannerAd?.dispose();
    Wakelock.disable();
    // for (var channel in _channels) {
    //   channel.sink.close();
    //   _offlineTimer.cancel();
    // }
    // _heartbeatTimer.cancel();
    _heartbeatTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _offlineTimer.cancel();
  }

  // int selectedTime = 1;
  bool isDialogShown = false;

  Widget _buildTimers() {
    if (!isDialogShown &&
        (logic.player1Timer.currentTime.inSeconds <= 0 || logic.player2Timer.currentTime.inSeconds <= 0)) {
      isDialogShown = true;
      // WidgetsBinding.instance.addPostFrameCallback((_) => _showEndDialog(context));
      Timer(const Duration(milliseconds: 500), () => _showEndDialog(context));
      //_endGame(logic.turn());
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RotatedBox(
              quarterTurns: 2,
              child: Text(
                'White: ${logic.player1Timer.currentTime.inMinutes}:${(logic.player1Timer.currentTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xB3F5E3CA)),
              ),
            ),
            RotatedBox(
              quarterTurns: 2,
              child: Text(
                'Black: ${logic.player2Timer.currentTime.inMinutes}:${(logic.player2Timer.currentTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xB3F5E3CA)),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildTimers2() {
    if (!isDialogShown &&
        (logic.player1Timer.currentTime.inSeconds <= 0 || logic.player2Timer.currentTime.inSeconds <= 0)) {
      isDialogShown = true;
      // WidgetsBinding.instance.addPostFrameCallback((_) => _showEndDialog(context));
      Timer(const Duration(milliseconds: 500), () => _showEndDialog(context));
      //_endGame(logic.turn());
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'White: ${logic.player1Timer.currentTime.inMinutes}:'
                  '${(logic.player1Timer.currentTime.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color(0xB3F5E3CA)),
            ),
            Text(
              'Black: ${logic.player2Timer.currentTime.inMinutes}:'
                  '${(logic.player2Timer.currentTime.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xB3F5E3CA)),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildMultiplayerBar(bool isMe, PieceColor color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            child: PlayerBar(isMe, color)
        ),
      ],
    );
  }
  Widget _buildMultiplayerBar2(bool isMe, PieceColor color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            child: RotatedBox(
                quarterTurns: 2,
                child: PlayerBar(isMe, color))
        ),
      ],
    );
  }
  bool isPromotionDialogShown = false;
  bool showEndDialog =false;
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final mainPlayerColor = logic.args.asBlack ? PieceColor.BLACK : PieceColor.WHITE;
    final secondPlayerColor = logic.args.asBlack ? PieceColor.WHITE : PieceColor.BLACK;

    bool isMainTurn = mainPlayerColor == logic.turn();
    if (logic.isPromotion && (logic.args.isMultiplayer || isMainTurn) && !isPromotionDialogShown) {
      isPromotionDialogShown = true;
      Timer(const Duration(milliseconds: 10), () => _showPromotionDialog(context));
    } else if (logic.gameOver() && !showEndDialog) {
      showEndDialog =true;
      Timer(const Duration(milliseconds: 500), () => _showEndDialog(context));
    }

    final timerService =Provider.of<TimerService>(context);

    return WillPopScope(
        onWillPop: () async {
      _showSaveDialog(context);
      return false;
    },
    child: Scaffold(
      backgroundColor: color.navy1,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight/18),
            Row(
              children: [
                MaterialButton(
                  height: screenHeight/25,
                  minWidth: screenWidth/10,
                  onPressed: () {
                    if (!logic.gameOver()) {
                      _showSaveDialog(context);
                    } else {
                      timerService.startOfflineTimer(Duration(minutes: 1));
                      _showSaveDialog(context);
                      // Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                  color: const Color(0xB3F5E3CA),
                  child: const Text('Exit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),

              ],
            ),
            SizedBox(
              height: screenHeight/4, // Set your desired height
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/background_image1.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: logic.args.isMultiplayer
                        ? _buildMultiplayerBar2(true, mainPlayerColor) // Change the secondPlayerColor to MainPlayerColor
                        : PlayerBar(false, secondPlayerColor),
                  ),
                ],
              ),
            ),
            BoardPiece(),
            SizedBox(
              height: screenHeight/5, // Set your desired height
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/background1.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: logic.args.isMultiplayer
                        ? _buildMultiplayerBar(false, secondPlayerColor) // Change the mainPlayerColor to SecondPlayerColor
                        : PlayerBar(true, mainPlayerColor),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
  Future<void> _showSaveDialog(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            AlertDialog(
                backgroundColor: Color(0xB3F5E3CA),
                title:  Align(
                  alignment: Alignment.topCenter,
                  child: Text("Exit",
                      style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/12,color: Colors.yellow)),
                ),
                // content: Text("Do you want to Exit this game?",
                //     style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: Colors.yellow)),
                actions: [
                  TextButton(
                    onPressed: () {
                      AudioHelper.buttonClickSound();
                      logic.player1Timer.stop();
                      logic.player2Timer.stop();
                      Navigator.pop(context);
                      // logic.clear();
                      // Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Text("No",
                        style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  ),

                  TextButton(
                    onPressed: () async {
                      final prefs = GetIt.instance<SharedPreferences>();
                      // Perform the cleanup
                      await prefs.remove('opponent');
                      print('Opponent removed from SharedPreferences');
                      await prefs.remove('starting_ai');
                      print('AI removed from SharedPreferences');
                      await prefs.remove('selected_color');
                      print('Selected color removed from SharedPreferences');
                      await prefs.remove('game_mode');
                      print('Game mode removed from SharedPreferences');

                      String? sessionToken = prefs.getString('sessionToken');


                      final exitMessage = json.encode({
                        'type': 'player_exit',
                        //'username': playerName,
                        'sessionToken': sessionToken ,// Replace with the actual current player username
                      });

                      // Debug: print the message before sending
                      print('Sending exit message: $exitMessage');


                      webSocketManager.send(exitMessage);
                      //_showInterstitialAd();
                      AudioHelper.buttonClickSound();
                      logic.clear();
                      // Navigator.popUntil(context, (route) => route.isFirst);
                      logic.player1Timer.stop();
                      logic.player2Timer.stop();
                      _heartbeatTimer.cancel();
                      WidgetsBinding.instance.removeObserver(this);
                      _offlineTimer.cancel();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const HomeScreen()));
                    },
                    child: Text("Yes",
                        style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  ),
                ]
            )
    );
  }

  Future<void> _showEndDialog(BuildContext context) async {
    double screenWidth = MediaQuery.of(context).size.width;
    var title = "";
    String result;

    if (logic.inCheckmate()) {
      result = logic.turn() == PieceColor.WHITE ? "Black Wins" : "White Wins";
      title = "Checkmate!\n$result";
    } else if (logic.inDraw()) {
      title = "Draw!\n";
      if (logic.insufficientMaterial()) {
        title += "By Insufficient Material";
      } else if (logic.inThreefoldRepetition()) {
        title += "By Repetition";
      } else if (logic.inStalemate()) {
        title += "By Stalemate";
      } else {
        title += "By the 50-move rule";
      }
      result = "Draw";
    } else {
      result = logic.turn() == PieceColor.WHITE ? "Black Wins" : "White Wins";
      title = "Time's up!\n$result";
    }

    // Save the result to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('game_result', result);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            AlertDialog(
                backgroundColor: Color(0xB3F5E3CA),
                title: Text(title,
                    style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/12,color: Colors.yellow)),
                actions: [
                  TextButton(
                    onPressed: () {
                      AudioHelper.buttonClickSound();
                      logic.player1Timer.stop();
                      logic.player2Timer.stop();
                      Navigator.pop(context);
                      // logic.clear();
                      // Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Text("No",
                        style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  ),

                  TextButton(
                    onPressed: () async {
                      //_showInterstitialAd();
                      AudioHelper.buttonClickSound();
                      logic.clear();
                      final prefs = GetIt.instance<SharedPreferences>();
                      // Perform the cleanup
                      await prefs.remove('opponent');
                      print('Opponent removed from SharedPreferences');
                      await prefs.remove('starting_ai');
                      print('AI removed from SharedPreferences');
                      await prefs.remove('selected_color');
                      print('Selected color removed from SharedPreferences');
                      await prefs.remove('game_mode');
                      print('Game mode removed from SharedPreferences');

                      String? sessionToken = prefs.getString('sessionToken');


                      final exitMessage = json.encode({
                        'type': 'game_end',
                        //'username': playerName,
                        'sessionToken': sessionToken ,// Replace with the actual current player username
                      });

                      // Debug: print the message before sending
                      print('Sending exit message: $exitMessage');


                      webSocketManager.send(exitMessage);
                      print('Sent game state update to server: $exitMessage');
                      //  Navigator.popUntil(context, (route) => route.isFirst);
                      logic.player1Timer.stop();
                      logic.player2Timer.stop();
                      logic.clear();
                      _heartbeatTimer.cancel();
                      WidgetsBinding.instance.removeObserver(this);
                      _offlineTimer.cancel();
                      Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                      showEndDialog = false;
                    },
                    child: Text("Exit",
                        style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  )
                ]));
    // showEndDialog =false;
    // isDialogShown = false;
  }

  void _showPromotionDialog(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    var pieces = [
      PieceType.QUEEN,
      PieceType.ROOK,
      PieceType.BISHOP,
      PieceType.KNIGHT
    ].map((pieceType) => Piece(pieceType, logic.turn()));
    final asBlack = logic.args.asBlack;
    var futureValue = showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => Transform.rotate(
            angle: (logic.turn() == PieceColor.BLACK) != asBlack
                ? math.pi
                : 0,
            child: SimpleDialog(
                title: Text('Promote to',
                    style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                shadowColor: Colors.green,
                //backgroundColor: Colors.grey,
                surfaceTintColor: Colors.green,
                children: pieces
                    .map((piece) => SimpleDialogOption(
                    onPressed: () => Navigator.of(context).pop(piece),
                    child: SizedBox(
                        height: 60,
                        child: PieceWidget(piece: piece)
                    )))
                    .toList())));
    // futureValue.then((piece) => logic.promote(piece));
    futureValue.then((piece) {
      logic.promote(piece);
      isPromotionDialogShown = false; // Reset the flag
    });

  }
}