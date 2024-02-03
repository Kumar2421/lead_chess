
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:button_animations/button_animations.dart';
import 'package:chess_game/buttons/back_button.dart';
import 'package:cyber_punk_tool_kit_ui/cyber_punk_tool_kit_ui.dart';
import 'package:emoji_alert/arrays.dart';
import 'package:emoji_alert/emoji_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colors_border/flutter_colors_border.dart';
import 'package:gap/gap.dart';
import 'package:chess_game/colors.dart';
import 'package:get_it/get_it.dart';
import 'package:glowy_borders/glowy_borders.dart';
import 'package:google_fonts/google_fonts.dart';
import '../engine/choose_difficulty_screen.dart';
import '../engine/game_logic.dart';
import '../engine/home_screen_button.dart';


final logic = GetIt.instance<GameLogic>();
class PlayLocal extends StatefulWidget {
  const PlayLocal({super.key});

  @override
  State<PlayLocal> createState() => _PlayLocalState();
}

class _PlayLocalState extends State<PlayLocal> {
  final _textController1 = TextEditingController();
  final _textController2 = TextEditingController();
  double _scaleFactor = 1.0;

  //double currentProgress = 5.0;
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    const minWidth = 250.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.navy1,
       automaticallyImplyLeading: false,
        leading: ArrowBackButton(color: Colors.white,),
       title: Padding(
         padding:  EdgeInsets.only(right: screenWidth/10),
         child: Column(
           children: [
             Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text('PLAY ',style: GoogleFonts.oswald(
                       color: Colors.white,fontSize: screenWidth/20,fontWeight: FontWeight.bold),),
                   Text('LOCAL',style: GoogleFonts.oswald(
                       fontSize: screenWidth/20,fontWeight: FontWeight.bold,color: Colors.amberAccent),),
                 ],
               ),
             Padding(
               padding:EdgeInsets.symmetric(horizontal:10.0),
               child:Container(
                 height:screenHeight/400,
                 width:screenWidth/5,
                 decoration: const BoxDecoration(
                   gradient: LinearGradient(
                     colors: [Colors.white,Colors.amber, Colors.white],
                     begin: Alignment.bottomLeft,
                     end: Alignment.topRight,
                   ),
                 ),
               ),),
           ],
         ),
       ),
      ),
      //backgroundColor: color.navy,
      extendBody: true,
      body: Container(
        height: screenHeight/1,
        width: screenWidth/1,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/checked-background.png"),
                fit: BoxFit.cover
            )
        ),
        child: Container(
          height: screenHeight/1,
          width: screenWidth/1,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/play-local2.png"),
                  fit: BoxFit.cover
              )
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
              //  Gap(screenHeight/15),
               // ArrowBackButton(color: color.navy1,),
                SizedBox(height: screenHeight/5.18,),
                AnimatedGradientBorder(
                  borderSize: 4,
                  glowSize: 5,
                  gradientColors: [
                    Colors.black,
                    color.navy1,
                    color.navy,
                    Colors.grey,
                  ],
                  //animationProgress: currentProgress,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: SizedBox(
                    width: screenWidth/1.8,
                    height: screenHeight/3.3,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                       color: color.navy1
                       //  color: Color.fromARGB(255, 100, 100, 100)
                         // color: Theme.of(context).colorScheme.secondaryContainer
                      ),
                        child: Column(
                          children: [
                            Gap(screenHeight/50),
                            Image(
                              image: AssetImage('assets/LC-logo1.png'),
                              height: screenHeight/28,width: screenWidth/7,fit: BoxFit.cover,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('LEAD',style: GoogleFonts.oswald(color: Colors.white,fontSize: screenWidth/25,fontWeight: FontWeight.bold),
                                ),
                                Gap(screenWidth/50),
                                Text('CHESS',style: GoogleFonts.oswald(fontSize: screenWidth/25,fontWeight: FontWeight.bold,color: Colors.amberAccent),),

                              ],
                            ),
                            // Padding(
                            //   padding:EdgeInsets.symmetric(horizontal:10.0),
                            //   child:Container(
                            //     height:screenHeight/500,
                            //     width:screenWidth/6,
                            //     decoration: const BoxDecoration(
                            //       gradient: LinearGradient(
                            //         colors: [Colors.white,Colors.amber, Colors.white],
                            //         begin: Alignment.bottomLeft,
                            //         end: Alignment.topRight,
                            //       ),
                            //     ),
                            //   ),),
                            Gap(screenHeight/30),
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
                                _textController1;_textController2;
                                logic.args.isMultiplayer = true;
                                Navigator.pushNamed(context, '/color');
                                //  EmojiAlert(
                                //   //alertTitle:  Text("Player1 vs Player2", style:  TextStyle(fontWeight:  FontWeight.bold)),
                                //    enableMainButton: true,
                                //    onMainButtonPressed: (){
                                //      _textController1;_textController2;
                                //      logic.args.isMultiplayer = true;
                                //      Navigator.pushNamed(context, '/color');
                                //    },
                                //    mainButtonText: Text('Play',style: TextStyle(fontWeight: FontWeight.bold,color: color.navy1),),
                                //    mainButtonColor: color.beige,
                                //    cancelable:  true,
                                //    emojiType: EMOJI_TYPE.JOYFUL,
                                //    emojiSize: 0,
                                //    cornerRadiusType: CORNER_RADIUS_TYPES.ALL_CORNERS,
                                //    background: color.navy1,
                                //    //Colors.white.withOpacity(0.15),
                                //    height: screenHeight/2.5,
                                //    animationType: ANIMATION_TYPE.TRANSITION,
                                //    //alignment: Alignment.center,
                                //   description:  Column(
                                //       children: [
                                //         Image(image: AssetImage('assets/crown1.png'),height: screenHeight/17,width: screenWidth/5,),
                                //         Row(
                                //           crossAxisAlignment: CrossAxisAlignment.center,
                                //           mainAxisAlignment: MainAxisAlignment.center,
                                //           children: [
                                //             Text('Player1 ',
                                //                 style: GoogleFonts.oswald(fontWeight: FontWeight.w500,color: Colors.white)),
                                //             Text('vs ',
                                //                 style: GoogleFonts.oswald(fontWeight: FontWeight.w500,color: Colors.orangeAccent)),
                                //             Text('Player2',
                                //                 style: GoogleFonts.oswald(fontWeight: FontWeight.w500,color: Colors.white)),
                                //           ],
                                //         ),
                                //         Gap(screenHeight/50),
                                //         Container(
                                //           height: screenHeight/20,
                                //           width: screenWidth/2,
                                //           child: TextFormField(
                                //             controller: _textController1,
                                //             decoration:  InputDecoration(
                                //               //  hintText: "Player1",
                                //                 labelText: 'Name1',
                                //               fillColor: Colors.white,
                                //               labelStyle: TextStyle(
                                //                 color: color.beige
                                //               ),
                                //               // hintStyle: TextStyle(
                                //               //   color: Colors.white
                                //               // ),
                                //               // border: OutlineInputBorder(
                                //               //     borderSide: BorderSide(color: Colors.red,),
                                //               //     borderRadius: BorderRadius.all(
                                //               //         Radius.circular(9.0)),
                                //               // ),
                                //               enabledBorder: OutlineInputBorder(
                                //                 borderSide: BorderSide(color: color.beige), // Change the color here
                                //                 borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                //               ),
                                //               focusedBorder: OutlineInputBorder(
                                //                 borderSide: BorderSide(color: color.beige), // Change the color here
                                //                 borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                //               ),
                                //             ),
                                //             style: TextStyle(color: Colors.white),
                                //             cursorColor: Colors.white,
                                //           ),
                                //         ),
                                //         Gap(screenHeight/50),
                                //         Container(
                                //           height: screenHeight/20,
                                //           width: screenWidth/2,
                                //           child: TextFormField(
                                //             controller: _textController2,
                                //             decoration: InputDecoration(
                                //               //border: OutlineInputBorder(),
                                //               //  hintText: 'Player2',
                                //                 labelText: 'Name2',
                                //               labelStyle: TextStyle(
                                //                   color: color.beige
                                //               ),
                                //               // hintStyle: TextStyle(
                                //               //     color: Colors.white
                                //               // ),
                                //               enabledBorder: OutlineInputBorder(
                                //                 borderSide: BorderSide(color: color.beige), // Change the color here
                                //                 borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                //               ),
                                //               focusedBorder: OutlineInputBorder(
                                //                 borderSide: BorderSide(color: color.beige), // Change the color here
                                //                 borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                //               ),
                                // ),
                                //             style: TextStyle(color: Colors.white),
                                //             cursorColor: Colors.white,
                                //           ),
                                //         )
                                //       ]
                                //   ),
                                // ).displayAlert(context);
                              },
                              child:  Row(
                                children: [
                                  Gap(screenWidth/100),
                                  Image(
                                    image: AssetImage('assets/playfriend.png'),
                                    height: screenHeight/35,width: screenWidth/18,color: Colors.orangeAccent,),
                                  Gap(screenWidth/100),
                                  Text(
                                    'Player1 vs Player2',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: screenWidth/30),
                                  ),
                                ],
                              ),
                            ),
                            Gap(screenHeight/30),
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
                                logic.args.isMultiplayer = false;
                                Navigator.pushNamed(context, '/difficulty');
                                // EmojiAlert(
                                //   //alertTitle:  Text("Play with Computer", style:  TextStyle(fontWeight:  FontWeight.bold,color: Colors.orangeAccent)),
                                //   description:  Column(
                                //       mainAxisAlignment: MainAxisAlignment.center,
                                //     crossAxisAlignment: CrossAxisAlignment.center,
                                //       children: [
                                //         Image(image: AssetImage('assets/crown1.png'),height: screenHeight/17,width: screenWidth/5,),
                                //         Row(
                                //           crossAxisAlignment: CrossAxisAlignment.center,
                                //           mainAxisAlignment: MainAxisAlignment.center,
                                //           children: [
                                //             Text('Play ',
                                //                 style: GoogleFonts.oswald(fontWeight: FontWeight.w500,color: Colors.white)),
                                //             Text('with ',
                                //                 style: GoogleFonts.oswald(fontWeight: FontWeight.w500,color: Colors.orangeAccent)),
                                //             Text('Computer',
                                //                 style: GoogleFonts.oswald(fontWeight: FontWeight.w500,color: Colors.white)),
                                //           ],
                                //         ),
                                //         SizedBox(height: screenHeight/50,),
                                //         BouncingWidget(
                                //             scaleFactor: _scaleFactor,
                                //             onPressed: () {},
                                //             //_onPressed(context),
                                //             child: CyberButton(
                                //               width: screenWidth/2.5,
                                //               height: screenHeight/20,
                                //               // primaryColorBigContainer: Colors.black,
                                //               // secondaryColorBigContainer: Colors.greenAccent,
                                //               primaryColorBigContainer: color.navy,
                                //               secondaryColorBigContainer: Colors.purple,
                                //               primaryColorSmallContainer: Colors.black,
                                //               secondaryColorSmallContainer: Colors.transparent,
                                //               onTap: (){
                                //
                                //               },
                                //               child: Row(
                                //                 children: [
                                //                   Gap(screenWidth/30),
                                //                   Image(
                                //                     image: AssetImage('assets/chesscoin1.png'),
                                //                     height: screenHeight/20,width: screenWidth/12,color: Colors.orangeAccent,),
                                //                   Padding(
                                //                     padding:  EdgeInsets.only(left: 8.0),
                                //                     child: Text(
                                //                       'EASY',
                                //                       style: TextStyle(color: Colors.white,fontSize: screenWidth/30),
                                //                     ),
                                //                   ),
                                //                 ],
                                //               ),
                                //             )),
                                //         SizedBox(height: screenHeight/50,),
                                //         BouncingWidget(
                                //             scaleFactor: _scaleFactor,
                                //             onPressed: () {},
                                //             //_onPressed(context),
                                //             child: CyberButton(
                                //               width: screenWidth/2.5,
                                //               height: screenHeight/20,
                                //               // primaryColorBigContainer: Colors.black,
                                //               // secondaryColorBigContainer: Colors.greenAccent,
                                //               primaryColorBigContainer: color.navy,
                                //               secondaryColorBigContainer: Colors.purple,
                                //               primaryColorSmallContainer: Colors.black,
                                //               secondaryColorSmallContainer: Colors.transparent,
                                //               child: Row(
                                //                 children: [
                                //                   Gap(screenWidth/30),
                                //                   Image(
                                //                     image: AssetImage('assets/chesscoin1.png'),
                                //                     height: screenHeight/20,width: screenWidth/12,color: Colors.orangeAccent,),
                                //                   Padding(
                                //                     padding:  EdgeInsets.only(left: 8.0),
                                //                     child: Text(
                                //                       'MEDIUM',
                                //                       style: TextStyle(color: Colors.white,fontSize: screenWidth/30),
                                //                     ),
                                //                   ),
                                //                 ],
                                //               ),
                                //             )),
                                //         SizedBox(height: screenHeight/50,),
                                //         BouncingWidget(
                                //             scaleFactor: _scaleFactor,
                                //             onPressed: () {},
                                //             //_onPressed(context),
                                //             child: CyberButton(
                                //               width: screenWidth/2.5,
                                //               height: screenHeight/20,
                                //               // primaryColorBigContainer: Colors.black,
                                //               // secondaryColorBigContainer: Colors.greenAccent,
                                //               primaryColorBigContainer: color.navy,
                                //               secondaryColorBigContainer: Colors.purple,
                                //               primaryColorSmallContainer: Colors.black,
                                //               secondaryColorSmallContainer: Colors.transparent,
                                //               child: Row(
                                //                 children: [
                                //                   Gap(screenWidth/30),
                                //                   Image(
                                //                     image: AssetImage('assets/chesscoin1.png'),
                                //                     height: screenHeight/20,width: screenWidth/12,color: Colors.orangeAccent,),
                                //                   Padding(
                                //                     padding:  EdgeInsets.only(left: 8.0),
                                //                     child: Text(
                                //                       'HARD',
                                //                       style: TextStyle(color: Colors.white,fontSize: screenWidth/30),
                                //                     ),
                                //                   ),
                                //                 ],
                                //               ),
                                //             )),
                                //         // Padding(
                                //         //   padding:  EdgeInsets.only(left: screenWidth/20),
                                //         //   child: CyberButtons(routeName: "/Easy",name: 'Easy',),
                                //         // ),
                                //         // SizedBox(height: screenHeight/50,),
                                //         // Padding(
                                //         //   padding: EdgeInsets.only(left: screenWidth/20),
                                //         //   child: CyberButtons(routeName: "/Medium",name: 'Medium',),
                                //         // ),
                                //         // SizedBox(height: screenHeight/50,),
                                //         // Padding(
                                //         //   padding: EdgeInsets.only(left: screenWidth/20),
                                //         //   child: CyberButtons(routeName: "/Hard",name: 'Hard',),
                                //         // ),
                                //
                                //         ]
                                //   ),
                                //  // enableMainButton: true,
                                //  // onMainButtonPressed: (){},
                                //  // mainButtonText: Text('Ready To Play',style: TextStyle(fontWeight: FontWeight.bold),),
                                //   mainButtonColor: color.navy1,
                                //   cancelable:  true,
                                //   emojiType: EMOJI_TYPE.JOYFUL,
                                //   emojiSize: 0,
                                //   cornerRadiusType: CORNER_RADIUS_TYPES.ALL_CORNERS,
                                //   // background: Colors.grey,
                                //   background: color.navy1,
                                //   //Colors.white.withOpacity(0.15),
                                //   height:  screenHeight/2.5,
                                //  // width: screenWidth/1.,
                                //   animationType: ANIMATION_TYPE.TRANSITION,
                                // ).displayAlert(context);
                              },
                              child:  Row(
                                children: [
                                  Gap(screenWidth/100),
                                  Image(image: AssetImage('assets/play.png'),height: screenHeight/35,width: screenWidth/18,),
                                  Gap(screenWidth/100),
                                  Text(
                                    'Play with Computer',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: screenWidth/30),
                                  ),
                                ],
                              ),
                            ),
                            // Image(image: AssetImage('assets/play.png'),height: 60,width: 80,fit: BoxFit.cover,),
                            //  Text(
                            //   "Play vs Computer",
                            //    style: GoogleFonts.oswald(color: Colors.white,fontSize: screenWidth/20,fontWeight: FontWeight.bold)
                            // ),

                          ],
                        ),
                     // ),
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Text("chess",
                      //         //": $currentProgress",
                      //         style: TextStyle(color: Colors.white, fontSize: 30.0)),
                      //   ],
                      // ),
                    ),
                  ),
                ),
                // SizedBox(height: screenHeight/500),
                // Image(image: AssetImage('assets/chess-coin.png'),),
               //  Gap(screenHeight/50),
               //  Row(
               //    mainAxisAlignment: MainAxisAlignment.center,
               //    crossAxisAlignment: CrossAxisAlignment.center,
               //    children: [
               //      Text('PLAY',style: GoogleFonts.oswald(color: Colors.white,fontSize: screenWidth/20,fontWeight: FontWeight.bold),
               //      ),
               //      Gap(screenWidth/50),
               //      Text('LOCAL',style: GoogleFonts.oswald(fontSize: screenWidth/20,fontWeight: FontWeight.bold,color: Colors.amberAccent),),
               //
               //    ],
               //  ),
               //  Padding(
               //    padding:EdgeInsets.symmetric(horizontal:10.0),
               //    child:Container(
               //      height:screenHeight/400,
               //      width:screenWidth/5,
               //      decoration: const BoxDecoration(
               //        gradient: LinearGradient(
               //          colors: [Colors.white,Colors.amber, Colors.white],
               //          begin: Alignment.bottomLeft,
               //          end: Alignment.topRight,
               //        ),
               //      ),
               //    ),),
               //  HomeScreenButton(
               //      text: "Multiplayer",
               //      minWidth: minWidth,
               //      onPressed: (context) {
               //        logic.args.isMultiplayer = true;
               //        Navigator.pushNamed(context, '/color');
               //      }
               //  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
