
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:button_animations/button_animations.dart';
import 'package:chess_game/buttons/back_button.dart';
import 'package:chess_game/buttons/bounce_button.dart';
import 'package:chess_game/buttons/fancy_button.dart';
import 'package:chess_game/friends-list.dart';
import 'package:chess_game/screen/home_screen.dart';
import 'package:chess_game/style/text_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chess_game/colors.dart';
import 'package:gap/gap.dart';
import 'package:chess_game/search-bar.dart';

import '../style/create-link.dart';

class User {
  final String username;
  final String lastSeen;
  final String imageUrl;

  const User({
    required this.username,
    required this.lastSeen,
    required this.imageUrl,});
}

class PlayFriend extends StatefulWidget {
  const PlayFriend({super.key});

  @override
  State<PlayFriend> createState() => _PlayFriendState();
}

class _PlayFriendState extends State<PlayFriend> {
  TextEditingController textController = TextEditingController();
 List<User> users=[
   const User(username: 'esakki', lastSeen: '2 hour', imageUrl: 'assets/profile.png'),
   const User(username: 'esakki', lastSeen: '2 hour', imageUrl: 'assets/profile.png'),
   const User(username: 'esakki', lastSeen: '2 hour', imageUrl: 'assets/profile.png'),
   const User(username: 'esakki', lastSeen: '2 hour', imageUrl: 'assets/profile.png')
 ];
   final List friends = [
    'chess',
    'coin',
    'board',
     'chess',
     'coin',
     'board',
     'chess',
     'coin',
     'board',
  ];
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('PLAY ',style: GoogleFonts.oswald(color: Colors.white,fontSize: screenWidth/20,fontWeight: FontWeight.bold),
                      ),
                      Text('with ',style: GoogleFonts.oswald(fontSize: screenWidth/20,fontWeight: FontWeight.bold,color: Colors.amberAccent),),
                      Text('FRIENDS',style: GoogleFonts.oswald(color: Colors.white,fontSize: screenWidth/20,fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Padding(
                    padding:EdgeInsets.symmetric(horizontal:10.0),
                    child:Container(
                      height:screenHeight/400,
                      width:screenWidth/3,
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
      body:  Container(
        height: screenHeight/1,
        width: screenWidth/1,
        decoration: BoxDecoration(
              image: DecorationImage(
              image: AssetImage('assets/checked-background.png'),
          fit: BoxFit.cover
          ),),
        child: Container(
          height: screenHeight/1,
          width: screenWidth/1,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/friends2.png'),
                fit: BoxFit.cover
            ),),
          child:  SingleChildScrollView(
            scrollDirection: Axis.vertical,
           physics: BouncingScrollPhysics(),
            child: Column(
                children: [
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth/20),
                        child: AnimSearchBar(
                          width: screenWidth/1.15,
                          color: color.navy1,
                          prefixIcon: Icon(Icons.search_rounded,color: Colors.white,),
                          suffixIcon: Icon(Icons.close,color: Colors.white,),
                          textController: textController,
                          onSuffixTap: () {
                            setState(() {
                              textController.clear();
                            });
                          }, onSubmitted: (String ) {},
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateLink()));
                        },
                        child: Container(
                          height: screenHeight/15,
                          width: screenWidth/1.5,
                          decoration: BoxDecoration(
                            color: color.navy1.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              //SizedBox(width: screenWidth/20,),
                              Image(image: AssetImage('assets/playfriend.png'),height: screenHeight/20,width: screenWidth/10,),
                              //SizedBox(width: screenWidth/20,),
                              Text('CHALLENGE FRIENDS',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)
                            ],
                          ),
                        ),
                      ),
                 SizedBox(height: screenHeight/40,),
                  Container(
                    height: screenHeight/2,
                    width: screenWidth/1.1,
                    decoration: BoxDecoration(
                     // color: color.navy1.withOpacity(0.30)
                      borderRadius: BorderRadius.circular(12)
                    ),
                    // child: ListView.builder(
                    //           itemCount: friends.length,
                    //           itemBuilder: (BuildContext context, int index) {
                    //             return FriendsList(child: friends[index],);
                    //           },
                    //         ),
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (BuildContext context, int index) {
                        final user = users[index];
                        return Container(
                                  height: screenHeight/14,
                                  width: screenWidth/1.2,
                                  decoration: BoxDecoration(
                                    color: color.navy1.withOpacity(0.25),
                                    border: Border(
                                      bottom: BorderSide(color: color.navy1, width: 1.0), // Set the border color and width for the bottom side
                                    ),
                                  ),
                                  child: Center(
                                    child: ListTile(
                                     // textColor: color.navy1.withOpacity(0.25),
                                    //  contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                     // tileColor: color.navy1.withOpacity(0.15),
                                      leading: CircleAvatar(
                                        radius: 20,
                                        backgroundImage: AssetImage(user.imageUrl),
                                      ),
                                      title: Text(user.username,style: TextStyle(fontSize: 13,),),
                                      subtitle: Text(user.lastSeen,style: TextStyle(fontSize: 11),),
                                      trailing: Container(
                                        height: screenHeight/30,
                                        width: screenWidth/3.5,

                                        child: ElevatedButton(
                                          onPressed: (){},
                                          style: ButtonStyle(
                                            backgroundColor:MaterialStateProperty.all(color.navy1),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),))
                                          ),
                                          child: Text('Challenge',style: TextStyle(fontSize: screenWidth/25,),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                        );

                      },
                    ),
                  ),

                //  ),
                  // Gap(screenHeight/2.4),
                  // Image(image: AssetImage('assets/friends.png'),
                  //   height: screenHeight/4.5,width: screenWidth/1.9,fit: BoxFit.cover,),
                  // Gap(screenHeight/100),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                  //     Text('PLAY ',style: GoogleFonts.oswald(color: Colors.white,fontSize: screenWidth/20,fontWeight: FontWeight.bold),
                  //     ),
                  //     Text('with',style: GoogleFonts.oswald(fontSize: screenWidth/20,fontWeight: FontWeight.bold,color: Colors.amberAccent),),
                  //     Text('FRIENDS',style: GoogleFonts.oswald(color: Colors.white,fontSize: screenWidth/20,fontWeight: FontWeight.bold),
                  //     ),
                  //
                  //   ],
                  // ),
                  // Padding(
                  //   padding:EdgeInsets.symmetric(horizontal:10.0),
                  //   child:Container(
                  //     height:screenHeight/400,
                  //     width:screenWidth/5,
                  //     decoration: const BoxDecoration(
                  //       gradient: LinearGradient(
                  //         colors: [Colors.white,Colors.amber, Colors.white],
                  //         begin: Alignment.bottomLeft,
                  //         end: Alignment.topRight,
                  //       ),
                  //     ),
                  //   ),),
                  // SizedBox(height: 50,),
                  // ArrowBackButton(color: color.navy1,),
                  // Padding(
                  //   padding:  EdgeInsets.only(top: 100,left: 10),
                  //   child: Stack(
                  //     children: [
                  //       Transform(
                  //         transform: Matrix4.skewY(-0.05),
                  //         child: Container(
                  //             height:screenHeight/12,
                  //             width: screenWidth/1.2,
                  //             decoration: BoxDecoration(
                  //               gradient: LinearGradient(
                  //                 begin: Alignment.topCenter,
                  //                 end: Alignment.bottomCenter,
                  //                 colors: [
                  //                   Color.fromRGBO (209,4,43,1),
                  //                   Color. fromRGBO(214,61,99, 1),
                  //                 ],
                  //               ), // LinearGradient
                  //               borderRadius: BorderRadius.all(Radius.circular (25)),
                  //             ),
                  //             child:  Row(
                  //               children: [
                  //                 Padding(
                  //                   padding:  EdgeInsets.only(left: 20),
                  //                   child: Text('Play with Computer',style: kText,),
                  //                 ),
                  //                 Image(image: AssetImage('assets/chesscoin1.png'),
                  //                   height: screenHeight/7,
                  //                   width: screenWidth/5,
                  //                 )
                  //               ],
                  //             )
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(height: 50,),
                  // Motion.elevated(
                  //   elevation: 70,
                  //
                  //   borderRadius: cardBorderRadius,
                  //   child:  Card(
                  //     elevation: 45,
                  //     color: color.navy1,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: cardBorderRadius,
                  //     ),
                  //     child: Container(
                  //       width: 280,
                  //       height: 170,
                  //       //color: color.navy1,
                  //       // Add your content here
                  //     ),
                  //     // width: 280, height: 170, borderRadius: cardBorderRadius
                  //   ),
                  // ),
                  // SizedBox(height: 50,),
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: BlurryContainer(
                  //  //   color: Colors.white.withOpacity(0.15),
                  //     color: Colors.transparent,
                  //     blur: 8,
                  //     elevation: 5,
                  //     height: 240,
                  //     padding: const EdgeInsets.all(32),
                  //     child: Column(
                  //       // mainAxisAlignment: MainAxisAlignment.start,
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         const CircleAvatar(
                  //           radius: 35,
                  //           backgroundColor: Colors.transparent,
                  //           backgroundImage: NetworkImage(
                  //               'https://img.indiaforums.com/person/480x360/0/0211-hrithik-roshan.jpg?c=4lP5F3'),
                  //         ),
                  //         const Spacer(),
                  //         const Text(
                  //           "0100 0010 0100 0011",
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontSize: 20,
                  //             fontWeight: FontWeight.w200,
                  //           ),
                  //         ),
                  //         const SizedBox(height: 8),
                  //         Row(
                  //           children: [
                  //             Text(
                  //               "Ranjeet Rocky".toUpperCase(),
                  //               style: TextStyle(
                  //                 color: Colors.white.withOpacity(0.5),
                  //                 // fontSize: 16,
                  //                 fontWeight: FontWeight.w200,
                  //               ),
                  //             ),
                  //             const Spacer(),
                  //             Text(
                  //               "VALID",
                  //               style: TextStyle(
                  //                 color: Colors.white.withOpacity(0.5),
                  //                 fontWeight: FontWeight.w200,
                  //               ),
                  //             ),
                  //             const SizedBox(width: 4),
                  //             Text(
                  //               "06/24",
                  //               style: TextStyle(
                  //                 color: Colors.white.withOpacity(0.8),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // BounceButton(onTap: (){},
                  //     height: screenHeight/15, width: screenWidth/4, duration: Duration(milliseconds: 1000), child: Text('child')),
                  // ListView.separated(
                  //   itemBuilder: (context, index){
                  //     final text = texts[index];
                  //     return Center(
                  //
                  //       child: Container(
                  //         width: 160,
                  //         child: Text(
                  //           text,style: TextStyle(fontSize: 32,color: Colors.black),),
                  //       ),
                  //     );
                  //   },
                  //   separatorBuilder: (context, index) => Divider(),
                  //   itemCount: texts.length,
                  //   shrinkWrap:true,),
                  // SizedBox(height: 50,),
                  // AnimatedButton(
                  //   child: Text(
                  //     'Dark', // add your text here
                  //     style: TextStyle(
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  //   type: null,
                  //   blurRadius: 10,
                  //   onTap: () {},
                  // ),
                  // SizedBox(height: 50,),
                  // FancyButton( key: Key('unique_key'), // Provide a unique key here
                  //   onPressed: () {
                  //     // Your onPressed callback
                  //     // VoidCallback;
                  //   },
                  //   icon: Icons.people, // Your icon
                  //   text: 'Head to Head', ),
                  // SizedBox(height: 50,),

                ],
              ),
          ),
          ),
        ),


    );
  }
}