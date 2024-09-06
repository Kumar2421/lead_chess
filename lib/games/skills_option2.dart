import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:button_animations/button_animations.dart';
import 'package:flutter/material.dart';
import 'package:chess_game/colors.dart';
import 'package:get_it/get_it.dart';
import '../buttons/back_button.dart';
import 'game_logic.dart';
final logic = GetIt.instance<GameLogic>();

class SkillsOption2 extends StatelessWidget{
  const SkillsOption2({super.key});
  final double _scaleFactor = 1.0;
  @override
  Widget build(BuildContext context){
    const difficulties = [
      "Easy", "Normal", "Hard",
    ];
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Center(
          child: Container(
            height: screenHeight/1,
            width: screenWidth/1,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.navy,Colors.black],
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  // stops: [0.0,1.0],
                  // tileMode: TileMode.repeated,
                )
            ),
            child: Column(
                children: [
                  SizedBox(height: screenHeight/20,),
                  //ArrowBackButton(color: Colors.white,),
                  SizedBox(height: screenHeight/15,),
                  for (final difficulty in difficulties)
                    Column(
                      children: [
                        AnimatedButton(
                          type: null,
                          blurRadius: 10,
                          height: screenHeight/20,
                          width: screenWidth/2.5,
                          shadowColor:  color.blue3,
                          color: color.navy,
                          //borderColor: color.navy,
                          // blurColor: color.beige2,
                          onTap: () {
                           // AudioHelper.buttonClickSound();
                            logic.args.difficultyOfAI = difficulty;
                            Navigator.pushNamed(context, '/colorOption2');
                          },
                          child: Text(difficulty, textScaleFactor: 1.5,style: const TextStyle(color: Colors.white),),
                        ),
                        SizedBox(height:screenHeight/ 20),
                      ],
                    ),
                ]
            ),
          ),
        )
    );
  }
}
