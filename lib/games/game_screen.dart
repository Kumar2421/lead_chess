import 'package:chess_game/colors.dart';
import 'package:chess_game/screen/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Widget _buildTimers() {
  //   if (!isDialogShown &&
  //       (logic.player1Timer.currentTime.inSeconds <= 0 || logic.player2Timer.currentTime.inSeconds <= 0)) {
  //     isDialogShown = true;
  //     _endGame(logic.turn());
  //   }
  //   return Column(
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           RotatedBox(
  //             quarterTurns: 2,
  //             child: Text(
  //               'White: ${logic.player1Timer.currentTime.inMinutes}:${(logic.player1Timer.currentTime.inSeconds % 60).toString().padLeft(2, '0')}',
  //               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xB3F5E3CA)),
  //             ),
  //           ),
  //           RotatedBox(
  //             quarterTurns: 2,
  //             child: Text(
  //               'Black: ${logic.player2Timer.currentTime.inMinutes}:${(logic.player2Timer.currentTime.inSeconds % 60).toString().padLeft(2, '0')}',
  //               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xB3F5E3CA)),
  //             ),
  //           ),
  //          ],
  //        ),
  //     ],
  //   );
  // }
  // Widget _buildTimers2() {
  //   if (!isDialogShown &&
  //       (logic.player1Timer.currentTime.inSeconds <= 0 || logic.player2Timer.currentTime.inSeconds <= 0)) {
  //     isDialogShown = true;
  //     _endGame(logic.turn());
  //   }
  //   return Column(
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(
  //             'Player 1: ${logic.player1Timer.currentTime.inMinutes}:'
  //                 '${(logic.player1Timer.currentTime.inSeconds % 60).toString().padLeft(2, '0')}',
  //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color(0xB3F5E3CA)),
  //           ),
  //           Text(
  //             'Player 2: ${logic.player2Timer.currentTime.inMinutes}:'
  //                 '${(logic.player2Timer.currentTime.inSeconds % 60).toString().padLeft(2, '0')}',
  //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xB3F5E3CA)),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }
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

  void _endGame([PieceColor? winner]) {
    double screenWidth = MediaQuery.of(context).size.width;
    // Future.microtask(() {
      Future.delayed(Duration.zero, () {
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                AlertDialog(
                  backgroundColor: const Color(0xB3F5E3CA),
                  title: Text("Game Over",
                      style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/12,color: Colors.yellow)),
                  content: Text(
                      "Player ${winner == PieceColor.WHITE ? 2 : 1} wins!",
                      style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: Colors.yellow)),
                  actions: [
                    TextButton(
                      onPressed: () {
                        final args = logic.args;
                        logic.clear();
                        args.asBlack = !args.asBlack;
                        logic.args = args;
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/game');
                        logic.start();
                      },
                      child: Text("Rematch",
                          style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/20,color: color.navy1)),
                    ),
                    TextButton(
                      onPressed: () {
                        logic.clear();
                        //Navigator.pop(context);
                        //Navigator.of(context).popUntil((route) => route.isFirst);
                        //  Navigator.popUntil(context, (route) => route.isFirst);
                        logic.player1Timer.stop();
                        logic.player2Timer.stop();
                        Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) => const HomeScreen()));
                      },
                      child: Text("OK",
                          style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/20,color: color.navy1)),
                    ),
                  ],
                ));
      });
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const HomeScreen()));

              },
              child: Text("Yes",
                  style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
            ),
          ]
        )
    );
  }

  void _showEndDialog(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
      var title = "";
      if (logic.inCheckmate()) {
        title = "Checkmate!\n${logic.turn() == PieceColor.WHITE
            ? "Black"
            : "White"} Wins";
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
      } else {
        title = "Time's up!\n${logic.turn() == PieceColor.WHITE
            ? "Black"
            : "White"} Wins";
      }
      showDialog(
          context: context,
          builder: (BuildContext context) =>
              AlertDialog(
                backgroundColor: const Color(0xB3F5E3CA),
                  title: Text(title,
                      style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/12,color: Colors.yellow)),
                  actions: [
                    TextButton(
                      onPressed: () {
                        final args = logic.args;
                        logic.clear();
                        args.asBlack = !args.asBlack;
                        logic.args = args;
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/game');
                        logic.start();
                        },
                      child: Text("Rematch",
                          style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                    ),
                TextButton(
                  onPressed: () {
                    logic.clear();
                    //  Navigator.popUntil(context, (route) => route.isFirst);
                    logic.player1Timer.stop();
                    logic.player2Timer.stop();
                    Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => const HomeScreen()));
                    showEndDialog = false;
                  },
                  child: Text("Exit",
                      style: GoogleFonts.oswald(fontWeight: FontWeight.w500,fontSize: screenWidth/15,color: color.navy1)),
                )
              ]));
      // showEndDialog =false;
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
