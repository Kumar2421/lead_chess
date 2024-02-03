import 'package:cyber_punk_tool_kit_ui/cyber_punk_tool_kit_ui.dart';
import 'package:flutter/material.dart';
import 'package:chess_game/colors.dart';
import 'package:get_it/get_it.dart'; 
import '../buttons/back_button.dart';
import 'game_logic.dart';
final logic = GetIt.instance<GameLogic>();



class ChooseDifficultyScreen extends StatelessWidget {
  const ChooseDifficultyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const difficulties = [
      //"Kid"
       "Easy", "Normal", "Hard",
      //"Unreal"
    ];
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: color.navy1,

        // appBar: AppBar(
        //   title: const Text("Choose Difficulty"),
        // ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
         // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight/20,),
            ArrowBackButton2(color: Colors.white,),
            SizedBox(height: screenHeight/20,),
            for (final difficulty in difficulties)
              // CyberButton(
              //     width: screenWidth/5,
              //     height: screenHeight/20,
              //     // primaryColorBigContainer: Colors.greenAccent,
              //     // secondaryColorBigContainer: Colors.blueAccent,
              //     primaryColorBigContainer: color.navy,
              //     secondaryColorBigContainer: Colors.purple,
              //     primaryColorSmallContainer: Colors.black,
              //     secondaryColorSmallContainer: Colors.transparent,
            TextButton(
                   onPressed: () {
                    logic.args.difficultyOfAI = difficulty;
                    Navigator.pushNamed(context, '/color');
                  },
                  child: Text(difficulty, textScaleFactor: 2.0,style: TextStyle(color: Colors.white),)
                ),
          ]
        )
    );  
  }
}
