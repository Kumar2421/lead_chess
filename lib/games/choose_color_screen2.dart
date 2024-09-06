import 'dart:async';
import 'dart:math';
import 'package:chess_game/games/piece_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_logic.dart';
import '/colors.dart';

final logic = GetIt.instance<GameLogic>();

class ChooseColorScreen2 extends StatefulWidget {
  const ChooseColorScreen2({super.key});

  @override
  _ChooseColorScreenState createState() => _ChooseColorScreenState();
}

class _ChooseColorScreenState extends State<ChooseColorScreen2> {
  @override
  void initState() {
    super.initState();
    _getColorAndNavigate();
  }

  Future<void> _getColorAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final color = prefs.getString('selected_color');

    if (color != null) {
      logic.args.asBlack = (color == 'Black');
      logic.start();
    } else {
      // If no color is found, you can handle it accordingly (e.g., assign a random color or show an error)
      final random = Random();
      logic.args.asBlack = random.nextBool();
      logic.start();
      print("no color get");
    }

    // Show loading animation for 3 seconds before navigating
    Timer(const Duration(seconds: 3), () {
      logic.args.isMultiplayer = true;
      Navigator.pushReplacementNamed(context, '/game');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.navy1,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: PieceWidget(piece: Piece(PieceType.KING, PieceColor.BLACK)),
                  ),
                ),
                Flexible(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: PieceWidget(piece: Piece(PieceType.KING, PieceColor.WHITE)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
