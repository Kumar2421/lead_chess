import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chess_game/buttons/back_button.dart';
import 'package:chess_game/colors.dart';
import 'package:chess_game/server_side/show_online_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../user/current_user.dart';
import '../user/users.dart';

class User1 {
  final String username;
  final String winningamount;
 final String bettingamount;
 //final String points;

  const User1( {
    required this.winningamount,
    required this.bettingamount,
    required this.username,
  //  required this.points,
  });

  factory User1.fromJson(Map<String, dynamic> json) {
    return User1(
      username: 'User', // Adjust as needed
      winningamount: json['winning_amount'],
      bettingamount: json['betting_amount'],
    //  points: 'assets/pawn.png', // Adjust as needed
    );
  }
}


class PlayOnline2 extends StatefulWidget {
  const PlayOnline2({super.key});

  @override
  State<PlayOnline2> createState() => _PlayOnline2State();
}

class _PlayOnline2State extends State<PlayOnline2>with TickerProviderStateMixin {
  int activeIndex = 0;
  CarouselController buttonCarouselController = CarouselController();
  List<User1> users = [];
  Users currentUser = Get.find<CurrentUser>().users;
  @override
  void initState() {
    super.initState();
    fetchGameData();
  }

  Future<void> fetchGameData() async {
    final response = await http.get(Uri.parse('https://schmidivan.com/Esakki/ChessGame/fetch_online_game'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        users = data.map((json) => User1.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load game data');
    }
  }
  Future<void> updateBettingAmount(String userId, String bettingAmount) async {
    try {
      final response = await http.post(
        Uri.parse('https://schmidivan.com/senthil/_ChessGame/update_betting_amount'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'user_id': userId,
          'betting_amount': bettingAmount,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          // Update was successful
          print('Betting amount updated successfully');
          SharedPreferences pref =await SharedPreferences. getInstance();
          await pref. setString("bettingAmount", bettingAmount);
          Navigator.push(context, MaterialPageRoute(builder:(Context)=>PlayOnline(bettingAmount: '', userData: {},)));
        } else {
          // Handle error
          print('Error: ${responseData['message']}');
        }
      } else {
        // Handle error
        print('Failed to update betting amount. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: color.navy1,
          automaticallyImplyLeading: false,
          leading: const ArrowBackButton(color: Colors.white,),
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
                        Text('ONLINE',style: GoogleFonts.oswald(fontSize: screenWidth/20,fontWeight: FontWeight.bold,color: Colors.amberAccent),),
                      ],
                    ),
                    Padding(
                      padding:const EdgeInsets.symmetric(horizontal:10.0),
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
          decoration: const BoxDecoration(
            image: DecorationImage(
               image: AssetImage('assets/Designer.jpeg'), fit: BoxFit.cover,),
          ),
          child: Container(
            height: screenHeight/1,
            width: screenWidth/1,
            decoration: const BoxDecoration(
            //  image: DecorationImage(
               // image: AssetImage('assets/play-online2.png'), fit: BoxFit.cover,),
            ),
            // child: SingleChildScrollView(
            //   scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                child: Column(
                 children: [
                   SizedBox(height: screenHeight/4,),
                Padding(
                  padding: const EdgeInsets.only(right: 4.0,left: 4.0),
                  child: Stack(
                      alignment: Alignment.bottomCenter,
                      children:[
                        CarouselSlider(
                        //  items: _items.map((itemColor)
                    items: users.map((user) {
                      // final user = users[index];
                      List<Gradient> containerGradients = [
                        const RadialGradient(
                          colors: [Colors.green, Colors.blue,Colors.green,],
                          radius: 1.75,
                        ),
                        const RadialGradient(
                          colors: [Colors.grey, Colors.red,Colors.grey,],
                          radius: 1.75,
                        ),
                        const RadialGradient(
                          colors: [Colors.blue, Colors.grey,Colors.blue,],
                          radius: 1.75,
                        ),
                        const RadialGradient(
                          colors: [Colors.blue, Colors.purple,Colors.blue],
                          radius: 2.75,
                        ),
                        const RadialGradient(
                          colors: [Colors.pink, Colors.black,Colors.pink],
                          radius: 2.75,
                        ),
                        const RadialGradient(
                          colors: [Colors.black, Colors.pink,Colors.black],
                          radius: 2.75,
                        ),
                        // Add more gradients as needed
                      ];
                      Gradient containerGradient = containerGradients[users.indexOf(user) % containerGradients.length];
                            return GestureDetector(
                              onTap: (){
                                updateBettingAmount(currentUser.userId, user.bettingamount);
                              },
                              child: Container(
                                height: screenHeight/2.5,
                                width: screenWidth/1.3,
                                decoration: BoxDecoration(
                                 // color: itemColor,
                                  gradient: containerGradient,
                                 //  gradient: LinearGradient(
                                 //    colors: [Colors.brown, Colors.red, Colors.brown], // Adjust the gradient colors as needed
                                 //    begin: Alignment.bottomLeft,
                                 //    end: Alignment.topRight,
                                 //  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: color.navy.withOpacity(0.55), width: 10.0
                                    //   bottom: BorderSide(color: color.navy1, width: 3.0), // Set the border color and width for the bottom side
                                  ),
                                ),
                              //  child: Text('100 coins'),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "betting amount:  ${user.bettingamount}",
                                        style:  TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "winning amount:  ${user.winningamount}",
                                        style: const TextStyle(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
                                      ),
                                      // const SizedBox(height: 10),
                                      // Image(
                                      //   image: AssetImage(user.points),
                                      //   height: screenHeight / 10,
                                      //   width: screenWidth / 10,
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          carouselController: buttonCarouselController,
                          options:  CarouselOptions( // Set the desired options for the carousel
                            onPageChanged: (index, reason){
                              setState((){
                              //  activeIndex=index;
                              });
                            },
                            initialPage: 0,
                            // height: 300, // Set the height of the carousel
                            enlargeCenterPage: true,
                          //  autoPlay: true, // Enable auto-play
                            autoPlayCurve: Curves.easeInOut, // Set the auto-play curve
                            enableInfiniteScroll: true,
                            enlargeFactor: 0.5,
                            autoPlayAnimationDuration: const Duration(milliseconds: 300), // Set the auto-play animation duration
                            aspectRatio: 16/9, // Set the aspect ratio of each item
                            viewportFraction: 0.8, // You can also customize other options such as enlargeCenterPage, enableInfiniteScroll, etc.
                          ),
                        ),
                        Positioned(
                          bottom: 80,
                          right: 0,
                          left: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               GestureDetector(
                                  onTap: ()=> buttonCarouselController.previousPage(
                                      duration: const Duration(milliseconds: 300), curve: Curves.linear),
                                    child: Image(
                                      image: const AssetImage('assets/arrowb1.png'),
                                      height: screenHeight/20,width: screenWidth/15,color: Colors.orange,)),
                             GestureDetector(
                                    onTap: () => buttonCarouselController.nextPage(
                                        duration: const Duration(milliseconds: 300), curve: Curves.linear),
                                    child: Image(
                                      image: const AssetImage('assets/arrowf1.png'),
                                      height: screenHeight/20,width: screenWidth/15,color: Colors.orange,)),
                            ],
                          ),
                        ),
                      ]
                  ),
                ),
                   const SizedBox(height: 100,),
                   // TweenAnimationBuilder(
                   //     tween: Tween<double>(begin:0,end:1),
                   //     duration: const Duration(milliseconds: 3000),
                   //     builder: (context,double value,child){
                   //       return Opacity(opacity: value,
                   //       child:  MaterialButton(
                   //         onPressed: (){},
                   //           height: 50,
                   //           minWidth: 100,
                   //           color: Colors.red,
                   //           child: const Text("Hello flutter")),);
                   // })
                 ],
                         ),
              ),
          //  ),
          ),
     )
    );
  }
}




