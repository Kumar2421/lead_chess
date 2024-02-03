import 'package:button_animations/button_animations.dart';
import 'package:chess_game/buttons/back_button.dart';
import 'package:chess_game/cyber/cyber_one.dart';
import 'package:chess_game/games/tournament/registration.dart ';
import 'package:chess_game/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:chess_game/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class TournamentPage extends StatefulWidget {
  const TournamentPage({super.key});

  @override
  State<TournamentPage> createState() => _TournamentPageState();
}

class _TournamentPageState extends State<TournamentPage> {
  double _scaleFactor = 1.0;

  _onPressed(BuildContext context) {
    print("CLICK");
  }
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
                      Text('TOURNA',style: GoogleFonts.oswald(color: Colors.white,fontSize: screenWidth/20,fontWeight: FontWeight.bold),
                      ),
                      Text('MENT',style: GoogleFonts.oswald(fontSize: screenWidth/20,fontWeight: FontWeight.bold,color: Colors.amberAccent),),
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
      body: Container(
        height: screenHeight/1,
        width: screenWidth/1,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/checked-background.png'),
                fit: BoxFit.cover
            )
        ),
        child: Container(
          height: screenHeight/1,
          width: screenWidth/1,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/tournament2.png'),
                  fit: BoxFit.cover
              )
          ),
          child: Column(
            children: [
              Gap(screenHeight/7.6),
              AnimatedButton(
                type: null,
                blurRadius: 10,
                shadowColor:  color.blue3,
                color: color.navy,
                //borderColor: color.navy,
                // blurColor: color.beige2,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CyberOne()));
                },
                child: Text(
                  'Create Tournament', // add your text here
                  style: TextStyle(
                      color: Colors.white,fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Gap(screenHeight/20),
              AnimatedButton(
                type: null,
                blurRadius: 10,
                shadowColor:  color.blue3,
                color: color.navy,
                //borderColor: color.navy,
                // blurColor: color.beige2,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>JoinTournament()));
                },
                child: Text(
                  'Join Tournament', // add your text here
                  style: TextStyle(
                      color: Colors.white,fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Gap(screenHeight/3.35),
          //    Image(image: AssetImage('assets/Tournament1.png'),
            //    height: screenHeight/6,width: screenWidth/1.5,fit: BoxFit.cover,),
            //  Gap(screenHeight/50),
              // Image(
              //   image: AssetImage('assets/LC-logo1.png'),
              //   height: screenHeight/20,width: screenWidth/5,fit: BoxFit.cover,),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     Text('TOURNAMENT',style: GoogleFonts.oswald(color: Colors.white,fontSize: screenWidth/20,fontWeight: FontWeight.bold),
              //     ),
              //    // Gap(screenWidth/50),
              //    // Text('CHESS',style: GoogleFonts.oswald(fontSize: screenWidth/20,fontWeight: FontWeight.bold,color: Colors.amberAccent),),
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
            ],
          ),
        ),
      ),
    );
  }
}


class User {
  final String username;
  final String lastSeen;
  final String imageUrl;
  final String totalPlayer;

  const User( {
    required this.totalPlayer,
    required this.username,
    required this.lastSeen,
    required this.imageUrl,});
}

class JoinTournament extends StatefulWidget {
  const JoinTournament({super.key});

  @override
  State<JoinTournament> createState() => _JoinTournamentState();
}

class _JoinTournamentState extends State<JoinTournament> {
  List<User> users=[
    const User(username: '800 Freeroll', lastSeen: '08:00AM/06-11-23', imageUrl: 'assets/chesscoin.png',totalPlayer: '8/0'),
    const User(username: '1.6K Freeroll', lastSeen: '10:00AM/06-11-23', imageUrl: 'assets/chesscoin.png',totalPlayer: '16/0'),
    const User(username: '800 Freeroll', lastSeen: '12:00PM/06-11-23', imageUrl: 'assets/chesscoin.png',totalPlayer: '8/0'),
    const User(username: '1.6k Freeroll', lastSeen: '02:00PM/06-11-23', imageUrl: 'assets/chesscoin.png',totalPlayer: '16/0'),
    const User(username: '800 Freeroll', lastSeen: '12:00PM/06-11-23', imageUrl: 'assets/chesscoin.png',totalPlayer: '8/0'),
    const User(username: '1.6k Freeroll', lastSeen: '02:00PM/06-11-23', imageUrl: 'assets/chesscoin.png',totalPlayer: '16/0'),
    const User(username: '800 Freeroll', lastSeen: '12:00PM/06-11-23', imageUrl: 'assets/chesscoin.png',totalPlayer: '8/0'),
    const User(username: '1.6k Freeroll', lastSeen: '02:00PM/06-11-23', imageUrl: 'assets/chesscoin.png',totalPlayer: '16/0'),
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
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
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
        //  mainAxisAlignment: MainAxisAlignment.start,
          //  crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                backgroundColor: color.navy1.withOpacity(0.15),
                title: Text('Tournament'),
        ),
              Container(
                height: screenHeight/8,
                width: screenWidth/1,
                decoration: BoxDecoration(
                 // color: color.navy1.withOpacity(0.25),
                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.black,
                                      color.navy1
                                    ],
                                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Chess',style: GoogleFonts.oswald(color: Colors.white,fontSize: screenWidth/15,fontWeight: FontWeight.bold)),
                    Image(
                        image: AssetImage('assets/piece.png'),height: screenHeight/8,width: screenWidth/8,
                    ),
                   Text('Tourney',style: GoogleFonts.oswald(color: Colors.white,fontSize: screenWidth/15,fontWeight: FontWeight.bold))
                  ],
                ),
              ),
              Container(
                height: screenHeight/2,
                width: screenWidth/1,
                // decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(12)
                // ),
                // child: ListView.builder(
                //           itemCount: friends.length,
                //           itemBuilder: (BuildContext context, int index) {
                //             return FriendsList(child: friends[index],);
                //           },
                //         ),
                child:
                ListView.builder(
                  //physics: AlwaysScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (BuildContext context, int index) {
                    final user = users[index];
                    return Container(
                      height: screenHeight/12,
                      width: screenWidth/1.2,
                      decoration: BoxDecoration(
                        color: color.navy1.withOpacity(0.25),
                        border: Border(
                          bottom: BorderSide(color: color.navy1, width: 1.0), // Set the border color and width for the bottom side
                        ),
                      ),
                        child: ListTile(
                          // textColor: color.navy1.withOpacity(0.25),
                          //  contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                          // tileColor: color.navy1.withOpacity(0.15),
                          leading: Image(image: AssetImage('assets/piece.png'),height: screenHeight/20,),
                          title: Text(user.username,style: TextStyle(fontSize: 13,color: Colors.white),),
                          subtitle: Text(user.lastSeen,style: TextStyle(fontSize: 11,color: Colors.white),),
                          trailing: Column(
                            children: [
                              Container(
                                height: screenHeight/35,
                                width: screenWidth/4.5,

                                child: ElevatedButton(
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Registration()));
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:MaterialStateProperty.all(color.navy1),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),))
                                  ),
                                  child: Text('Registering',style: TextStyle(fontSize: screenWidth/40,),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(top: screenHeight/100),
                                child: Text(user.totalPlayer, style: TextStyle(fontSize: 13,color: Colors.white),),
                              ),
                            ],
                          ),
                      ),
                    );
                  },
                ),
               ),
            ]
        ),
      )
    );
  }
}
