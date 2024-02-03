import 'package:chess_game/colors.dart';
import 'package:chess_game/engine/timer.dart';
import 'package:chess_game/server_side/websocket_manager.dart';

import '../games/play_local.dart';
import 'piece_widget.dart';
import 'package:flutter/material.dart';
import 'chess_board.dart';
import 'player_bar.dart'; 

import 'dart:math' as math;
import 'dart:async'; 

import 'package:get_it/get_it.dart'; 
import 'game_logic.dart'; 
final logic = GetIt.instance<GameLogic>(); 

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key, required WebSocketManager webSocketManager}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int selectedTimerOption = 5; // Default timer option: 5 minutes
  bool isTimerRunning = false;
  late Timer _gameTimer;
  void update() => setState(() => {});
  @override
  void initState() {
    logic.addListener(update);
    super.initState();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), _onTimerTick);
  }
  @override
  void dispose() {
    logic.removeListener(update);
    _gameTimer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _onTimerTick(Timer timer) {
    if (logic.isTimerRunning) {
      logic.updateTimers();
      if (logic.isTimeUp()) {
        _endGame(logic.turn() == PieceColor.WHITE
            ? PieceColor.BLACK
            : PieceColor.WHITE);
      }
    }
  }

  void _endGame(PieceColor winner) {
    logic.stopTimer();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("Player ${winner == PieceColor.WHITE ? '2' : '1'} wins!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
  Widget _buildTimerSelector() {
    return Column(
      children: [
        const Text(
          'Select Initial Time:',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 10),
        DropdownButton<int>(
          value: selectedTimerOption,
          items: [5, 10, 15, 20, 30].map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value minutes'),
            );
          }).toList(),
          onChanged: (int? value) {
            if (value != null) {
              setState(() {
                selectedTimerOption = value;
              });
              logic.setGameTimer(value * 60); // Convert minutes to seconds
            }
          },
        ),
      ],
    );
  }

  Widget _buildMultiplayerBar(bool isMe, PieceColor color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
            flex: 7,
            child: PlayerBar(isMe, color)
        ),
       // const Spacer(flex: 2),
       //  Flexible(
       //      flex: 7,
       //      child: RotatedBox(
       //          quarterTurns: 2,
       //          child: PlayerBar(!isMe, color)
       //      )
       //  ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainPlayerColor = logic.args.asBlack ? PieceColor.BLACK : PieceColor.WHITE; 
    final secondPlayerColor = logic.args.asBlack ? PieceColor.WHITE : PieceColor.BLACK; 

    bool isMainTurn = mainPlayerColor == logic.turn(); 
    if (logic.isPromotion && (logic.args.isMultiplayer || isMainTurn)) {
      Timer(const Duration(milliseconds: 100), () => _showPromotionDialog(context)); 
    } else if (logic.gameOver()) {
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
            SizedBox(height: 50,),
            Row(
              children: [
                MaterialButton(
                  height: 30,
                  minWidth: 60,
                  onPressed: (){
                  if (!logic.gameOver()) {
                    _showSaveDialog(context);
                  } else {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                 },
                  color: Colors.white,
                  child: Text('Exit',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),),
                SizedBox(width: 80,),
                MaterialButton(
                  height: 30,
                  minWidth: 60,
                  onPressed:logic.canUndo() ? () => logic.undo() : null,
                  color: Colors.white,
                 child: Icon(Icons.undo,size: 30,),),
                SizedBox(width: 30,),
                MaterialButton(
                  height: 30,
                  minWidth: 60,
                  onPressed: logic.canRedo() ? () => logic.redo() : null,
                  color: Colors.white,
                  child: Icon(Icons.redo,size: 30,),),
              ],
            ),
            _buildTimerSelector(),
            Text(
              'Player 1 Time: ${logic.getPlayer1Time()}',
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
            Text(
              'Player 2 Time: ${logic.getPlayer2Time()}',
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
            ElevatedButton(
              onPressed: () {
                logic.switchTurns();
              },
              child: Text('Switch Turns'),
            ),
           // MyHomePage(),
            Container(
              height: 180, // Set your desired height
              width: double.infinity,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: logic.args.isMultiplayer
                    ? _buildMultiplayerBar(true, mainPlayerColor) //change the secondPlayerColor to MainPlayerColor
                    : PlayerBar(false, secondPlayerColor),
              ),
            ),
            // ignore: prefer_const_constructors
            ChessBoard(),
            Container(
              height: 180, // Set your desired height
              width: double.infinity,
              child: Align(
                alignment: Alignment.topCenter,
                child: logic.args.isMultiplayer
                    ? _buildMultiplayerBar(false, secondPlayerColor) // change the mainPlayerColor to SecondPlayerColor
                    : PlayerBar(true, mainPlayerColor),
              ),
            ),
          ],
        ),
      ),
    ); 
  }

  void _showSaveDialog(BuildContext context) {
    showDialog(
      context: context, 
      builder: (BuildContext context) => 
        AlertDialog(
          title: const Text("Exit"),
          content: const Text("Do you want to Exit this game?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // logic.clear();
                // Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                //logic.clear();
               // Navigator.popUntil(context, (route) => route.isFirst);
               // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PlayLocal()));
                final game = logic.save();
                logic.clear();
                Navigator.popUntil(context, (route) => route.isFirst);
                final snackBar = SnackBar(
                  backgroundColor: Theme.of(context).bottomAppBarColor ,
                  content: Text(
                    "The game has been saved as ${game.name}",
                    style: TextStyle(color: Theme.of(context).primaryColorLight))
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: const Text("Yes"),
            ),
          ]
        )
    ); 
  }

  void _showEndDialog(BuildContext context) {
    var title = "";
    if (logic.inCheckmate()) {
      title = "Checkmate!\n" +
          (logic.turn() == PieceColor.WHITE ? "Black" : "White") +
          " Wins";
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
    }

    showDialog(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(title: Text(title), actions: [
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
                child: const Text("Rematch"),
              ),
              TextButton(
                onPressed: () {
                  logic.clear();
                  Navigator.popUntil(context, (route) => route.isFirst); 
                },
                child: const Text("Exit"),
              )
            ]));
  }

  void _showPromotionDialog(BuildContext context) {
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
                title: const Text('Promote to'),
                children: pieces 
                          .map((piece) => SimpleDialogOption(
                            onPressed: () => Navigator.of(context).pop(piece), 
                            child: SizedBox(
                              height: 60,
                              child: PieceWidget(piece: piece)
                            )))
                          .toList()))); 
    futureValue.then((piece) => logic.promote(piece));
  }
}
