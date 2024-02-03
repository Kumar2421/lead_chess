import 'package:flutter/material.dart';
import 'package:chess_game/colors.dart';

class Event extends StatefulWidget {
  const Event({super.key});

  @override
  State<Event> createState() => _EventState();
}

class _EventState extends State<Event> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return
      // Scaffold(
      //
      // body:
      Container(
          height: screenHeight/1,
          width: screenWidth/1,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/chess1.png'),
                  fit: BoxFit.cover
              )
          ),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            //BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            // physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
                children: [
                  AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: color.navy1.withOpacity(0.25),
                    title:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Event'),
                        Container(
                          height: screenHeight/32,
                          width: screenWidth/4,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: color.navy
                          ),
                          child: Row(
                            children: [
                              Image(image: AssetImage('assets/money1.png'),
                                height: screenHeight/20,
                                width: screenWidth/16,
                              ),
                              Container(
                                  height: screenHeight/32,
                                  width: screenWidth/7,
                                  child: Center(
                                      child: Text("0",style: TextStyle(color: Colors.white),))),
                              //Gap(screenWidth/10),
                              // Padding(
                              //   padding:  EdgeInsets.only(left: screenWidth/7.5),
                              Image(image: AssetImage('assets/plus1.png'),
                                height: screenHeight/28,
                                width: screenWidth/23,
                              ),
                              //),
                            ],
                          ),
                        ),
                        Container(
                          height: screenHeight/32,
                          width: screenWidth/4,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: color.navy
                          ),
                          child: Row(
                            children: [
                              Image(image: AssetImage('assets/coin4.png'),
                                height: screenHeight/25,
                                width: screenWidth/18,
                              ),
                              Container(
                                  height: screenHeight/32,
                                  width: screenWidth/7.5,
                                  child: Center(
                                      child: Text("100",style: TextStyle(color: Colors.white),))),
                              Image(image: AssetImage('assets/plus1.png'),
                                height: screenHeight/28,
                                width: screenWidth/23,
                              ),
                            ],
                          ),
                          //  ),
                        ),
                      ],
                    ),

                  ),
                ]
            ),
          )
      );
  }
}
