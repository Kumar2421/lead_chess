import 'package:button_animations/button_animations.dart';
import 'package:chess_game/expandable-slider.dart';
import 'package:emoji_alert/arrays.dart';
import 'package:emoji_alert/emoji_alert.dart';
import 'package:flutter/material.dart';
import 'package:chess_game/colors.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
class CreateLink extends StatefulWidget {
  const CreateLink({super.key});

  @override
  State<CreateLink> createState() => _CreateLinkState();
}

class _CreateLinkState extends State<CreateLink> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
     // backgroundColor: color.navy1.withOpacity(0.15),
      body: Container(
        height: screenHeight/1,
        width: screenWidth/1,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/sky1.jpg'),fit:BoxFit.cover
          )
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: color.navy1.withOpacity(0.15),
              title: Text('Challenge Friends'),
            ),
            Padding(
              padding:  EdgeInsets.only(top: screenHeight/15),
              child: Container(
                height: screenHeight/14,
                width: screenWidth/1.2,
                decoration: BoxDecoration(
                    color: color.navy1.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)
                ),
                  child: Center(
                    child: ListTile(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>TimeSet()));
                      },
                        leading: Icon(Icons.lock_clock),
                        title: Text('Time set',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      subtitle: Text('10 min',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      trailing: Icon(Icons.arrow_forward),
                       ),
                  ),
              ),
           ),
            SizedBox(height: screenHeight/20,),
            AnimatedButton(
              type: null,
              blurRadius: 10,
              height: screenHeight/18,
              width: screenWidth/2,
              shadowColor: Colors.transparent,
              color: color.navy1.withOpacity(0.15),
              borderColor: Colors.transparent,
              blurColor: Colors.transparent,
              onTap: () {
                EmojiAlert(
                  //alertTitle:  Text("Player1 vs Player2", style:  TextStyle(fontWeight:  FontWeight.bold)),
                  description:  Column(
                      children: [
                        Icon(Icons.share,color: Colors.white,),
                        Text('Share Friends',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
                        Gap(screenHeight/20),
                        Container(
                          height: screenHeight/20,
                          width: screenWidth/2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white)
                        ),
                        ),
                        Gap(screenHeight/20),
                       Container(
                         height: screenHeight/23,
                         width: screenWidth/2,
                         child: ElevatedButton(
                             onPressed: (){},
                           style: ButtonStyle(
                             minimumSize: MaterialStateProperty.all(Size(screenWidth/2,screenHeight/23)), // Change the width and height
                             backgroundColor: MaterialStateProperty.all(Colors.white)
                           ),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(Icons.copy,color: Colors.black,),
                                 Text('COPY LINK',
                                   style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: color.navy1),),
                               ],
                             ),),
                       )
                      ]
                  ),
                  enableMainButton: true,
                 // enableSecondaryButton: true,
                  onMainButtonPressed: (){},
                 // onSecondaryButtonPressed: (){},
                  //secondaryButtonText: Text('Copy Link', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20),),
                  mainButtonText: Text('SHARE LINK',
                    style: TextStyle(fontWeight: FontWeight.bold,color: color.navy1,fontSize: 20),),
                  mainButtonColor: Colors.white,
                  //secondaryButtonColor: Colors.white,
                  cancelable:  true,
                  emojiType: EMOJI_TYPE.JOYFUL,
                  emojiSize: 0,
                  cornerRadiusType: CORNER_RADIUS_TYPES.ALL_CORNERS,
                  background: color.navy1.withOpacity(0.35),
                  //Colors.white.withOpacity(0.15),
                  height: screenHeight/2.5,
                  buttonSize: screenWidth/2,
                  animationType: ANIMATION_TYPE.TRANSITION,
                  //alignment: Alignment.center,
                ).displayAlert(context);
              },
              child: Text(
                    'Create Link',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: screenWidth/20),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
class TimeSet extends StatefulWidget {
  const TimeSet({super.key});

  @override
  State<TimeSet> createState() => _TimeSetState();
}

class _TimeSetState extends State<TimeSet> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    const padding = EdgeInsets.only(top: 25,left: 25 );
    return Scaffold(
      body: Container(
        height: screenHeight/1,
        width: screenWidth/1,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/sky1.jpg'),fit:BoxFit.cover
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(
              backgroundColor: color.navy1.withOpacity(0.15),
              title: Text('Time Set'),
            ),
            // Padding(
            //   padding: padding,
            //   child: Text('FAST',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),),
            // ),
            // Padding(
            //   padding: padding,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //       children: [
            //         Container(
            //           height: screenHeight/16,
            //           width: screenWidth/3.5,
            //           decoration: BoxDecoration(
            //               color: color.navy1.withOpacity(0.15),
            //               borderRadius: BorderRadius.circular(12)
            //           ),
            //           child: Center(child: Text('30 sec',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),)),
            //         ),
            //         Container(
            //           height: screenHeight/16,
            //           width: screenWidth/3.5,
            //           decoration: BoxDecoration(
            //               color: color.navy1.withOpacity(0.15),
            //               borderRadius: BorderRadius.circular(12)
            //           ),
            //           child: Center(child: Text('1 min',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),)),
            //         ),
            //         Container(
            //           height: screenHeight/16,
            //           width: screenWidth/3.5,
            //           decoration: BoxDecoration(
            //               color: color.navy1.withOpacity(0.15),
            //               borderRadius: BorderRadius.circular(12)
            //           ),
            //           child: Center(child: Text('2 min',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),)),
            //         )
            //       ],
            //     ),
            // ),
            // Padding(
            //   padding: padding,
            //   child: Text('MEDIUM  ',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),),
            // ),
            // Padding(
            //   padding: padding,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       Container(
            //         height: screenHeight/16,
            //         width: screenWidth/3.5,
            //         decoration: BoxDecoration(
            //             color: color.navy1.withOpacity(0.15),
            //             borderRadius: BorderRadius.circular(12)
            //         ),
            //         child: Center(child: Text('3 min',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),)),
            //       ),
            //       Container(
            //         height: screenHeight/16,
            //         width: screenWidth/3.5,
            //         decoration: BoxDecoration(
            //             color: color.navy1.withOpacity(0.15),
            //             borderRadius: BorderRadius.circular(12)
            //         ),
            //         child: Center(child: Text('4 min',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),)),
            //       ),
            //       Container(
            //         height: screenHeight/16,
            //         width: screenWidth/3.5,
            //         decoration: BoxDecoration(
            //             color: color.navy1.withOpacity(0.15),
            //             borderRadius: BorderRadius.circular(12)
            //         ),
            //         child: Center(child: Text('5 min',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),)),
            //       )
            //     ],
            //   ),
            // ),
            // Padding(
            //   padding: padding,
            //   child: Text('SLOW  ',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),),
            // ),
            // Padding(
            //   padding:padding,
            //   //EdgeInsets.only(left: screenWidth/20,top: screenHeight/20),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       Container(
            //         height: screenHeight/16,
            //         width: screenWidth/3.5,
            //         decoration: BoxDecoration(
            //             color: color.navy1.withOpacity(0.15),
            //             borderRadius: BorderRadius.circular(12)
            //         ),
            //         child: Center(
            //             child: Text('10 min',
            //               style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),)),
            //       ),
            //       Container(
            //         height: screenHeight/16,
            //         width: screenWidth/3.5,
            //         decoration: BoxDecoration(
            //             color: color.navy1.withOpacity(0.15),
            //             borderRadius: BorderRadius.circular(12)
            //         ),
            //         child: Center(
            //             child: Text('20 min',
            //               style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),)),
            //       ),
            //       Container(
            //         height: screenHeight/16,
            //         width: screenWidth/3.5,
            //         decoration: BoxDecoration(
            //             color: color.navy1.withOpacity(0.15),
            //             borderRadius: BorderRadius.circular(12)
            //         ),
            //         child: Center(
            //             child: Text('30 min',
            //               style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),)),
            //       ),
            //     ],
            //   ),
            // ),
            Padding(
              padding:padding,
              child: Row(
                children: [
                  Icon(Icons.access_time,color: Colors.orangeAccent,),
                  Text(' Custom Time Set',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: screenWidth/10,top: screenHeight/35),
              child: Container(
                height: screenHeight/3,
                  width: screenWidth/1.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: color.navy1.withOpacity(0.15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ExpandSlider(max: 120, min: 0,),
                      ExpandSlider(max: 60, min: 0,name: 'Bonce ',time: ' sec',value: ' 60',),
                      MaterialButton(
                        onPressed: (){},
                        color: color.navy1.withOpacity(0.15),
                      child: Text('Check',style: TextStyle(color: Colors.white),),
                      )
                    ],
                  )),
            ),
            Padding(
              padding:padding,
              child: Row(
                children: [
                  Icon(Icons.sunny_snowing,color: Colors.orangeAccent,),
                  Text('Days  ',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),),
                ],
              ),
            ),
               SizedBox(height: screenHeight/50,),
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: screenHeight/16,
                    width: screenWidth/3.5,
                    decoration: BoxDecoration(
                        color: color.navy1.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Center(
                        child: Text('1 day',
                          style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),)),
                  ),
                  Container(
                    height: screenHeight/16,
                    width: screenWidth/3.5,
                    decoration: BoxDecoration(
                        color: color.navy1.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Center(
                        child: Text('2 day',
                          style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),)),
                  ),
                  Container(
                    height: screenHeight/16,
                    width: screenWidth/3.5,
                    decoration: BoxDecoration(
                        color: color.navy1.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Center(
                        child: Text('3 day',
                          style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
