import 'package:chess_game/colors.dart';
import 'package:chess_game/engine/timer.dart';
import 'package:flutter/material.dart';
import '../expandable-slider.dart';
import 'piece_widget.dart';

import 'package:get_it/get_it.dart'; 
import 'game_logic.dart'; 
final logic = GetIt.instance<GameLogic>(); 

class ChooseColorScreen extends StatelessWidget {
  const ChooseColorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.navy1,
      // appBar: AppBar(
      //   title: const Text("You Play As"),
      // ),
      body:
      // Column(
      //       children: [
      //         SizedBox(height: 200,),
      //         ExpandSlider(max: 120, min: 0,),
      //         ExpandSlider(max: 60, min: 0,name: 'Bonce ',time: ' sec',value: ' 60',),
      //         SizedBox(height: 50,),
              Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: InkWell(
                        borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                        child: SizedBox(
                          width: 120, height: 120,
                          child: PieceWidget(piece: Piece(PieceType.KING, PieceColor.BLACK))
                        ),
                        onTap: () {
                          logic.args.asBlack = true;
                          Navigator.pushNamed(context, '/game');
                          logic.start();
                        }
                      ),
                    ),
                    Flexible(
                      child: InkWell(
                        borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                        child: SizedBox(
                          width: 120, height: 120,
                          child: PieceWidget(piece: Piece(PieceType.KING, PieceColor.WHITE))
                        ),
                        onTap: () {
                          logic.args.asBlack = false;
                          Navigator.pushNamed(context, '/game');
                          logic.start();
                        }
                      ),
                    ),
                  ]
                ),
              ),

          //   ],
          // )
    );
  }

}
