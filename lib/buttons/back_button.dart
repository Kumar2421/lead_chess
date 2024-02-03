import 'package:chess_game/games/play_local.dart';
import 'package:chess_game/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:chess_game/colors.dart';
class ArrowBackButton extends StatelessWidget {
  final Color color;
  const ArrowBackButton({Key? key, required this.color,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child:    Align(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onTap:(){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
            },
            child: Image(
              image: AssetImage('assets/arrow-back.png'),height: screenHeight/20,width: screenWidth/10,color: color),
          )),
    );
  }
}
class ArrowBackButton2 extends StatelessWidget {
  final Color color;
  const ArrowBackButton2({Key? key, required this.color,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child:    Align(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onTap:(){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>PlayLocal()));
            },
            child: Image(
                image: AssetImage('assets/arrow-back.png'),height: screenHeight/20,width: screenWidth/10,color: color),
          )),
    );
  }
}