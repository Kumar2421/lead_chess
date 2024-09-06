import 'package:chess_game/colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'piece_widget.dart';
import 'game_logic.dart';
import 'dart:convert'; // for jsonDecode
import 'package:shared_preferences/shared_preferences.dart';

final logic = GetIt.instance<GameLogic>();

class PlayerBar extends StatefulWidget {
  final bool isMe;
  final PieceColor color;

  const PlayerBar(
      this.isMe,
      this.color, {
        super.key,
      });

  @override
  _PlayerBarState createState() => _PlayerBarState();
}

class _PlayerBarState extends State<PlayerBar> {
  String? opponent;
  String? name;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  @override
  void dispose() {
    super.dispose();
  }
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? opponentName = prefs.getString('opponent');
    String? aiopponent = prefs.getString('starting_ai');
    String? userDataString = prefs.getString('userData');
    if (userDataString != null) {
      Map<String, dynamic> userDataMap = jsonDecode(userDataString);
      if (opponentName!= null){
        setState(() {
          opponent = opponentName;
          name = userDataMap['name'];
        });
      }else{
        setState(() {
          opponent = aiopponent;
          name = userDataMap['name'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Determine if the device is a tablet
    bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    // Set the height and width based on the device type
    double containerHeight = isTablet ? screenHeight / 13 : screenHeight / 17;
    double containerWidth = screenWidth;

    final isMyTurn = widget.color == logic.turn();
    final pieceScore = logic.getRelScore(widget.color);
    final eaten = widget.color == PieceColor.WHITE ? logic.eatenBlack : logic.eatenWhite;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      height: containerHeight,
      width: containerWidth,
      decoration: BoxDecoration(
        color: Colors.black26,
      ),
      child: Row(
        children: [
          Text(
            (widget.isMe ? name ?? "You" : opponent ??"Computer" ) + (pieceScore > 0 ? " +$pieceScore" : ""),
            style: TextStyle(
              fontWeight: isMyTurn ? FontWeight.bold : FontWeight.normal,
              fontSize: 20,
              color: Colors.white, // Set font color to white
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.pie_chart, color: Colors.white), // Use a suitable icon and set its color to white
            onPressed: () => _showEatenPieces(context, eaten, widget.color == PieceColor.WHITE ? Alignment.topRight : Alignment.topLeft),
          ),
        ],
      ),
    );
  }

  void _showEatenPieces(BuildContext context, List<PieceType> eaten, Alignment alignment) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          color: Colors.blueGrey, // Set the background color here
          child: Wrap(
            children: eaten
                .map((pieceType) => SizedBox(
              width: 31,
              height: 31,
              child: PieceWidget(piece: Piece(pieceType, widget.color)),
            ))
                .toList(),
          ),
        );
      },
    );
  }
}

class PlayerBar2 extends StatefulWidget {
  final bool isMe;
  final PieceColor color;

  const PlayerBar2(
      this.isMe,
      this.color, {
        super.key,
      });

  @override
  _PlayerBar2State createState() => _PlayerBar2State();
}

class _PlayerBar2State extends State<PlayerBar2> {
  String? opponent;
  String? name;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? opponentName = prefs.getString('opponent');
    String? aiopponent = prefs.getString('starting_ai');
    String? userDataString = prefs.getString('userData');
    if (userDataString != null) {
      Map<String, dynamic> userDataMap = jsonDecode(userDataString);
      if (opponentName != null) {
        setState(() {
          opponent = opponentName;
          name = userDataMap['name'];
        });
      } else {
        setState(() {
          opponent = aiopponent;
          name = userDataMap['name'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMyTurn = widget.color == logic.turn();
    final pieceScore = logic.getRelScore(widget.color);
    final eaten = widget.color == PieceColor.WHITE ? logic.eatenBlack : logic
        .eatenWhite;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: const BoxDecoration(
        color: color.black1,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                (widget.isMe ? opponent ?? "Computer" : name ?? "You") +
                    (pieceScore > 0 ? " +$pieceScore" : ""),
                style: TextStyle(
                  fontWeight: isMyTurn ? FontWeight.bold : FontWeight.normal,
                  fontSize: 20,
                  color: Colors.white,

                ),
              ),
              Spacer(),
              IconButton(
                icon: const Icon(Icons.pie_chart, color: Colors.white),
                // Use a suitable icon
                onPressed: () =>
                    _showEatenPieces(context, eaten,
                        widget.color == PieceColor.WHITE
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEatenPieces(BuildContext context, List<PieceType> eaten,
      Alignment alignment) {
    showModalBottomSheet(

      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.blueGrey, // Set the background color here
          child: Wrap(
            children: eaten
                .map((pieceType) =>
                SizedBox(
                  width: 31,
                  height: 31,
                  child: PieceWidget(piece: Piece(pieceType, widget.color)),
                ))
                .toList(),
          ),
        );
      },
    );
  }
}