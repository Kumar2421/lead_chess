
import 'dart:math';

import 'package:button_animations/button_animations.dart';
import 'package:chess_game/buttons/animation_button.dart';
import 'package:chess_game/cyber/cyber_buttons.dart';
import 'package:chess_game/games/play_tournament.dart';
import 'package:chess_game/games/play_friends.dart';
import 'package:chess_game/games/play_local.dart';
import 'package:chess_game/games/play_online.dart';
import 'package:chess_game/screen/home_screen.dart';
import 'package:cyber_punk_tool_kit_ui/cyber_punk_tool_kit_ui.dart';
import 'package:flutter/material.dart';
import 'package:chess_game/colors.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
class CyberButtons extends StatefulWidget {
 // final String? imageUrl;
//  final String? name;
 // final String routeName;
  const CyberButtons({super.key,
  //  this.imageUrl, this.name, required this.routeName,
  });

  @override
  State<CyberButtons> createState() => _CyberButtonsState();
}

class _CyberButtonsState extends State<CyberButtons> {
  double _scaleFactor = 1.0;

  _onPressed(BuildContext context) {
    print("CLICK");
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return  Padding(
      padding:  EdgeInsets.only(left: 10,right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BouncingWidget(
                  scaleFactor: _scaleFactor,
                  onPressed: () =>
                  // {
                  //   final currentRoute = ModalRoute.of(context)?.settings.name;
                  //   // Check if the current route is not the same as the destination page route
                  //   if (currentRoute != widget.routeName) {
                  //     Navigator.of(context).pushReplacementNamed(widget.routeName);
                  //   }
                  // },
                 Navigator.push(context, MaterialPageRoute(builder: (context)=>PlayLocal())),
                      //_onPressed(context),
                  child: CyberButton(
                    width: screenWidth/2.5,
                    height: screenHeight/20,
                    // primaryColorBigContainer: Colors.greenAccent,
                    // secondaryColorBigContainer: Colors.blueAccent,
                    primaryColorBigContainer: color.navy,
                    secondaryColorBigContainer: Colors.purple,
                    primaryColorSmallContainer: Colors.black,
                    secondaryColorSmallContainer: Colors.transparent,
                    child: Row(
                      children: [
                        SizedBox(width: screenWidth/30),
                        Image(
                          image: AssetImage('assets/chesscoin.png'),fit: BoxFit.cover,
                          height: screenHeight/35,width: screenWidth/14,color: Colors.orangeAccent,),
                        SizedBox(width: screenWidth/100),
                        Text(
                       'Play Local',
                          style: TextStyle(color: Colors.white,fontSize: screenWidth/30,fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
             // Gap(screenWidth/6),
              Stack(
                children: [
                  BouncingWidget(
                      scaleFactor: _scaleFactor,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlayOnline())),
                    //_onPressed(context),
                     child: CyberButton(
                       width: screenWidth/2.5,
                       height: screenHeight/20,
                      // primaryColorBigContainer: Colors.black,
                      // secondaryColorBigContainer: Colors.greenAccent,
                       primaryColorBigContainer: color.navy,
                       secondaryColorBigContainer: Colors.purple,
                       primaryColorSmallContainer: Colors.black,
                       secondaryColorSmallContainer: Colors.transparent,
                       child: Row(
                         children: [
                          SizedBox(width: screenWidth/30),
                           Image(
                            image: AssetImage('assets/chesscoin1.png'),
                            height: screenHeight/20,width: screenWidth/12,color: Colors.orangeAccent,),
                          Padding(
                            padding:  EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Play Online',
                              style: TextStyle(color: Colors.white,fontSize: screenWidth/30,fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )),

                ],
              ),
            ],
          ),
          SizedBox(height: screenHeight/30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BouncingWidget(
                scaleFactor: _scaleFactor,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>PlayFriend())),
                //_onPressed(context),
                child:  CyberButton(
                  width: screenWidth/2.5,
                  height: screenHeight/20,
                  primaryColorBigContainer:color.navy,
                  secondaryColorBigContainer: Colors.purple,
                  primaryColorSmallContainer: Colors.black,
                  secondaryColorSmallContainer: Colors.transparent,
                  child: Row(
                    children: [
                      SizedBox(width: screenWidth/20),
                      Image(
                        image: AssetImage('assets/playfriend.png'),
                        color: Colors.orangeAccent,height: screenHeight/30,width: screenWidth/18,),
                      Text(
                        'Play with Friends',
                        style: TextStyle(fontSize: screenWidth/33,fontWeight: FontWeight.bold,color: Colors.white),
                      ),
                    ],
                  ),
                ),),
              Stack(
                  children: [
                    BouncingWidget(
                        scaleFactor: _scaleFactor,
                        onPressed: () =>
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>TournamentPage())),
                      //_onPressed(context),

                      child: CyberButton(
                        width: screenWidth/2.5,
                         height: screenHeight/20,
                      // primaryColorBigContainer: Colors.redAccent,
                      // secondaryColorBigContainer: Colors.yellowAccent,
                       primaryColorBigContainer:color.navy,
                       secondaryColorBigContainer: Colors.purple,
                       primaryColorSmallContainer: Colors.black,
                       secondaryColorSmallContainer: Colors.transparent,
                       child: Row(
                        children: [
                         SizedBox(width: screenWidth/20),
                          Image(image: AssetImage('assets/tournament.png'),
                            height: screenHeight/35,width: screenWidth/18,color: Colors.orangeAccent,),
                          SizedBox(width: screenWidth/50),
                          Text(
                            'Tournament',
                            style: TextStyle(color: Colors.white, fontSize: screenWidth/30,fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )),
                    Positioned(
                      top: 10,
                      left: 20,
                      child: Transform.rotate(
                        angle: 2*pi/12,
                        child: Text(
                          "coming soon",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontSize: 15),
                        ),
                      ),
                    ),
               ] ),
            ],
          )
        ],
      ),
    );
  }
}