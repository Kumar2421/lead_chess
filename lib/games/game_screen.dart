import 'package:chess_game/colors.dart';
import 'package:chess_game/games/winningscreen.dart';
import 'package:chess_game/screen/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../server_side/show_online_user.dart';
import 'board_piece.dart';
import 'piece_widget.dart';
import 'package:flutter/material.dart';
import 'player_bar.dart';

import 'dart:math' as math;
import 'dart:async';

import 'package:get_it/get_it.dart';
import 'game_logic.dart';
final logic = GetIt.instance<GameLogic>();

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  void update() => setState(() => {});
  @override
  void initState() {
    logic.addListener(update);
    super.initState();
  }

  @override
  void dispose() {
    logic.clear(); // Clear the game state
    logic.removeListener(update);
    logic.player1Timer.stop();
    logic.player2Timer.stop();
    super.dispose();
  }

  int selectedTime = 1;
  bool isDialogShown = false;

  Widget _buildMultiplayerBar(bool isMe, PieceColor color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
            flex: 7,
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
        Flexible(
            flex: 7,
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

    return Scaffold(
      backgroundColor: color.navy1,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight/20,),
            Row(
              children: [
                MaterialButton(
                  height: screenHeight/25,
                  minWidth: screenWidth/10,
                  onPressed: (){
                    if (!logic.gameOver()) {
                      _showSaveDialog(context);
                    } else {
                      _showSaveDialog(context);
                      // Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                  color: const Color(0xB3F5E3CA),
                  child: const Text('Exit',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),),
                SizedBox(width: screenWidth/8,),
                MaterialButton(
                  height: screenHeight/25,
                  minWidth: screenWidth/10,
                  onPressed:logic.canUndo() ? () => logic.undo() : null,
                  color: const Color(0xB3F5E3CA),
                  child: const Icon(Icons.undo,size: 30,),),
                SizedBox(width: screenWidth/8,),
                MaterialButton(
                  height: screenHeight/25,
                  minWidth: screenWidth/10,
                  onPressed: logic.canRedo() ? () => logic.redo() : null,
                  color: const Color(0xB3F5E3CA),
                  child: const Icon(Icons.redo,size: 30,),),
              ],
            ),
            // _buildTimers(),
            SizedBox(
              height: screenHeight/7, // Set your desired height
              width: double.infinity,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: logic.args.isMultiplayer
                    ? _buildMultiplayerBar2(true, mainPlayerColor) //change the secondPlayerColor to MainPlayerColor
                    : PlayerBar(false, secondPlayerColor),
              ),
            ),
            // ignore: prefer_const_constructors
            BoardPiece(),
            SizedBox(
              height: screenHeight/7, // Set your desired height
              width: double.infinity,
              child: Align(
                alignment: Alignment.topCenter,
                child: logic.args.isMultiplayer
                    ? _buildMultiplayerBar(false, secondPlayerColor) // change the mainPlayerColor to SecondPlayerColor
                    : PlayerBar(true, mainPlayerColor),
              ),
            ),
            // _buildTimers2()
          ],
        ),
      ),
    );
  }

  void _showSaveDialog(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
                backgroundColor: const Color(0xB3F5E3CA),
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
                    onPressed: () {
                      final args = logic.args;
                      logic.clear();
                      args.asBlack = !args.asBlack;
                      logic.args = args;
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/game2');
                      logic.start();
                    },
                    child: Text("Rematch",
                        style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  ),
                  TextButton(
                    onPressed: () {
                      logic.clear();
                      // Navigator.popUntil(context, (route) => route.isFirst);
                      logic.player1Timer.stop();
                      logic.player2Timer.stop();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const PlayOnline(bettingAmount: '', userData: {})));

                    },
                    child: Text("Yes",
                        style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                  ),
                ]
            )
    );
  }
  void _showEndDialog(BuildContext context) async {
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
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xB3F5E3CA),
        title: Text(
          title,
          style: GoogleFonts.oswald(
            fontWeight: FontWeight.w500,
            fontSize: screenWidth / 12,
            color: Colors.yellow,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Future.delayed(Duration(seconds: 3));
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GameResultScreen()),
              );
            },
            child: Text(
              "Rematch",
              style: GoogleFonts.oswald(
                fontWeight: FontWeight.w500,
                fontSize: screenWidth / 15,
                color: color.navy1,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              logic.clear();
              logic.player1Timer.stop();
              logic.player2Timer.stop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlayOnline(bettingAmount: '', userData: {}),
                ),
              );
              showEndDialog = false;
            },
            child: Text(
              "Exit",
              style: GoogleFonts.oswald(
                fontWeight: FontWeight.w500,
                fontSize: screenWidth / 15,
                color: color.navy1,
              ),
            ),
          ),
        ],
      ),
    );
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
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:chess_game/colors.dart';
// import 'package:chess_game/games/winningscreen.dart';
// import 'package:chess_game/screen/home_screen.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import '../server_side/show_online_user.dart';
// import 'board_piece.dart';
// import 'piece_widget.dart';
// import 'package:flutter/material.dart';
// import 'player_bar.dart';
// import 'dart:math' as math;
// import 'dart:async';
// import 'package:get_it/get_it.dart';
// import 'game_logic.dart';
// final logic = GetIt.instance<GameLogic>();
// late String opponentName = '';
// late Map<String, dynamic> userData = {};
// class GameScreen extends StatefulWidget {
//   const GameScreen({super.key});
//
//   @override
//   State<GameScreen> createState() => _GameScreenState();
// }
//
// class _GameScreenState extends State<GameScreen> {
//   Map<String, bool> inviteStatus = {};
//
//   List<String> websocketUrls = [
//     'ws://192.168.29.168:3009',
//     // Add more WebSocket server URLs as needed
//   ];
//   late List<WebSocketChannel> _channels;
//   void update() => setState(() => {});
//   @override
//   void initState() {
//     logic.addListener(update);
//     super.initState();
//     loadUserData();
//
//   }
//   String opponentName = '';
//   Future<String?> getOpponentName() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? opponent = prefs.getString('opponent');
//     print('$opponent: get here');
//     return opponent;
//   }
//   Future<void> loadUserData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? userDataString = prefs.getString('userData');
//     String? opponent = await getOpponentName();
//     if (userDataString != null && opponent != null) {
//       setState(() {
//         userData = jsonDecode(userDataString);
//         opponentName = opponent; // Assign opponentName here
//       });
//       print('Loaded userData: $userData');
//       print('Loaded opponent: $opponent');
//       initializeWebSocket();
//     } else {
//       print('No user data or opponent found.');
//     }
//   }
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
//           //handleWebSocketMessage1(decodedMessage);
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
//   //
//   // Future<void> handleWebSocketMessage1(String message) async {
//   //   final decodedMessage = json.decode(message);
//   //   switch (decodedMessage['type']) {
//   //     case 'rematch_request':
//   //       final opponent = decodedMessage['opponent'] as String?;
//   //       if (opponent != null) {
//   //         _showRematchDialog(opponent);
//   //       } else {
//   //         print('Error: No opponent found in rematch request message');
//   //       }
//   //       break;
//   //     case 'rematch_response':
//   //       final response = decodedMessage['response'] as String?;
//   //       if (response != null) {
//   //         if (response == 'accepted') {
//   //           _startNewGame();
//   //         } else {
//   //           _showRejectionDialog();
//   //         }
//   //       } else {
//   //         print('Error: No response found in rematch response message');
//   //       }
//   //       break;
//   //   }
//   // }
//   void sendRematchRequest(String opponent) {
//     if (opponent.isEmpty) {
//       print('Error: Opponent name is empty.');
//       return;
//     }
//
//     for (var channel in _channels) {
//       channel.sink.add(jsonEncode({
//         'type': 'rematch_request',
//         'sessionToken': userData['session_token'] ?? '',
//         'opponent': opponent,
//       }));
//       print('Sent rematch request to $opponent');
//     }
//   }
//
//   // void sendRematchResponse(String opponent, String response) {
//   //   if (opponent.isEmpty) {
//   //     print('Error: Opponent name is empty.');
//   //     return;
//   //   }
//   //
//   //   for (var channel in _channels) {
//   //     channel.sink.add(json.encode({
//   //       'type': 'rematch_response',
//   //       'response': response,
//   //       'opponent': opponent,
//   //       'sessionToken': userData['session_token'] ?? '',
//   //     }));
//   //   }
//   // }
//   //
//   // void _showRematchDialog(String opponent) {
//   //   showDialog(
//   //     context: context,
//   //     builder: (BuildContext context) => AlertDialog(
//   //       title: Text("Rematch Request"),
//   //       content: Text("$opponent has requested a rematch. Do you accept?"),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () {
//   //             sendRematchResponse(opponent, 'accepted');
//   //             Navigator.pop(context);
//   //             _startNewGame();
//   //           },
//   //           child: Text("Accept"),
//   //         ),
//   //         TextButton(
//   //           onPressed: () {
//   //             sendRematchResponse(opponent, 'rejected');
//   //             Navigator.pop(context);
//   //           },
//   //           child: Text("Reject"),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   // void _showRejectionDialog() {
//   //   showDialog(
//   //     context: context,
//   //     builder: (BuildContext context) => AlertDialog(
//   //       title: Text("Rematch Rejected"),
//   //       content: Text("Your rematch request has been rejected."),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(context),
//   //           child: Text("OK"),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   @override
//   void dispose() {
//     logic.clear(); // Clear the game state
//     logic.removeListener(update);
//     logic.player1Timer.stop();
//     logic.player2Timer.stop();
//     super.dispose();
//   }
//
//   int selectedTime = 1;
//   bool isDialogShown = false;
//
//   Widget _buildMultiplayerBar(bool isMe, PieceColor color) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Flexible(
//             flex: 7,
//             child: PlayerBar(isMe, color)
//         ),
//
//       ],
//     );
//   }
//   Widget _buildMultiplayerBar2(bool isMe, PieceColor color) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Flexible(
//             flex: 7,
//             child: RotatedBox(
//                 quarterTurns: 2,
//                 child: PlayerBar(isMe, color))
//         ),
//
//       ],
//     );
//   }
//   bool isPromotionDialogShown = false;
//   bool showEndDialog =false;
//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//     final mainPlayerColor = logic.args.asBlack ? PieceColor.BLACK : PieceColor.WHITE;
//     final secondPlayerColor = logic.args.asBlack ? PieceColor.WHITE : PieceColor.BLACK;
//
//     bool isMainTurn = mainPlayerColor == logic.turn();
//     if (logic.isPromotion && (logic.args.isMultiplayer || isMainTurn) && !isPromotionDialogShown) {
//       isPromotionDialogShown = true;
//       Timer(const Duration(milliseconds: 10), () => _showPromotionDialog(context));
//     } else if (logic.gameOver() && !showEndDialog) {
//       showEndDialog =true;
//       Timer(const Duration(milliseconds: 500), () => _showEndDialog(context));
//       //Timer(const Duration(milliseconds: 500), () => _showRematchDialog(opponentName));
//
//     }
//
//     return Scaffold(
//       backgroundColor: color.navy1,
//       body: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: screenHeight/20,),
//             Row(
//               children: [
//                 MaterialButton(
//                   height: screenHeight/25,
//                   minWidth: screenWidth/10,
//                   onPressed: (){
//                     if (!logic.gameOver()) {
//                       _showSaveDialog(context);
//                     } else {
//                       _showSaveDialog(context);
//                       // Navigator.popUntil(context, (route) => route.isFirst);
//                     }
//                   },
//                   color: const Color(0xB3F5E3CA),
//                   child: const Text('Exit',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),),
//                 SizedBox(width: screenWidth/8,),
//                 MaterialButton(
//                   height: screenHeight/25,
//                   minWidth: screenWidth/10,
//                   onPressed:logic.canUndo() ? () => logic.undo() : null,
//                   color: const Color(0xB3F5E3CA),
//                   child: const Icon(Icons.undo,size: 30,),),
//                 SizedBox(width: screenWidth/8,),
//                 MaterialButton(
//                   height: screenHeight/25,
//                   minWidth: screenWidth/10,
//                   onPressed: logic.canRedo() ? () => logic.redo() : null,
//                   color: const Color(0xB3F5E3CA),
//                   child: const Icon(Icons.redo,size: 30,),),
//               ],
//             ),
//             // _buildTimers(),
//             SizedBox(
//               height: screenHeight/7, // Set your desired height
//               width: double.infinity,
//               child: Align(
//                 alignment: Alignment.bottomCenter,
//                 child: logic.args.isMultiplayer
//                     ? _buildMultiplayerBar2(true, mainPlayerColor) //change the secondPlayerColor to MainPlayerColor
//                     : PlayerBar(false, secondPlayerColor),
//               ),
//             ),
//             // ignore: prefer_const_constructors
//             BoardPiece(),
//             SizedBox(
//               height: screenHeight/7, // Set your desired height
//               width: double.infinity,
//               child: Align(
//                 alignment: Alignment.topCenter,
//                 child: logic.args.isMultiplayer
//                     ? _buildMultiplayerBar(false, secondPlayerColor) // change the mainPlayerColor to SecondPlayerColor
//                     : PlayerBar(true, mainPlayerColor),
//               ),
//             ),
//             // _buildTimers2()
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   void _showSaveDialog(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     showDialog(
//         context: context,
//         builder: (BuildContext context) =>
//             AlertDialog(
//                 backgroundColor: const Color(0xB3F5E3CA),
//                 title:  Align(
//                   alignment: Alignment.topCenter,
//                   child: Text("Exit",
//                       style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/12,color: Colors.yellow)),
//                 ),
//                 // content: Text("Do you want to Exit this game?",
//                 //     style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: Colors.yellow)),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       logic.player1Timer.stop();
//                       logic.player2Timer.stop();
//                       //sendRematchRequest(opponentName);
//                       Navigator.pop(context);
//                       // logic.clear();
//                       // Navigator.popUntil(context, (route) => route.isFirst);
//                     },
//                     child: Text("No",
//                         style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       final args = logic.args;
//                       logic.clear();
//                       args.asBlack = !args.asBlack;
//                       logic.args = args;
//                       Navigator.pop(context);
//                       Navigator.pushNamed(context, '/game2');
//                       logic.start();
//                       //sendRematchRequest(opponentName);
//                     },
//                     child: Text("Rematch",
//                         style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       logic.clear();
//                       // Navigator.popUntil(context, (route) => route.isFirst);
//                       logic.player1Timer.stop();
//                       logic.player2Timer.stop();
//                       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const PlayOnline(bettingAmount: '', userData:{})));
//
//                     },
//                     child: Text("Yes",
//                         style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
//                   ),
//                 ]
//             )
//     );
//   }
//
//   void _showEndDialog(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     var title = "";
//     if (logic.inCheckmate()) {
//       title = "Checkmate!\n${logic.turn() == PieceColor.WHITE
//           ? "Black"
//           : "White"} Wins";
//     } else if (logic.inDraw()) {
//       title = "Draw!\n";
//       if (logic.insufficientMaterial()) {
//         title += "By Insufficient Material";
//       } else if (logic.inThreefoldRepetition()) {
//         title += "By Repetition";
//       } else if (logic.inStalemate()) {
//         title += "By Stalemate";
//       } else {
//         title += "By the 50-move rule";
//       }
//     } else {
//       title = "Time's up!\n${logic.turn() == PieceColor.WHITE
//           ? "Black"
//           : "White"} Wins";
//     }
//     showDialog(
//         context: context,
//         builder: (BuildContext context) =>
//             AlertDialog(
//                 backgroundColor: const Color(0xB3F5E3CA),
//                 title: Text(title,
//                     style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/12,color: Colors.yellow)),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       // final args = logic.args;
//                       // logic.clear();
//                       // args.asBlack = !args.asBlack;
//                       // logic.args = args;
//                       // Navigator.pop(context);
//                       // Navigator.pushNamed(context, '/game');
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => GameResultScreen(
//                             winnerName: 'Player 1', // Replace with actual winner name
//                             loserName: 'Player 2',  // Replace with actual loser name
//                             winnerImage: 'assets/c4.jpeg', // Replace with actual winner image path
//                             loserImage: 'assets/c5.jpeg',  // Replace with actual loser image path
//                             isWinner: true, // Set this to true or false based on the game result
//                             onRematch: () {
//                               Navigator.pop(context); // Navigate back to start a new game
//                               PlayOnline(bettingAmount: '', userData: {},);
//                             },
//                             onExit: () {
//                               Navigator.popUntil(context, (route) => route.isFirst); // Exit to home screen
//                             },
//                           ),
//                         ),
//                       );
//                       //logic.start();
//                       sendRematchRequest(opponentName);
//                     },
//                     child: Text("Rematch",
//                         style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
//
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       logic.clear();
//                       //  Navigator.popUntil(context, (route) => route.isFirst);
//                       logic.player1Timer.stop();
//                       logic.player2Timer.stop();
//                       Navigator.pushReplacement(context, MaterialPageRoute(
//                           builder: (context) => const PlayOnline(bettingAmount: '', userData: {},)));
//                       showEndDialog = false;
//                     },
//                     child: Text("Exit",
//                         style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
//                   )
//                 ]));
//     // showEndDialog =false;
//   }
//
//   void _showPromotionDialog(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     var pieces = [
//       PieceType.QUEEN,
//       PieceType.ROOK,
//       PieceType.BISHOP,
//       PieceType.KNIGHT
//     ].map((pieceType) => Piece(pieceType, logic.turn()));
//     final asBlack = logic.args.asBlack;
//     var futureValue = showDialog(
//         context: context,
//         builder: (BuildContext context) => Transform.rotate(
//             angle: (logic.turn() == PieceColor.BLACK) != asBlack
//                 ? math.pi
//                 : 0,
//             child: SimpleDialog(
//                 title: Text('Promote to',
//                     style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
//                 shadowColor: Colors.green,
//                 //backgroundColor: Colors.grey,
//                 surfaceTintColor: Colors.green,
//                 children: pieces
//                     .map((piece) => SimpleDialogOption(
//                     onPressed: () => Navigator.of(context).pop(piece),
//                     child: SizedBox(
//                         height: 60,
//                         child: PieceWidget(piece: piece)
//                     )))
//                     .toList())));
//     // futureValue.then((piece) => logic.promote(piece));
//     futureValue.then((piece) {
//       logic.promote(piece);
//       isPromotionDialogShown = false; // Reset the flag
//     });
//
//   }
// }
