import 'package:chess_game/buttons/back_button.dart';
import 'package:cyber_punk_tool_kit_ui/cyber_punk_tool_kit_ui.dart';
import 'package:flutter/material.dart';
import 'package:chess_game/colors.dart';

class CyberOne extends StatefulWidget {
  //final String? imageUrl;
  //final String? name;
  const CyberOne({super.key,});

  @override
  State<CyberOne> createState() => _CyberOneState();
}

class _CyberOneState extends State<CyberOne> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: color.navy1,
      //Colors.white.withOpacity(0.15),
      body: Column(
       // mainAxisAlignment: MainAxisAlignment.center,
         //  crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             SizedBox(height: screenHeight/10,),
             ArrowBackButton(color: Colors.white),
             Padding(
               padding:  EdgeInsets.only(left: screenWidth/25),
               child: CyberContainerOne(
                width:screenWidth/ 1.1,
                height: screenHeight/3,
                colorBackgroundLineFrame: Colors.black,
                primaryColorBackground: Colors.blueAccent,
                primaryColorLineFrame: Colors.orangeAccent,
            //  animationDurationSecs: Duration.millisecondsPerDay,
                secondaryColorLineFrame: Colors.white,
                secondaryColorBackground: Colors.purple,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  //   image: DecorationImage(
                  //     fit: BoxFit.fill,
                  //     image: AssetImage('assets/sky.jpg'),
                  //   ),
                   ),
                  child: Column(
                    children: [
                      Text('Create')
                    ],
                  ),
                ),
        ),
             ),
           ],
         ),
    );
  }
}